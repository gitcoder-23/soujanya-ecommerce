import 'dart:convert';
import 'dart:io';

const String _configPath = 'assets/config/social_sign_in.json';
const String _templatePath = 'assets/config/social_sign_in.template.json';

Future<void> main() async {
  stdout.writeln('┌───────────────────────────────┐');
  stdout.writeln('│   Social Sign-In Setup Tool   │');
  stdout.writeln('└───────────────────────────────┘\n');

  final File configFile = File(_configPath);

  if (!await configFile.exists()) {
    final templateFile = File(_templatePath);
    if (!await templateFile.exists()) {
      stderr.writeln(
        'Template file not found at $_templatePath. '
        'Please make sure the repository is intact.',
      );
      exitCode = 1;
      return;
    }

    await configFile.create(recursive: true);
    await configFile.writeAsString(await templateFile.readAsString());
    stdout.writeln('Created $_configPath from template.');
  }

  Map<String, dynamic> config;
  try {
    config = json.decode(await configFile.readAsString()) as Map<String, dynamic>;
  } catch (e) {
    stderr.writeln('Failed to read $_configPath: $e');
    stderr.writeln('Reset the file or fix the JSON format, then re-run this script.');
    exitCode = 1;
    return;
  }

  config['google'] = await _promptSection(
    title: 'Google Sign-In (required)',
    current: _readSection(config, 'google'),
    fields: const [
      _Field(
        key: 'enabled',
        label: 'Enable Google Sign-In',
        type: _FieldType.boolean,
        defaultBool: true,
      ),
      _Field(
        key: 'clientId',
        label: 'Google OAuth Client ID',
        required: true,
      ),
      _Field(
        key: 'serverClientId',
        label: 'Google OAuth Server Client ID',
        required: true,
      ),
    ],
  );

  config['facebook'] = await _promptSection(
    title: 'Facebook Login (optional)',
    current: _readSection(config, 'facebook'),
    fields: const [
      _Field(
        key: 'enabled',
        label: 'Enable Facebook Login',
        type: _FieldType.boolean,
      ),
      _Field(
        key: 'appId',
        label: 'Facebook App ID',
      ),
      _Field(
        key: 'clientToken',
        label: 'Facebook Client Token',
      ),
    ],
  );

  config['apple'] = await _promptSection(
    title: 'Sign in with Apple (optional)',
    current: _readSection(config, 'apple'),
    fields: const [
      _Field(
        key: 'enabled',
        label: 'Enable Sign in with Apple',
        type: _FieldType.boolean,
      ),
      _Field(
        key: 'serviceId',
        label: 'Apple Service ID',
      ),
      _Field(
        key: 'teamId',
        label: 'Apple Team ID',
      ),
    ],
  );

  config['twitter'] = await _promptSection(
    title: 'Twitter Login (optional)',
    current: _readSection(config, 'twitter'),
    fields: const [
      _Field(
        key: 'enabled',
        label: 'Enable Twitter Login',
        type: _FieldType.boolean,
      ),
      _Field(
        key: 'consumerKey',
        label: 'Twitter Consumer Key',
      ),
      _Field(
        key: 'consumerSecret',
        label: 'Twitter Consumer Secret',
      ),
    ],
  );

  const encoder = JsonEncoder.withIndent('  ');
  await configFile.writeAsString('${encoder.convert(config)}\n');

  stdout
    ..writeln('\nSaved Google Sign-In configuration to $_configPath.')
    ..writeln('You can re-run this script anytime to update the values.')
    ..writeln('\nNext steps:')
    ..writeln('  1. Restart the Flutter app so it reloads the new config.')
    ..writeln('  2. Tap the Google Sign-In button to verify the login flow.')
    ..writeln('\nNeed help? See docs/12_social_login_setup.md.');
}

Future<Map<String, dynamic>> _promptSection({
  required String title,
  Map<String, dynamic>? current,
  required List<_Field> fields,
}) async {
  stdout.writeln('\n$title');
  final result = <String, dynamic>{};
  for (final field in fields) {
    switch (field.type) {
      case _FieldType.text:
        final existing = current?[field.key]?.toString();
        final value = await _promptForString(
          label: field.label,
          currentValue: existing,
          required: field.required,
        );
        result[field.key] = value;
        break;
      case _FieldType.boolean:
        final existingBool = _toBool(current?[field.key]);
        final value = await _promptForBoolean(
          label: field.label,
          currentValue: existingBool ?? field.defaultBool,
        );
        result[field.key] = value;
        break;
    }
  }
  return result;
}

Future<String> _promptForString({
  required String label,
  String? currentValue,
  bool required = false,
}) async {
  final existing = currentValue?.trim() ?? '';

  while (true) {
    if (existing.isEmpty) {
      stdout.write('$label: ');
    } else {
      stdout.write('$label [$existing]: ');
    }

    final input = stdin.readLineSync()?.trim() ?? '';

    if (input.isEmpty) {
      if (existing.isNotEmpty) {
        return existing;
      }
      if (!required) {
        return '';
      }
      stdout.writeln(
        '  → A value is required. Please paste it from the provider console.',
      );
      continue;
    }

    return input;
  }
}

Future<bool> _promptForBoolean({
  required String label,
  bool? currentValue,
}) async {
  final effective = currentValue ?? false;
  final prompt = effective ? ' [Y/n]' : ' [y/N]';

  while (true) {
    stdout.write('$label$prompt: ');
    final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';

    if (input.isEmpty) {
      return effective;
    }

    if (input == 'y' || input == 'yes') {
      return true;
    }

    if (input == 'n' || input == 'no') {
      return false;
    }

    stdout.writeln('  → Please answer y or n.');
  }
}

Map<String, dynamic>? _readSection(
  Map<String, dynamic> config,
  String key,
) {
  final section = config[key];
  if (section is Map) {
    return section.map(
      (dynamic k, dynamic v) => MapEntry(k.toString(), v),
    );
  }
  return null;
}

bool? _toBool(Object? value) {
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return null;
}

enum _FieldType { text, boolean }

class _Field {
  const _Field({
    required this.key,
    required this.label,
    this.required = false,
    this.type = _FieldType.text,
    this.defaultBool,
  });

  final String key;
  final String label;
  final bool required;
  final _FieldType type;
  final bool? defaultBool;
}
