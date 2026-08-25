import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/rule_learning_controller.dart';
import '../models/rule_content.dart';

class RuleDetailsScreen extends StatefulWidget {
  final RuleContent rule;

  const RuleDetailsScreen({
    super.key,
    required this.rule,
  });

  @override
  State<RuleDetailsScreen> createState() =>
      _RuleDetailsScreenState();
}

class _RuleDetailsScreenState
    extends State<RuleDetailsScreen> {
  late final RuleLearningController _controller;

  final ScrollController _scrollController =
  ScrollController();

  bool _reachedExamplesEnd = false;

  @override
  void initState() {
    super.initState();

    _controller = RuleLearningController(
      ruleId: widget.rule.id,
    );

    _controller.addListener(_refreshScreen);
    _scrollController.addListener(_checkScrollPosition);

    _controller.initialize();
  }

  void _refreshScreen() {
    if (!mounted) return;
    setState(() {});
  }

  void _checkScrollPosition() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >=
        position.maxScrollExtent - 100) {
      if (!_reachedExamplesEnd) {
        setState(() {
          _reachedExamplesEnd = true;
        });
      }
    }
  }

  Future<void> _completeLearning() async {
    if (!_reachedExamplesEnd &&
        !_controller.progress.learnCompleted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'আগে সবগুলো example দেখে নিচে আসুন।',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.navy,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );

      return;
    }

    final completed =
    await _controller.completeLearning();

    if (!mounted) return;

    if (completed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Learning complete! Rule Test এখন unlock হয়েছে।',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
    }
  }

  void _openTest() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Rule Test Screen পরবর্তী ধাপে connect হবে।',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _controller.removeListener(_refreshScreen);
    _controller.dispose();

    _scrollController
      ..removeListener(_checkScrollPosition)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _controller.progress;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = (width * 0.055)
                .clamp(18.0, 38.0)
                .toDouble();

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    10,
                    horizontalPadding,
                    8,
                  ),
                  child: _DetailsHeader(
                    title: widget.rule.title,
                  ),
                ),

                _LearningStepBar(
                  learnCompleted:
                  progress.learnCompleted,
                  testCompleted:
                  progress.testCompleted,
                  speakingCompleted:
                  progress.speakingCompleted,
                ),

                Expanded(
                  child: _controller.isLoading &&
                      !progress.isStarted
                      ? const Center(
                    child:
                    CircularProgressIndicator(),
                  )
                      : Center(
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                        maxWidth: 850,
                      ),
                      child: CustomScrollView(
                        controller:
                        _scrollController,
                        physics:
                        const BouncingScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding:
                            EdgeInsets.fromLTRB(
                              horizontalPadding,
                              18,
                              horizontalPadding,
                              16,
                            ),
                            sliver: SliverList(
                              delegate:
                              SliverChildListDelegate(
                                [
                                  _RuleIntroductionCard(
                                    rule: widget.rule,
                                  ),

                                  const SizedBox(
                                    height: 16,
                                  ),

                                  _FormulaCard(
                                    formula:
                                    widget.rule.formula,
                                  ),

                                  if (widget.rule
                                      .keywords
                                      .isNotEmpty) ...[
                                    const SizedBox(
                                      height: 18,
                                    ),
                                    _KeywordsSection(
                                      keywords:
                                      widget.rule
                                          .keywords,
                                    ),
                                  ],

                                  const SizedBox(
                                    height: 27,
                                  ),

                                  _ExamplesHeader(
                                    exampleCount:
                                    widget.rule
                                        .examples
                                        .length,
                                  ),

                                  const SizedBox(
                                    height: 13,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SliverPadding(
                            padding:
                            EdgeInsets.symmetric(
                              horizontal:
                              horizontalPadding,
                            ),
                            sliver: SliverList.separated(
                              itemCount: widget
                                  .rule.examples.length,
                              separatorBuilder:
                                  (_, _) =>
                              const SizedBox(
                                height: 11,
                              ),
                              itemBuilder:
                                  (context, index) {
                                final example = widget
                                    .rule.examples[index];

                                return _ExampleCard(
                                  index: index,
                                  example: example,
                                  color:
                                  widget.rule.color,
                                );
                              },
                            ),
                          ),

                          SliverPadding(
                            padding:
                            EdgeInsets.fromLTRB(
                              horizontalPadding,
                              22,
                              horizontalPadding,
                              30,
                            ),
                            sliver:
                            SliverToBoxAdapter(
                              child:
                              _LearningCompletionCard(
                                isCompleted: progress
                                    .learnCompleted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                _BottomActionArea(
                  isLoading: _controller.isLoading,
                  isLearningCompleted:
                  progress.learnCompleted,
                  onCompleteLearning:
                  _completeLearning,
                  onOpenTest: _openTest,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  final String title;

  const _DetailsHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () {
            Navigator.pop(context);
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.navy,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 17,
              ),
              SizedBox(width: 5),
              Text(
                'Learn',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LearningStepBar extends StatelessWidget {
  final bool learnCompleted;
  final bool testCompleted;
  final bool speakingCompleted;

  const _LearningStepBar({
    required this.learnCompleted,
    required this.testCompleted,
    required this.speakingCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        22,
        10,
        22,
        13,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          _StepItem(
            label: 'Learn',
            icon: Icons.menu_book_rounded,
            isCompleted: learnCompleted,
            isActive: !learnCompleted,
          ),

          _StepLine(
            isCompleted: learnCompleted,
          ),

          _StepItem(
            label: 'Test',
            icon: Icons.quiz_rounded,
            isCompleted: testCompleted,
            isActive:
            learnCompleted && !testCompleted,
          ),

          _StepLine(
            isCompleted: testCompleted,
          ),

          _StepItem(
            label: 'Speak',
            icon: Icons.mic_rounded,
            isCompleted: speakingCompleted,
            isActive:
            testCompleted && !speakingCompleted,
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  const _StepItem({
    required this.label,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isActive
        ? AppColors.primary
        : AppColors.textSecondary;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primary
                : isActive
                ? AppColors.mint
                : const Color(0xFFF0F2F1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted
                ? Icons.check_rounded
                : icon,
            color:
            isCompleted ? Colors.white : color,
            size: 17,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isCompleted;

  const _StepLine({
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.fromLTRB(
          7,
          0,
          7,
          17,
        ),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.primary
              : AppColors.border,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _RuleIntroductionCard extends StatelessWidget {
  final RuleContent rule;

  const _RuleIntroductionCard({
    required this.rule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rule.color.withAlpha(25),
            rule.color.withAlpha(8),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: rule.color.withAlpha(45),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: rule.color,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  rule.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.shortMeaning,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 17,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      rule.category,
                      style: TextStyle(
                        color: rule.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'কোথায় ব্যবহার হয়?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            rule.usage,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaCard extends StatelessWidget {
  final String formula;

  const _FormulaCard({
    required this.formula,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(22),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: AppColors.amber,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Sentence Structure',
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  formula,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordsSection extends StatelessWidget {
  final List<String> keywords;

  const _KeywordsSection({
    required this.keywords,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Important words',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 11),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((keyword) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.primary.withAlpha(30),
                ),
              ),
              child: Text(
                keyword,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ExamplesHeader extends StatelessWidget {
  final int exampleCount;

  const _ExamplesHeader({
    required this.exampleCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Examples',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'বাংলা পড়ে English sentence বুঝুন',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '$exampleCount examples',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final int index;
  final RuleExample example;
  final Color color;

  const _ExampleCard({
    required this.index,
    required this.example,
    required this.color,
  });

  String get _typeLabel {
    switch (example.type) {
      case RuleExampleType.simple:
        return 'Simple';
      case RuleExampleType.positive:
        return 'Positive';
      case RuleExampleType.negative:
        return 'Negative';
      case RuleExampleType.question:
        return 'Question';
      case RuleExampleType.conversation:
        return 'Conversation';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  example.bengali,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  example.english,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(14),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    _typeLabel,
                    style: TextStyle(
                      color: color,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCompletionCard
    extends StatelessWidget {
  final bool isCompleted;

  const _LearningCompletionCard({
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.mint
            : AppColors.amber.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withAlpha(45)
              : AppColors.amber.withAlpha(55),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.lightbulb_rounded,
            color: isCompleted
                ? AppColors.primary
                : AppColors.amber,
            size: 27,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              isCompleted
                  ? 'Learning section complete হয়েছে। এখন Rule Test দিন।'
                  : 'সব example বুঝে পড়ার পর নিচের Complete Learning button চাপুন।',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionArea extends StatelessWidget {
  final bool isLoading;
  final bool isLearningCompleted;
  final VoidCallback onCompleteLearning;
  final VoidCallback onOpenTest;

  const _BottomActionArea({
    required this.isLoading,
    required this.isLearningCompleted,
    required this.onCompleteLearning,
    required this.onOpenTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: isLoading
              ? null
              : isLearningCompleted
              ? onOpenTest
              : onCompleteLearning,
          child: isLoading
              ? const SizedBox(
            width: 23,
            height: 23,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                isLearningCompleted
                    ? Icons.quiz_rounded
                    : Icons.check_circle_rounded,
              ),
              const SizedBox(width: 8),
              Text(
                isLearningCompleted
                    ? 'Take Rule Test'
                    : 'Complete Learning',
              ),
            ],
          ),
        ),
      ),
    );
  }
}