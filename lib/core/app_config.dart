import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://soujanya360.com';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String appName = dotenv.env['APP_NAME'] ?? 'Soujanya';
  static String appEnv = dotenv.env['APP_ENV'] ?? 'development';
  static String testEmail = dotenv.env['TEST_EMAIL'] ?? '';
  static String testPassword = dotenv.env['TEST_PASSWORD'] ?? '';

  static List<String>? adKeys = dotenv.env['AD_KEYS']?.split(',');

  /// Resolves a URL by prepending the base URL if it's a relative path.
  /// If the URL already has a scheme (http/https), it is returned as-is.
  static String resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    String baseUrl =
        apiBaseUrl.endsWith('/')
            ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
            : apiBaseUrl;
    String path = url.startsWith('/') ? url : '/$url';

    return '$baseUrl$path';
  }

  static String get helpCenterUrl =>
      resolveUrl(dotenv.env['HELP_CENTER_URL'] ?? '/contact');

  static String get customerSupportUrl =>
      resolveUrl(dotenv.env['CUSTOMER_SUPPORT_URL'] ?? '/contact');

  // Language Configuration
  static String get defaultLanguage =>
      dotenv.env['DEFAULT_LANGUAGE']?.toLowerCase() ?? 'en';
  static String get defaultLanguageDirection =>
      dotenv.env['DEFAULT_LANGUAGE_DIRECTION']?.toLowerCase() ?? 'ltr';

  // Theme Configuration
  static String get defaultThemeMode =>
      dotenv.env['DEFAULT_THEME_MODE']?.toLowerCase() ?? 'system';

  // RTL language mapping
  static const Map<String, bool> _rtlLanguages = {
    'ar': true, // Arabic
    'he': true, // Hebrew
    'fa': true, // Persian/Farsi
    'ur': true, // Urdu
    'ku': true, // Kurdish
    'ps': true, // Pashto
    'sd': true, // Sindhi
    'yi': true, // Yiddish
  };

  // Check if a language code is RTL
  static bool isLanguageRtl(String languageCode) {
    return _rtlLanguages[languageCode.toLowerCase()] ?? false;
  }

  // Get the effective RTL status based on language and direction settings
  static bool get isDefaultLanguageRtl {
    // First check if DEFAULT_LANGUAGE_DIRECTION is explicitly set
    if (dotenv.env['DEFAULT_LANGUAGE_DIRECTION'] != null) {
      return defaultLanguageDirection == 'rtl';
    }
    // Otherwise, determine from the language code
    return isLanguageRtl(defaultLanguage);
  }

  // Twitter
  static String? twitterConsumerKey = dotenv.env['TWITTER_CONSUMER_KEY'];
  static String? twitterConsumerSecret = dotenv.env['TWITTER_CONSUMER_SECRET'];
  static bool? _twitterEnabledConfig;
  static String twitterRedirectUri =
      dotenv.env['TWITTER_REDIRECT_URI'] ?? 'soujanya://twitter-auth';

  // Google
  static String? googleClientId;
  static String? googleServerClientId;
  static bool? _googleEnabledConfig;

  // Facebook
  static String? facebookAppId = dotenv.env['FACEBOOK_APP_ID'];
  static String? facebookClientToken = dotenv.env['FACEBOOK_CLIENT_TOKEN'];
  static bool? _facebookEnabledConfig;

  // Apple
  static String? appleServiceId = dotenv.env['APPLE_SERVICE_ID'];
  static String? appleTeamId = dotenv.env['APPLE_TEAM_ID'];
  static bool? _appleEnabledConfig;

  // Social Login Configuration
  static bool get enableAppleSignIn {
    final allow = _envOrConfigFlag(
      dotenv.env['ENABLE_APPLE_SIGN_IN'],
      _appleEnabledConfig,
    );
    return allow &&
        appleServiceId?.isNotEmpty == true &&
        appleTeamId?.isNotEmpty == true;
  }

  static bool get enableGoogleSignIn {
    final allow = _envOrConfigFlag(
      dotenv.env['ENABLE_GOOGLE_SIGN_IN'],
      _googleEnabledConfig,
      defaultValue: true,
    );
    return allow &&
        googleClientId?.isNotEmpty == true &&
        googleServerClientId?.isNotEmpty == true;
  }

  static bool get enableFacebookSignIn {
    final allow = _envOrConfigFlag(
      dotenv.env['ENABLE_FACEBOOK_SIGN_IN'],
      _facebookEnabledConfig,
    );
    return allow &&
        facebookAppId?.isNotEmpty == true &&
        facebookClientToken?.isNotEmpty == true;
  }

  static bool get enableTwitterSignIn {
    final allow = _envOrConfigFlag(
      dotenv.env['ENABLE_TWITTER_SIGN_IN'],
      _twitterEnabledConfig,
    );
    return allow &&
        twitterConsumerKey?.isNotEmpty == true &&
        twitterConsumerSecret?.isNotEmpty == true;
  }

  // Utility method to check if any social login is enabled
  static bool get hasAnySocialLoginEnabled =>
      enableAppleSignIn ||
      enableGoogleSignIn ||
      enableFacebookSignIn ||
      enableTwitterSignIn;

  // Order Upload Proof Configuration
  static bool get enableOrderUploadProof =>
      dotenv.env['ENABLE_ORDER_UPLOAD_PROOF']?.toLowerCase() != 'false';

  // Guest Checkout Configuration
  static bool get enableGuestCheckout =>
      dotenv.env['ENABLE_GUEST_CHECKOUT']?.toLowerCase() == 'true';

  // Product Image Configuration
  static String get productImageThumbnailSize =>
      dotenv.env['PRODUCT_IMAGE_THUMBNAIL_SIZE']?.toLowerCase() ?? 'small';

  // Help Center Configuration
  // Only use local help if USE_LOCAL_HELP is explicitly set to 'true'
  // Otherwise, use WebView (default behavior)
  static bool get useLocalHelpCenter =>
      dotenv.env['USE_LOCAL_HELP']?.toLowerCase() == 'true';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
    await _loadSocialLoginConfig();
    googleClientId ??= _cleanString(dotenv.env['GOOGLE_CLIENT_ID']);
    googleServerClientId ??= _cleanString(
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
    );
    facebookAppId ??= _cleanString(dotenv.env['FACEBOOK_APP_ID']);
    facebookClientToken ??= _cleanString(dotenv.env['FACEBOOK_CLIENT_TOKEN']);
    appleServiceId ??= _cleanString(dotenv.env['APPLE_SERVICE_ID']);
    appleTeamId ??= _cleanString(dotenv.env['APPLE_TEAM_ID']);
    twitterConsumerKey ??= _cleanString(dotenv.env['TWITTER_CONSUMER_KEY']);
    twitterConsumerSecret ??= _cleanString(
      dotenv.env['TWITTER_CONSUMER_SECRET'],
    );
  }

  static Future<void> _loadSocialLoginConfig() async {
    const path = 'assets/config/social_sign_in.json';
    try {
      final raw = await rootBundle.loadString(path);
      final Map<String, dynamic> data =
          json.decode(raw) as Map<String, dynamic>;
      final googleData = _readSection(data, 'google');
      if (googleData != null) {
        _googleEnabledConfig = _cleanBool(googleData['enabled']);
        googleClientId = _cleanString(googleData['clientId']);
        googleServerClientId = _cleanString(googleData['serverClientId']);
      }

      final facebookData = _readSection(data, 'facebook');
      if (facebookData != null) {
        _facebookEnabledConfig = _cleanBool(facebookData['enabled']);
        facebookAppId = _cleanString(facebookData['appId']);
        facebookClientToken = _cleanString(facebookData['clientToken']);
      }

      final appleData = _readSection(data, 'apple');
      if (appleData != null) {
        _appleEnabledConfig = _cleanBool(appleData['enabled']);
        appleServiceId = _cleanString(appleData['serviceId']);
        appleTeamId = _cleanString(appleData['teamId']);
      }

      final twitterData = _readSection(data, 'twitter');
      if (twitterData != null) {
        _twitterEnabledConfig = _cleanBool(twitterData['enabled']);
        twitterConsumerKey = _cleanString(twitterData['consumerKey']);
        twitterConsumerSecret = _cleanString(twitterData['consumerSecret']);
      }
    } on FlutterError catch (_) {
      debugPrint(
        'Social login config not found at assets/config/social_sign_in.json',
      );
    } catch (e) {
      debugPrint('Failed to load social login config: $e');
    }
  }

  static String? _cleanString(Object? value) {
    if (value == null) return null;
    final trimmed = value.toString().trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool? _cleanBool(Object? value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }

  static bool _envOrConfigFlag(
    String? envValue,
    bool? configValue, {
    bool defaultValue = false,
  }) {
    final envFlag = _cleanBool(envValue);
    if (envFlag != null) return envFlag;
    if (configValue != null) return configValue;
    return defaultValue;
  }

  static Map<String, dynamic>? _readSection(
    Map<String, dynamic> data,
    String key,
  ) {
    final section = data[key];
    if (section is Map) {
      return section.map((dynamic k, dynamic v) => MapEntry(k.toString(), v));
    }
    return null;
  }
}
