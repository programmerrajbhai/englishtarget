import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../widgets/splash_mascot.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _navigationTimer;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    _navigationTimer = Timer(
      const Duration(seconds: 3),
      _openNextScreen,
    );
  }


  Future<void> _openNextScreen() async {
    final onboardingCompleted =
    await LocalStorageService.isOnboardingCompleted();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      onboardingCompleted
          ? AppRoutes.home
          : AppRoutes.onboarding,
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            final horizontalPadding =
            (screenWidth * 0.065).clamp(20.0, 36.0).toDouble();

            final mascotSize =
            (screenWidth * 0.48).clamp(150.0, 225.0).toDouble();

            final topSpacing =
            (screenHeight * 0.10).clamp(35.0, 95.0).toDouble();

            final mascotBottomSpacing =
            (screenHeight * 0.045).clamp(20.0, 36.0).toDouble();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: topSpacing),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: SplashMascot(
                            size: mascotSize,
                          ),
                        ),
                      ),

                      SizedBox(height: mascotBottomSpacing),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'English Target',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: screenWidth < 360 ? 29 : 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Learn Rules. Speak with Confidence.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 7),

                            const Text(
                              'নিয়ম শিখুন, আত্মবিশ্বাসের সাথে বলুন',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      const _AnimatedLoadingDots(),

                      SizedBox(
                        height: (screenHeight * 0.035)
                            .clamp(18.0, 30.0)
                            .toDouble(),
                      ),

                      const Text(
                        'Learn  •  Practice  •  Improve',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),

                      SizedBox(
                        height: (screenHeight * 0.04)
                            .clamp(24.0, 38.0)
                            .toDouble(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedLoadingDots extends StatefulWidget {
  const _AnimatedLoadingDots();

  @override
  State<_AnimatedLoadingDots> createState() =>
      _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<_AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(
              size: 8 + (_controller.value * 3),
              opacity: 0.45 + (_controller.value * 0.35),
            ),
            const SizedBox(width: 9),
            _buildDot(
              size: 12 + (_controller.value * 4),
              opacity: 1,
            ),
            const SizedBox(width: 9),
            _buildDot(
              size: 11 - (_controller.value * 3),
              opacity: 0.80 - (_controller.value * 0.30),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDot({
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(
          (opacity.clamp(0.0, 1.0) * 255).round(),
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}