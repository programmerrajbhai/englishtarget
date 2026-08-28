import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navigationTimer;

  bool _hasNavigated = false;

  late final AnimationController _entranceController;
  late final AnimationController _floatingController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(
        0,
        0.80,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.78,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.20,
          1,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _entranceController.forward();

    _navigationTimer = Timer(
      const Duration(milliseconds: 2800),
      _openNextScreen,
    );
  }

  Future<void> _openNextScreen() async {
    if (_hasNavigated) return;

    _hasNavigated = true;

    final bool onboardingCompleted =
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
    _entranceController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF071A31),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF071A31),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _SplashBackground(),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final double height = constraints.maxHeight;

                  final double horizontalPadding =
                  (width * 0.08)
                      .clamp(24.0, 42.0)
                      .toDouble();

                  final double logoSize =
                  (width * 0.43)
                      .clamp(148.0, 205.0)
                      .toDouble();

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: (height * 0.12)
                              .clamp(55.0, 105.0)
                              .toDouble(),
                        ),

                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: AnimatedBuilder(
                              animation: _floatingController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    -4 *
                                        _floatingController.value,
                                  ),
                                  child: child,
                                );
                              },
                              child: _BrandLogo(
                                size: logoSize,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: (height * 0.05)
                              .clamp(24.0, 42.0)
                              .toDouble(),
                        ),

                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: const Column(
                              children: [
                                Text(
                                  'English Target',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    height: 1.12,
                                    fontWeight:
                                    FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                                ),

                                SizedBox(height: 12),

                                Text(
                                  'Learn clearly. Speak confidently.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                    Color(0xFFD7E8E2),
                                    fontSize: 16,
                                    height: 1.45,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 8),

                                Text(
                                  'সহজভাবে শিখুন, আত্মবিশ্বাসের সাথে বলুন',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                    Color(0xFF75E2B6),
                                    fontSize: 14.5,
                                    height: 1.5,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const Column(
                            children: [
                              _SplashLoadingIndicator(),

                              SizedBox(height: 18),

                              Text(
                                'RULES  •  SENTENCES  •  SPEAKING',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                  Color(0xFF9CB1C3),
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: (height * 0.055)
                              .clamp(28.0, 48.0)
                              .toDouble(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  final double size;

  const _BrandLogo({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'English Target logo',
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.055),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF57E89C),
              AppColors.primary,
            ],
          ),
          border: Border.all(
            color: Colors.white.withAlpha(55),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
              AppColors.primary.withAlpha(105),
              blurRadius: 48,
              spreadRadius: 3,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/branding/app_icon.png',
            fit: BoxFit.cover,
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return const ColoredBox(
                color: Color(0xFF0A2848),
                child: Icon(
                  Icons.record_voice_over_rounded,
                  color: Colors.white,
                  size: 72,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF071A31),
            Color(0xFF0B2945),
            Color(0xFF073A35),
          ],
          stops: [
            0,
            0.54,
            1,
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -90,
            right: -85,
            child: _GlowCircle(
              size: 260,
              color: AppColors.primary,
            ),
          ),

          const Positioned(
            bottom: -120,
            left: -100,
            child: _GlowCircle(
              size: 310,
              color: AppColors.blue,
            ),
          ),

          Positioned(
            top: 150,
            left: 28,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 20,
              color: Colors.white.withAlpha(32),
            ),
          ),

          Positioned(
            right: 34,
            bottom: 190,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 28,
              color: const Color(0xFF75E2B6)
                  .withAlpha(45),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(15),
        border: Border.all(
          color: color.withAlpha(18),
          width: 24,
        ),
      ),
    );
  }
}

class _SplashLoadingIndicator
    extends StatelessWidget {
  const _SplashLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: const LinearProgressIndicator(
          minHeight: 4,
          backgroundColor: Color(0xFF29465C),
          color: Color(0xFF42D993),
        ),
      ),
    );
  }
}