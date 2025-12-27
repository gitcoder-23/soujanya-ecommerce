import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/theme/app_fonts.dart';

class NoInternetScreen extends StatefulWidget {
  final VoidCallback? onRetry;

  const NoInternetScreen({super.key, this.onRetry});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Friendly illustration with custom design
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer decorative circle
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800.withValues(alpha: 0.3)
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    // Main container with illustration
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: Theme.of(context).brightness == Brightness.dark
                              ? [
                                  Colors.grey.shade900,
                                  Colors.grey.shade800.withValues(alpha: 0.5),
                                ]
                              : [
                                  Colors.grey.shade50,
                                  Colors.grey.shade100,
                                ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // WiFi signal with X
                          Positioned(
                            top: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.wifi,
                                  size: 70,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                ),
                                // Cross over WiFi
                                Transform.rotate(
                                  angle: 0.785398, // 45 degrees
                                  child: Container(
                                    width: 60,
                                    height: 3,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.red.shade400
                                        : Colors.red.shade300,
                                  ),
                                ),
                                Transform.rotate(
                                  angle: -0.785398, // -45 degrees
                                  child: Container(
                                    width: 60,
                                    height: 3,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.red.shade400
                                        : Colors.red.shade300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Small cloud below
                          Positioned(
                            bottom: 45,
                            child: Icon(
                              Icons.cloud_outlined,
                              size: 40,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Decorative dots around
                    Positioned(
                      top: 10,
                      right: 40,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 25,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      right: 20,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade500,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'common.no_internet_title'.tr(),
              style: kAppTextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.getPrimaryTextColor(context),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          // Message
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'common.no_internet_message'.tr(),
                style: kAppTextStyle(
                  fontSize: 15,
                  color: AppColors.getSecondaryTextColor(context),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const Spacer(flex: 2),

          // Retry button
          widget.onRetry != null
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: ElevatedButton(
                      onPressed: widget.onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'common.retry'.tr(),
                            style: kAppTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),

          const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}