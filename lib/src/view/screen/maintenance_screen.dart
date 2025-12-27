import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/theme/app_fonts.dart';

class MaintenanceScreen extends StatefulWidget {
  final VoidCallback? onRetry;

  const MaintenanceScreen({super.key, this.onRetry});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;

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

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
                                        ? Colors.orange.shade900.withValues(alpha: 0.3)
                                        : Colors.orange.shade100,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: Theme.of(context).brightness == Brightness.dark
                                      ? [
                                          Colors.orange.shade900.withValues(alpha: 0.2),
                                          Colors.orange.shade800.withValues(alpha: 0.1),
                                        ]
                                      : [
                                          Colors.orange.shade50,
                                          Colors.orange.shade100.withValues(alpha: 0.7),
                                        ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: _rotationAnimation.value,
                                    child: Icon(
                                      Icons.settings,
                                      size: 70,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.orange.shade600
                                          : Colors.orange.shade700,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 55,
                                    right: 55,
                                    child: Transform.rotate(
                                      angle: -0.5,
                                      child: Icon(
                                        Icons.build,
                                        size: 35,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.orange.shade500
                                            : Colors.orange.shade600,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 45,
                                    right: 50,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.amber.shade700
                                            : Colors.amber.shade500,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.priority_high_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 40,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade400.withValues(alpha: 0.6),
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
                                      ? Colors.orange.shade700
                                      : Colors.orange.shade300,
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
                                      ? Colors.orange.shade800
                                      : Colors.orange.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 60,
                              left: 15,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade500.withValues(alpha: 0.5),
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

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'common.maintenance_mode'.tr(),
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

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'common.maintenance_message'.tr(),
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
                                    'common.maintenance_retry'.tr(),
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