import 'package:englishtarget/features/rules/screens/rule_details_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

import '../models/rule_item.dart';
import '../models/rule_progress.dart';
import '../models/rules_data.dart';
import '../repositories/rules_repository.dart';
import '../services/rules_progress_service.dart';
import '../widgets/rule_card.dart';

class RulesListScreen extends StatefulWidget {
  final bool showBackButton;

  const RulesListScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<RulesListScreen> createState() =>
      _RulesListScreenState();
}

class _RulesListScreenState
    extends State<RulesListScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  bool _isLoading = true;

  Map<String, RuleProgress> _progressMap = {};
  final Set<String> _bookmarkedRules = {};

  List<String> get _orderedRuleIds {
    return RulesData.rules
        .map((rule) => rule.id)
        .toList(growable: false);
  }

  List<RuleItem> get _filteredRules {
    final query = _searchQuery.trim().toLowerCase();

    return RulesData.rules.where((rule) {
      final matchesCategory =
          _selectedCategory == 'All' ||
              rule.category == _selectedCategory;

      final matchesSearch =
          query.isEmpty ||
              rule.title.toLowerCase().contains(query) ||
              rule.shortMeaning
                  .toLowerCase()
                  .contains(query) ||
              rule.explanation
                  .toLowerCase()
                  .contains(query);

      return matchesCategory && matchesSearch;
    }).toList(growable: false);
  }

  int get _completedRulesCount {
    return RulesData.rules.where((rule) {
      final progress =
          _progressMap[rule.id] ??
              const RuleProgress();

      return progress.isCompleted;
    }).length;
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress =
    await RulesProgressService.loadAllProgress();

    if (!mounted) return;

    setState(() {
      _progressMap = progress;
      _isLoading = false;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _search(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  void _toggleBookmark(String ruleId) {
    setState(() {
      if (_bookmarkedRules.contains(ruleId)) {
        _bookmarkedRules.remove(ruleId);
      } else {
        _bookmarkedRules.add(ruleId);
      }
    });
  }

  bool _isRuleUnlocked(RuleItem rule) {
    final ruleIndex = RulesData.rules.indexWhere(
          (item) => item.id == rule.id,
    );

    return RulesProgressService.isRuleUnlocked(
      ruleIndex: ruleIndex,
      orderedRuleIds: _orderedRuleIds,
      progressMap: _progressMap,
    );
  }



  Future<void> _openRule(
      RuleItem rule,
      bool isUnlocked,
      ) async {
    if (!isUnlocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'আগের Rule সম্পূর্ণ করলে এটি unlock হবে।',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.navy,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

      return;
    }



    final ruleContent =
    RulesRepository.findById(rule.id);

    if (ruleContent == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'এই Rule-এর learning content এখনো add করা হয়নি।',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return RuleDetailsScreen(
            rule: ruleContent,
          );
        },
      ),
    );

    await _loadProgress();
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = (width * 0.055)
                .clamp(18.0, 38.0)
                .toDouble();

            final crossAxisCount = width >= 1000
                ? 3
                : width >= 650
                ? 2
                : 1;

            final cardHeight =
            width < 370 ? 178.0 : 170.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        14,
                        horizontalPadding,
                        0,
                      ),
                      child: Column(
                        children: [
                          _RulesHeader(
                            showBackButton:
                            widget.showBackButton,
                          ),

                          const SizedBox(height: 18),

                          _RealProgressSummary(
                            completed:
                            _completedRulesCount,
                            total: RulesData.rules.length,
                          ),

                          const SizedBox(height: 17),

                          _SearchField(
                            controller:
                            _searchController,
                            searchQuery: _searchQuery,
                            onChanged: _search,
                            onClear: _clearSearch,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 13),

                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection:
                        Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal:
                          horizontalPadding,
                        ),
                        itemCount:
                        RulesData.categories.length,
                        separatorBuilder: (_, _) =>
                        const SizedBox(width: 9),
                        itemBuilder: (context, index) {
                          final category =
                          RulesData.categories[index];

                          return _CategoryChip(
                            label: category,
                            isSelected: category ==
                                _selectedCategory,
                            onTap: () {
                              _selectCategory(category);
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 13),

                    Expanded(
                      child: _isLoading
                          ? const Center(
                        child:
                        CircularProgressIndicator(),
                      )
                          : RefreshIndicator(
                        onRefresh: _loadProgress,
                        color: AppColors.primary,
                        child: _filteredRules.isEmpty
                            ? const _EmptyRules()
                            : GridView.builder(
                          physics:
                          const AlwaysScrollableScrollPhysics(
                            parent:
                            BouncingScrollPhysics(),
                          ),
                          padding:
                          EdgeInsets.fromLTRB(
                            horizontalPadding,
                            3,
                            horizontalPadding,
                            28,
                          ),
                          itemCount:
                          _filteredRules.length,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                            crossAxisCount,
                            mainAxisSpacing: 13,
                            crossAxisSpacing: 13,
                            mainAxisExtent:
                            cardHeight,
                          ),
                          itemBuilder:
                              (context, index) {
                            final rule =
                            _filteredRules[index];

                            final progress =
                                _progressMap[
                                rule.id] ??
                                    const RuleProgress();

                            final isUnlocked =
                            _isRuleUnlocked(
                              rule,
                            );

                            return RuleCard(
                              rule: rule,
                              progress:
                              progress,
                              isUnlocked:
                              isUnlocked,
                              isBookmarked:
                              _bookmarkedRules
                                  .contains(
                                rule.id,
                              ),
                              onBookmark: () {
                                _toggleBookmark(
                                  rule.id,
                                );
                              },
                              onTap: () {
                                _openRule(
                                  rule,
                                  isUnlocked,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RulesHeader extends StatelessWidget {
  final bool showBackButton;

  const _RulesHeader({
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton) ...[
          IconButton.filledTonal(
            onPressed: () {
              Navigator.maybePop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 11),
        ],

        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Learn Rules',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '60 essential rules for spoken English',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RealProgressSummary extends StatelessWidget {
  final int completed;
  final int total;

  const _RealProgressSummary({
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
    total == 0 ? 0.0 : completed / total;

    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(45),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor:
                  Colors.white.withAlpha(50),
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your real progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$completed of $total rules completed',
                  style: TextStyle(
                    color:
                    Colors.white.withAlpha(205),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.amber,
            size: 27,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search rules...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: searchQuery.isEmpty
            ? null
            : IconButton(
          onPressed: onClear,
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  OutlineInputBorder _border({
    Color color = AppColors.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : AppColors.border,
      ),
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}

class _EmptyRules extends StatelessWidget {
  const _EmptyRules();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppColors.textSecondary,
            size: 60,
          ),
          SizedBox(height: 14),
          Text(
            'No rules found',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}