import 'package:flutter/material.dart';

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

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isLoading = false;

  int get _lastPageIndex =>
      OnboardingData.items.length - 1;

  bool get _isLastPage =>
      _currentPage == _lastPageIndex;

  void _changePage(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _nextPage() async {
    if (_isLastPage) {
      await _finishOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skipOnboarding() async {
    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await LocalStorageService.completeOnboarding();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
          (route) => false,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
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
            (screenWidth * 0.06)
                .clamp(20.0, 36.0)
                .toDouble();

            final illustrationSize =
            (screenWidth * 0.58)
                .clamp(185.0, 280.0)
                .toDouble();

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: (screenHeight * 0.015)
                        .clamp(8.0, 16.0)
                        .toDouble(),
                  ),

                  _TopSection(
                    currentPage: _currentPage,
                    totalPages: OnboardingData.items.length,
                    onSkip: _skipOnboarding,
                  ),

                  SizedBox(
                    height: (screenHeight * 0.02)
                        .clamp(10.0, 18.0)
                        .toDouble(),
                  ),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: OnboardingData.items.length,
                      onPageChanged: _changePage,
                      itemBuilder: (context, index) {
                        return _OnboardingPage(
                          item: OnboardingData.items[index],
                          illustrationSize: illustrationSize,
                          screenHeight: screenHeight,
                        );
                      },
                    ),
                  ),

                  _BottomSection(
                    currentPage: _currentPage,
                    totalPages: OnboardingData.items.length,
                    isLastPage: _isLastPage,
                    isLoading: _isLoading,
                    onPressed: _nextPage,
                  ),

                  SizedBox(
                    height: (screenHeight * 0.025)
                        .clamp(16.0, 26.0)
                        .toDouble(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;

  const _TopSection({
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              totalPages,
                  (index) {
                final isSelected = index == currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isSelected ? 26 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),

          Positioned(
            right: 0,
            child: TextButton(
              onPressed: onSkip,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final double illustrationSize;
  final double screenHeight;

  const _OnboardingPage({
    required this.item,
    required this.illustrationSize,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: (screenHeight * 0.035)
                .clamp(16.0, 35.0)
                .toDouble(),
          ),

          OnboardingIllustration(
            item: item,
            size: illustrationSize,
          ),

          SizedBox(
            height: (screenHeight * 0.055)
                .clamp(26.0, 48.0)
                .toDouble(),
          ),

          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: MediaQuery.sizeOf(context).width < 360
                  ? 25
                  : 29,
              height: 1.20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),

          const SizedBox(height: 16),

          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.65,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLastPage;
  final bool isLoading;
  final VoidCallback onPressed;

  const _BottomSection({
    required this.currentPage,
    required this.totalPages,
    required this.isLastPage,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: isLastPage
              ? 'Get Started'
              : 'Continue to next page',
          child: FilledButton(
            onPressed: isLoading ? null : onPressed,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? const SizedBox(
                key: ValueKey('loading'),
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Row(
                key: ValueKey(isLastPage),
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(
                    isLastPage
                        ? 'Get Started'
                        : 'Continue',
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastPage
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          '${currentPage + 1} of $totalPages',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}