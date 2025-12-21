import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:martfury/src/service/biometric_service.dart';
import 'package:martfury/src/service/profile_service.dart';
import 'package:martfury/src/service/user_service.dart';
import 'package:martfury/src/service/notification_service.dart';
import 'package:martfury/src/service/token_service.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/view/screen/sign_in_screen.dart';
import 'package:martfury/src/view/widget/change_password_dialog.dart';
import 'package:local_auth/local_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  final ProfileService _profileService = ProfileService();
  final UserService _userService = UserService();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricEnabledInAPI = false;
  bool _isLoading = true;
  bool _isUpdating = false;
  BiometricType? _biometricType;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load settings from API first (only if the endpoint exists)
      try {
        final profile = await _profileService.getProfile();
        // Check if the API returns settings object with biometric_enabled field
        if (profile.containsKey('settings') && profile['settings'] is Map) {
          final settings = profile['settings'] as Map<String, dynamic>;
          if (settings.containsKey('biometric_enabled')) {
            _isBiometricEnabledInAPI = settings['biometric_enabled'] == true;
          } else {
            _isBiometricEnabledInAPI =
                await BiometricService.isBiometricLoginEnabled();
          }
        } else if (profile.containsKey('biometric_enabled')) {
          // Fallback to root level biometric_enabled if it exists
          _isBiometricEnabledInAPI = profile['biometric_enabled'] == true;
        } else {
          // API doesn't have biometric field yet, use local setting
          _isBiometricEnabledInAPI =
              await BiometricService.isBiometricLoginEnabled();
        }
      } catch (e) {
        // Continue with local settings if API fails
        _isBiometricEnabledInAPI =
            await BiometricService.isBiometricLoginEnabled();
      }

      // Check if biometric is available
      _isBiometricAvailable = await _biometricService.isBiometricAvailable();

      if (_isBiometricAvailable) {
        // Get available biometric types
        final biometrics = await _biometricService.getAvailableBiometrics();
        if (biometrics.isNotEmpty) {
          // Prioritize Face ID on iOS
          if (biometrics.contains(BiometricType.face)) {
            _biometricType = BiometricType.face;
          } else if (biometrics.contains(BiometricType.fingerprint)) {
            _biometricType = BiometricType.fingerprint;
          } else {
            _biometricType = biometrics.first;
          }
        }

        // Check if biometric login is enabled locally
        _isBiometricEnabled = await BiometricService.isBiometricLoginEnabled();

        // Sync with API setting if different
        if (_isBiometricEnabled != _isBiometricEnabledInAPI) {
          // Prefer API setting as source of truth
          _isBiometricEnabled = _isBiometricEnabledInAPI;
          await BiometricService.setBiometricLoginEnabled(_isBiometricEnabled);
        }
      }
    } catch (e) {
      // Failed to load biometric settings - using default values
      debugPrint('Failed to load biometric settings: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      if (value) {
        // Authenticate before enabling
        final authenticated = await _biometricService.authenticate(
          reason: 'profile.authenticate_to_enable_biometric'.tr(),
        );

        if (authenticated) {
          // Update local setting
          await BiometricService.setBiometricLoginEnabled(true);

          // Store the current auth token for biometric login
          final currentToken = await TokenService.getToken();

          if (currentToken != null) {
            await BiometricService.setBiometricToken(currentToken);

            // Verify it was saved
            await BiometricService.getBiometricToken();
          } else {}

          // Update API setting
          try {
            await _profileService.updateSettings(biometricEnabled: true);
          } catch (e) {
            // Continue even if API update fails
          }

          setState(() {
            _isBiometricEnabled = true;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('profile.biometric_enabled'.tr()),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        // Disable biometric login
        await BiometricService.setBiometricLoginEnabled(false);
        await BiometricService.setBiometricToken(null);

        // Update API setting
        try {
          await _profileService.updateSettings(biometricEnabled: false);
        } catch (e) {
          // Continue even if API update fails
        }

        setState(() {
          _isBiometricEnabled = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('profile.biometric_disabled'.tr()),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  String _getBiometricLabel() {
    if (_biometricType == BiometricType.face) {
      return 'profile.face_id'.tr();
    } else if (_biometricType == BiometricType.fingerprint) {
      return 'profile.touch_id'.tr();
    } else {
      return 'profile.biometric_authentication'.tr();
    }
  }

  String _getBiometricDescription() {
    if (_biometricType == BiometricType.face) {
      return 'profile.use_face_id_to_login'.tr();
    } else if (_biometricType == BiometricType.fingerprint) {
      return 'profile.use_touch_id_to_login'.tr();
    } else {
      return 'profile.use_biometric_to_login'.tr();
    }
  }

  Future<void> _handleAccountDeletion() async {
    final reason = await _showAccountDeletionReasonDialog();
    if (reason == null) {
      return;
    }

    final deletionRequested = await _requestAccountDeletion(reason);
    if (!deletionRequested) {
      return;
    }

    final verificationSucceeded = await _showAccountDeletionOtpDialog();
    if (verificationSucceeded != true) {
      return;
    }

    final deletionAcknowledged = await _showAccountDeletionSuccessDialog();
    if (deletionAcknowledged == true) {
      await _logoutAfterAccountDeletion();
    }
  }

  Future<String?> _showAccountDeletionReasonDialog() async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final reasonLength = controller.text.trim().length;

              return SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(sheetContext),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.getSecondaryTextColor(
                              sheetContext,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'profile.delete_account_confirmation_title'
                                      .tr(),
                                  style: kAppTextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.getPrimaryTextColor(
                                      sheetContext,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'profile.delete_account_confirmation_message'
                                      .tr(),
                                  style: kAppTextStyle(
                                    fontSize: 14,
                                    color: AppColors.getSecondaryTextColor(
                                      sheetContext,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        minLines: 3,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        decoration: InputDecoration(
                          labelText: 'profile.delete_account_reason_label'.tr(),
                          hintText: 'profile.delete_account_reason_hint'.tr(),
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: AppColors.getSurfaceColor(sheetContext),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.getBorderColor(sheetContext),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$reasonLength/200',
                          style: kAppTextStyle(
                            fontSize: 12,
                            color: AppColors.getSecondaryTextColor(
                              sheetContext,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(sheetContext).pop(null);
                              },
                              child: Text('common.cancel'.tr()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(
                                  sheetContext,
                                ).pop(controller.text.trim());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('common.confirm'.tr()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<bool> _requestAccountDeletion(String? reason) async {
    if (!mounted) {
      return false;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('common.loading'.tr()),
              ],
            ),
          ),
    );

    try {
      await _userService.requestAccountDeletion(reason: reason);

      if (!mounted) {
        return true;
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.delete_account_request_success'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      return true;
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile.delete_account_request_failed'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<bool?> _showAccountDeletionOtpDialog() {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (sheetContext) {
        final controllers = List.generate(6, (_) => TextEditingController());
        final focusNodes = List.generate(6, (_) => FocusNode());
        String? errorText;
        bool isVerifying = false;

        void disposeResources() {
          for (final controller in controllers) {
            controller.dispose();
          }
          for (final node in focusNodes) {
            node.dispose();
          }
        }

        String getEnteredCode() {
          return controllers.map((controller) => controller.text.trim()).join();
        }

        return StatefulBuilder(
          builder:
              (otpContext, setState) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(otpContext).viewInsets.bottom,
                ),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(sheetContext),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppColors.getSecondaryTextColor(
                                sheetContext,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.verified_user,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'profile.delete_account_otp_title'.tr(),
                                    style: kAppTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.getPrimaryTextColor(
                                        sheetContext,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'profile.delete_account_otp_message'.tr(),
                                    style: kAppTextStyle(
                                      fontSize: 14,
                                      color: AppColors.getSecondaryTextColor(
                                        sheetContext,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 64,
                          child: Row(
                            children: [
                              for (var i = 0; i < controllers.length; i++) ...[
                                Expanded(
                                  child: TextField(
                                    controller: controllers[i],
                                    focusNode: focusNodes[i],
                                    autofocus: i == 0,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: kAppTextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.getPrimaryTextColor(
                                        otpContext,
                                      ),
                                    ),
                                    maxLength: 1,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(1),
                                    ],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: AppColors.getSurfaceColor(
                                        sheetContext,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.getBorderColor(
                                            sheetContext,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.getBorderColor(
                                            sheetContext,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        errorText = null;
                                      });

                                      if (value.isNotEmpty &&
                                          i < focusNodes.length - 1) {
                                        focusNodes[i + 1].requestFocus();
                                      } else if (value.isEmpty && i > 0) {
                                        focusNodes[i - 1].requestFocus();
                                      }
                                    },
                                    enabled: !isVerifying,
                                  ),
                                ),
                                if (i != controllers.length - 1)
                                  const SizedBox(width: 12),
                              ],
                            ],
                          ),
                        ),
                        if (isVerifying) ...[
                          const SizedBox(height: 20),
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'profile.delete_account_verifying'.tr(),
                              style: kAppTextStyle(
                                fontSize: 13,
                                color: AppColors.getSecondaryTextColor(
                                  sheetContext,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (errorText != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorText!,
                                    style: kAppTextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  disposeResources();
                                  Navigator.of(sheetContext).pop(false);
                                },
                                child: Text('common.cancel'.tr()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    isVerifying
                                        ? null
                                        : () async {
                                          final code = getEnteredCode();
                                          bool sheetClosed = false;

                                          if (code.length ==
                                              controllers.length) {
                                            setState(() {
                                              errorText = null;
                                              isVerifying = true;
                                            });

                                            try {
                                              await _userService
                                                  .verifyAccountDeletion(
                                                    verificationCode: code,
                                                  );
                                              disposeResources();
                                              if (sheetContext.mounted) {
                                                sheetClosed = true;
                                                Navigator.of(
                                                  sheetContext,
                                                ).pop(true);
                                              }
                                            } catch (error) {
                                              setState(() {
                                                final message =
                                                    error.toString();
                                                final cleanedMessage =
                                                    message.startsWith(
                                                          'Exception: ',
                                                        )
                                                        ? message.replaceFirst(
                                                          'Exception: ',
                                                          '',
                                                        )
                                                        : message;
                                                errorText =
                                                    cleanedMessage.isNotEmpty
                                                        ? cleanedMessage
                                                        : 'profile.delete_account_verification_failed'
                                                            .tr();
                                              });
                                            } finally {
                                              if (!sheetClosed) {
                                                setState(() {
                                                  isVerifying = false;
                                                });
                                              }
                                            }
                                          } else {
                                            setState(() {
                                              errorText =
                                                  'profile.delete_account_otp_error'
                                                      .tr();
                                            });
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('common.confirm'.tr()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }

  Future<bool?> _showAccountDeletionSuccessDialog() {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      builder:
          (sheetContext) => SafeArea(
            top: false,
            bottom: false,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceColor(sheetContext),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.getSecondaryTextColor(
                        sheetContext,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'profile.delete_account_success_title'.tr(),
                    textAlign: TextAlign.center,
                    style: kAppTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getPrimaryTextColor(sheetContext),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'profile.delete_account_success_message'.tr(),
                    textAlign: TextAlign.center,
                    style: kAppTextStyle(
                      fontSize: 14,
                      color: AppColors.getSecondaryTextColor(sheetContext),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('common.confirm'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _logoutAfterAccountDeletion() async {
    await NotificationService.unregisterDeviceToken();
    await TokenService.deleteToken();

    if (!mounted) {
      return;
    }

    Get.offAll(() => const SignInScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile.settings'.tr(),
          style: kAppTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security Section
                    Text(
                      'profile.security'.tr(),
                      style: kAppTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Biometric Authentication Toggle
                    if (_isBiometricAvailable)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SwitchListTile(
                          title: Text(
                            _getBiometricLabel(),
                            style: kAppTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getPrimaryTextColor(context),
                            ),
                          ),
                          subtitle: Text(
                            _getBiometricDescription(),
                            style: kAppTextStyle(
                              fontSize: 14,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                          value: _isBiometricEnabled,
                          onChanged: _isUpdating ? null : _toggleBiometric,
                          activeColor: AppColors.primary,
                          secondary:
                              _isUpdating
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : null,
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.getSecondaryTextColor(
                              context,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.getSecondaryTextColor(
                                    context,
                                  ),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'profile.biometric_not_available'.tr(),
                                  style: kAppTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.getPrimaryTextColor(
                                      context,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'profile.biometric_not_available_description'
                                  .tr(),
                              style: kAppTextStyle(
                                fontSize: 14,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Additional security info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.security,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'profile.biometric_security_info'.tr(),
                              style: kAppTextStyle(
                                fontSize: 14,
                                color: AppColors.getPrimaryTextColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Change Password Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.lock_outline,
                          color: AppColors.getPrimaryTextColor(context),
                        ),
                        title: Text(
                          'profile.change_password'.tr(),
                          style: kAppTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.getPrimaryTextColor(context),
                          ),
                        ),
                        subtitle: Text(
                          'profile.update_your_account_password'.tr(),
                          style: kAppTextStyle(
                            fontSize: 14,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ChangePasswordDialog(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Delete Account Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        title: Text(
                          'profile.delete_account'.tr(),
                          style: kAppTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        subtitle: Text(
                          'profile.delete_account_description'.tr(),
                          style: kAppTextStyle(
                            fontSize: 14,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.red,
                        ),
                        onTap: _handleAccountDeletion,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
