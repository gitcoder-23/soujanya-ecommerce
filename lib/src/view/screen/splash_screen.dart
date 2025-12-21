import 'package:flutter/material.dart';
import 'package:martfury/src/service/token_service.dart';
import 'package:martfury/src/service/onboarding_service.dart';
import 'package:martfury/src/view/screen/main_screen.dart';
import 'package:martfury/src/view/screen/start_screen.dart';
import 'package:martfury/src/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Start animation and check auth
    _controller.forward();
    _checkAuthAndRedirect();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndRedirect() async {
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Show splash for 3 seconds

    if (!mounted) return;

    // Check both authentication and onboarding status
    final token = await TokenService.getToken();
    final hasCompletedOnboarding = await OnboardingService.hasCompletedOnboarding();

    if (!mounted) return;

    if (token != null) {
      // User is logged in, go to main screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else if (!hasCompletedOnboarding) {
      // User has not completed onboarding, show onboarding screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const StartScreen()),
      );
    } else {
      // User has completed onboarding but not logged in, go to main screen (guest mode)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image.asset('assets/images/logo.png', width: 200)],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
