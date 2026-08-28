import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/onboarding_data.dart';
import '../models/onboarding_item.dart';
import '../widgets/onboarding_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _pageController =
  PageController();

  int _currentPage = 0;
  bool _isFinishing = false;

  int get _pageCount =>
      OnboardingData.items.length;

  bool get _isLastPage =>
      _currentPage == _pageCount - 1;

  Future<void> _nextPage() async {
    if (_isFinishing) return;

    HapticFeedback.selectionClick();

    if (_isLastPage) {
      await _finishOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(
        milliseconds: 420,
      ),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skipOnboarding() async {
    if (_isFinishing) return;

    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;

    setState(() {
      _isFinishing = true;
    });

    try {
      await LocalStorageService
          .completeOnboarding();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isFinishing = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingItem activeItem =
    OnboardingData.items[_currentPage];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        Brightness.dark,
        statusBarBrightness:
        Brightness.light,
        systemNavigationBarColor:
        AppColors.background,
        systemNavigationBarIconBrightness:
        Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -110,
                right: -100,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 400,
                  ),
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeItem
                        .accentColor
                        .withAlpha(13),
                  ),
                ),
              ),

              LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  final double width =
                      constraints.maxWidth;

                  final double height =
                      constraints.maxHeight;

                  final double horizontalPadding =
                  (width * 0.06)
                      .clamp(20.0, 34.0)
                      .toDouble();

                  return Column(
                    children: [
                      Padding(
                        padding:
                        EdgeInsets.fromLTRB(
                          horizontalPadding,
                          10,
                          horizontalPadding,
                          0,
                        ),
                        child: _OnboardingHeader(
                          currentPage:
                          _currentPage,
                          pageCount:
                          _pageCount,
                          onSkip:
                          _skipOnboarding,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Expanded(
                        child: PageView.builder(
                          controller:
                          _pageController,
                          physics:
                          const BouncingScrollPhysics(),
                          itemCount: _pageCount,
                          onPageChanged: (
                              index,
                              ) {
                            setState(() {
                              _currentPage =
                                  index;
                            });
                          },
                          itemBuilder: (
                              context,
                              index,
                              ) {
                            return _OnboardingPage(
                              item: OnboardingData
                                  .items[index],
                              availableHeight:
                              height,
                              horizontalPadding:
                              horizontalPadding,
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding:
                        EdgeInsets.fromLTRB(
                          horizontalPadding,
                          10,
                          horizontalPadding,
                          18,
                        ),
                        child: _OnboardingFooter(
                          currentPage:
                          _currentPage,
                          pageCount:
                          _pageCount,
                          isLastPage:
                          _isLastPage,
                          isLoading:
                          _isFinishing,
                          accentColor:
                          activeItem
                              .accentColor,
                          onPressed:
                          _nextPage,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingHeader
    extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final VoidCallback onSkip;

  const _OnboardingHeader({
    required this.currentPage,
    required this.pageCount,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF0A2848),
            borderRadius:
            BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color:
                AppColors.navy.withAlpha(20),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(10),
            child: Image.asset(
              'assets/branding/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 11),

        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'English Target',
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Your speaking journey',
                style: TextStyle(
                  color:
                  AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        if (currentPage < pageCount - 1)
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor:
              AppColors.textSecondary,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _OnboardingPage
    extends StatelessWidget {
  final OnboardingItem item;
  final double availableHeight;
  final double horizontalPadding;

  const _OnboardingPage({
    required this.item,
    required this.availableHeight,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.sizeOf(context).width;

    final double illustrationSize =
    (width * 0.59)
        .clamp(
      185.0,
      availableHeight < 650
          ? 210.0
          : 270.0,
    )
        .toDouble();

    return SingleChildScrollView(
      physics:
      const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
          availableHeight * 0.68,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            SizedBox(
              height:
              availableHeight < 650
                  ? 8
                  : 18,
            ),

            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.85,
                end: 1,
              ),
              duration: const Duration(
                milliseconds: 650,
              ),
              curve: Curves.easeOutBack,
              builder: (
                  context,
                  value,
                  child,
                  ) {
                return Opacity(
                  opacity: value
                      .clamp(0.0, 1.0)
                      .toDouble(),
                  child: Transform.scale(
                    scale: value,
                    child: child,
                  ),
                );
              },
              child: OnboardingIllustration(
                item: item,
                size: illustrationSize,
              ),
            ),

            SizedBox(
              height:
              availableHeight < 650
                  ? 20
                  : 32,
            ),

            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: item.accentColor
                    .withAlpha(18),
                borderRadius:
                BorderRadius.circular(99),
                border: Border.all(
                  color: item.accentColor
                      .withAlpha(35),
                ),
              ),
              child: Text(
                _pageLabel(),
                style: TextStyle(
                  color: item.accentColor,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              item.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize:
                width < 360 ? 25 : 29,
                height: 1.16,
                fontWeight:
                FontWeight.w900,
                letterSpacing: -0.7,
              ),
            ),

            const SizedBox(height: 14),

            ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 480,
              ),
              child: Text(
                item.description,
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  color:
                  AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.62,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _pageLabel() {
    if (item.accentColor ==
        AppColors.primary) {
      return 'LEARN WITH CLARITY';
    }

    if (item.accentColor ==
        AppColors.blue) {
      return 'PRACTISE SMARTER';
    }

    return 'SPEAK WITH CONFIDENCE';
  }
}

class _OnboardingFooter
    extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final bool isLastPage;
  final bool isLoading;
  final Color accentColor;
  final VoidCallback onPressed;

  const _OnboardingFooter({
    required this.currentPage,
    required this.pageCount,
    required this.isLastPage,
    required this.isLoading,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: List.generate(
            pageCount,
                (index) {
              final bool selected =
                  index == currentPage;

              return AnimatedContainer(
                duration: const Duration(
                  milliseconds: 260,
                ),
                curve: Curves.easeOut,
                width: selected ? 30 : 8,
                height: 8,
                margin:
                const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? accentColor
                      : AppColors.border,
                  borderRadius:
                  BorderRadius.circular(99),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed:
            isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor:
              AppColors.primary,
              disabledBackgroundColor:
              AppColors.primary
                  .withAlpha(150),
              foregroundColor:
              Colors.white,
              elevation: 0,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(17),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 220,
              ),
              child: isLoading
                  ? const SizedBox(
                key:
                ValueKey('loading'),
                width: 23,
                height: 23,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Row(
                key: ValueKey(
                  isLastPage,
                ),
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  Text(
                    isLastPage
                        ? 'Start Learning'
                        : 'Continue',
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    width: 9,
                  ),
                  Icon(
                    isLastPage
                        ? Icons
                        .rocket_launch_rounded
                        : Icons
                        .arrow_forward_rounded,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          isLastPage
              ? 'Your progress will be saved on this device'
              : 'Swipe or tap Continue',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}