import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:martfury/src/service/profile_service.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/theme/app_fonts.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    double strength = 0;
    if (password.isNotEmpty) {
      if (password.length >= 6) strength += 0.25;
      if (password.length >= 8) strength += 0.25;
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
      if (password.contains(RegExp(r'[0-9!@#$%^&*]'))) strength += 0.25;
    }
    setState(() => _passwordStrength = strength);
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 0.25) return AppColors.error;
    if (_passwordStrength <= 0.5) return AppColors.warning;
    if (_passwordStrength <= 0.75) return Colors.orange;
    return AppColors.success;
  }

  String _getStrengthLabel() {
    if (_passwordStrength <= 0) return '';
    if (_passwordStrength <= 0.25) return 'Weak';
    if (_passwordStrength <= 0.5) return 'Fair';
    if (_passwordStrength <= 0.75) return 'Good';
    return 'Strong';
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _profileService.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        Get.snackbar(
          'common.success'.tr(),
          'profile.password_updated_successfully'.tr(),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'profile.password_update_failed'.tr();

        if (e.toString().contains('Current password is not valid') ||
            e.toString().contains('current password is incorrect') ||
            e.toString().contains('401') ||
            e.toString().contains('403')) {
          errorMessage = 'profile.current_password_incorrect'.tr();
        } else if (e.toString().contains('password must be at least') ||
            e.toString().contains('min:6')) {
          errorMessage = 'profile.password_too_short'.tr();
        }

        Get.snackbar(
          'common.error'.tr(),
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _buildPasswordInputDecoration({
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: kAppTextStyle(
        color: AppColors.getHintTextColor(context),
      ),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
      prefixIcon: Icon(
        Icons.lock_outline,
        color: AppColors.getSecondaryTextColor(context),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.getSecondaryTextColor(context),
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'profile.change_password'.tr(),
            style: kAppTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getPrimaryTextColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelText(String labelKey) {
    return Text(
      labelKey.tr(),
      style: kAppTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.getPrimaryTextColor(context),
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    if (_newPasswordController.text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]
                  : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getStrengthLabel(),
            style: kAppTextStyle(
              fontSize: 12,
              color: _getStrengthColor(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: AppColors.getCardBackgroundColor(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              // Current password
              _buildLabelText('profile.current_password'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: kAppTextStyle(
                  fontSize: 16,
                  color: AppColors.getPrimaryTextColor(context),
                ),
                decoration: _buildPasswordInputDecoration(
                  hintText: 'profile.enter_current_password'.tr(),
                  obscureText: _obscureCurrentPassword,
                  onToggleVisibility: () => setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'profile.please_enter_current_password'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New password
              _buildLabelText('profile.new_password'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: kAppTextStyle(
                  fontSize: 16,
                  color: AppColors.getPrimaryTextColor(context),
                ),
                decoration: _buildPasswordInputDecoration(
                  hintText: 'profile.enter_new_password'.tr(),
                  obscureText: _obscureNewPassword,
                  onToggleVisibility: () =>
                      setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                onChanged: _updatePasswordStrength,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'profile.please_enter_new_password'.tr();
                  }
                  if (value.length < 6) {
                    return 'profile.password_min_length'.tr();
                  }
                  return null;
                },
              ),
              _buildStrengthIndicator(),
              const SizedBox(height: 16),

              // Confirm password
              _buildLabelText('auth.confirm_password'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: kAppTextStyle(
                  fontSize: 16,
                  color: AppColors.getPrimaryTextColor(context),
                ),
                decoration: _buildPasswordInputDecoration(
                  hintText: 'profile.confirm_new_password'.tr(),
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'profile.please_confirm_password'.tr();
                  }
                  if (value != _newPasswordController.text) {
                    return 'auth.passwords_do_not_match'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Cancel link (centered)
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'common.cancel'.tr(),
                    style: kAppTextStyle(
                      color: AppColors.getSecondaryTextColor(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Full-width submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'profile.update_password'.tr(),
                          style: kAppTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
