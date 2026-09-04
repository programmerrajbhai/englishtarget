import 'package:flutter/material.dart';

import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../data/batches/rule_config.dart';
import '../models/rule_item.dart';
import '../models/rule_progress.dart';
import '../models/rules_data.dart';
import '../repositories/rules_repository.dart';
import '../services/rules_progress_service.dart';
import 'rule_details_screen.dart';

String _rawLevelName(RuleLevel level) {
  return level.toString().split('.').last.toLowerCase();
}

String _levelTitle(RuleLevel level) {
  final String raw = _rawLevelName(level);
  return raw.split('_').map((String word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }).join(' ');
}

String _levelSubtitle(RuleLevel level) {
  switch (_rawLevelName(level)) {
    case 'beginner':
      return 'Start from the basics';
    case 'basic':
      return 'Build strong grammar';
    case 'speaking':
      return 'Speak with confidence';
    case 'intermediate':
      return 'Improve your sentence skills';
    case 'advanced':
      return 'Master English confidently';
    default:
      return 'Learn this level step by step';
  }
}

IconData _levelIcon(RuleLevel level) {
  final int index = RuleLevel.values.indexOf(level);
  switch (index) {
    case 0:
      return Icons.flag_rounded;
    case 1:
      return Icons.school_rounded;
    case 2:
      return Icons.record_voice_over_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}

Color _levelColor(RuleLevel level) {
  final int index = RuleLevel.values.indexOf(level);
  switch (index) {
    case 0:
      return AppColors.primary;
    case 1:
      return AppColors.blue;
    case 2:
      return AppColors.purple;
    default:
      return AppColors.amber;
  }
}

class RulesListScreen extends StatefulWidget {
  final bool showBackButton;

  const RulesListScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<RulesListScreen> createState() => _RulesListScreenState();
}

class _RulesListScreenState extends State<RulesListScreen> {
  static const String _allLevels = 'All Levels';

  final TextEditingController _searchController = TextEditingController();

  Map<String, RuleProgress> _progressMap = const <String, RuleProgress>{};

  String _selectedCategory = 'All';
  String _selectedLevel = _allLevels;
  String _searchQuery = '';
  bool _isLoading = true;

  List<String> get _orderedRuleIds {
    return RulesData.rules.map((RuleItem rule) => rule.id).toList(growable: false);
  }

  List<RuleItem> get _filteredRules {
    final String query = _searchQuery.trim().toLowerCase();

    return RulesData.rules.where((RuleItem rule) {
      final bool matchesCategory =
          _selectedCategory == 'All' || rule.category == _selectedCategory;

      final bool matchesLevel = _selectedLevel == _allLevels ||
          _levelTitle(rule.level) == _selectedLevel;

      final bool matchesSearch = query.isEmpty ||
          rule.title.toLowerCase().contains(query) ||
          rule.shortMeaning.toLowerCase().contains(query) ||
          rule.explanation.toLowerCase().contains(query);

      return matchesCategory && matchesLevel && matchesSearch;
    }).toList(growable: false);
  }

  Map<RuleLevel, List<RuleItem>> get _groupedRules {
    final Map<RuleLevel, List<RuleItem>> grouped = <RuleLevel, List<RuleItem>>{
      for (final RuleLevel level in RuleLevel.values) level: <RuleItem>[],
    };

    for (final RuleItem rule in _filteredRules) {
      grouped[rule.level]!.add(rule);
    }
    return grouped;
  }

  List<RuleLevel> get _visibleLevels {
    final Map<RuleLevel, List<RuleItem>> grouped = _groupedRules;
    return RuleLevel.values.where((RuleLevel level) {
      return grouped[level]!.isNotEmpty;
    }).toList(growable: false);
  }

  int get _completedRulesCount {
    return RulesData.rules.where((RuleItem rule) {
      return (_progressMap[rule.id] ?? const RuleProgress()).isCompleted;
    }).length;
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final Map<String, RuleProgress> progress =
    await RulesProgressService.loadAllProgress();

    if (!mounted) return;

    setState(() {
      _progressMap = progress;
      _isLoading = false;
    });
  }

  // ALL TIME UNLOCKED LOGIC
  bool _isRuleUnlocked(RuleItem rule) {
    return true;
  }

  Future<void> _openRule(RuleItem rule, bool isUnlocked) async {
    final content = RulesRepository.findById(rule.id);

    if (content == null) {
      _showMessage(
        'এই Rule-এর lesson content এখনো যোগ করা হয়নি।',
        isError: true,
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RuleDetailsScreen(rule: content),
      ),
    );

    await _loadProgress();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.error : AppColors.navy,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Generates flat list of widgets to avoid nested list scrolling issues
  List<Widget> _buildRuleListItems() {
    final List<Widget> items = [];

    for (final RuleLevel level in _visibleLevels) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: _LevelSectionHeader(
            level: level,
            rules: _groupedRules[level]!,
            progressMap: _progressMap,
          ),
        ),
      );

      for (final RuleItem rule in _groupedRules[level]!) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RuleTile(
              rule: rule,
              progress: _progressMap[rule.id] ?? const RuleProgress(),
              isUnlocked: _isRuleUnlocked(rule),
              onTap: () => _openRule(rule, _isRuleUnlocked(rule)),
            ),
          ),
        );
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = (MediaQuery.of(context).size.width * 0.045).clamp(16.0, 34.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Premium off-white background
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- STICKY BANNER AD START ---
            // এটি স্ক্রিনের ওপরে ফিক্সড থাকবে, স্ক্রল করলে চলে যাবে না।
            // const ব্যবহারের ফলে পারফরম্যান্স ড্রপ বা ল্যাগ হবে না।
            const BannerAdWidget(),
            // --- STICKY BANNER AD END ---

            // --- SCROLLABLE CONTENT ---
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadProgress,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // 1. TOP HEADER & FILTERS
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                          horizontalPadding, 16, horizontalPadding, 0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _Header(
                            showBackButton: widget.showBackButton,
                            completedRules: _completedRulesCount,
                            totalRules: RulesData.rules.length,
                          ),
                          const SizedBox(height: 24),
                          _ProgressSummary(
                            completed: _completedRulesCount,
                            total: RulesData.rules.length,
                          ),
                          const SizedBox(height: 24),
                          _LevelSelector(
                            rules: RulesData.rules,
                            progressMap: _progressMap,
                            selectedLevel: _selectedLevel,
                            onSelected: (String value) {
                              setState(() {
                                _selectedLevel = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          _SearchBox(
                            controller: _searchController,
                            query: _searchQuery,
                            onChanged: (String value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            onClear: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),

                    // 2. HORIZONTAL CATEGORY CHIPS
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          itemCount: RulesData.categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (BuildContext context, int index) {
                            final String category = RulesData.categories[index];
                            return _CategoryChip(
                              label: category,
                              selected: category == _selectedCategory,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // 3. FLAT FULL-SCREEN RULE LIST
                    if (_isLoading)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      )
                    else if (_filteredRules.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                            horizontalPadding, 12, horizontalPadding, 40),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(_buildRuleListItems()),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PREMIUM UI COMPONENTS
// ==========================================

class _Header extends StatelessWidget {
  final bool showBackButton;
  final int completedRules;
  final int totalRules;

  const _Header({
    required this.showBackButton,
    required this.completedRules,
    required this.totalRules,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 12),
        ],
        const Expanded(
          child: Text(
            'Learn Rules',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.amber.withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.amber, size: 18),
              const SizedBox(width: 6),
              Text(
                '$completedRules/$totalRules',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressSummary({
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double value = total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);
    final int percentage = (value * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your learning journey',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completed of $total rules completed',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

class _LevelSelector extends StatelessWidget {
  final List<RuleItem> rules;
  final Map<String, RuleProgress> progressMap;
  final String selectedLevel;
  final ValueChanged<String> onSelected;

  const _LevelSelector({
    required this.rules,
    required this.progressMap,
    required this.selectedLevel,
    required this.onSelected,
  });

  int _completedFor(List<RuleItem> items) {
    return items.where((RuleItem rule) {
      return (progressMap[rule.id] ?? const RuleProgress()).isCompleted;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: RuleLevel.values.length + 1,
        clipBehavior: Clip.none,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            final int completed = _completedFor(rules);
            return _AllLevelCard(
              total: rules.length,
              completed: completed,
              selected: selectedLevel == 'All Levels',
              onTap: () => onSelected('All Levels'),
            );
          }
          final RuleLevel level = RuleLevel.values[index - 1];
          final List<RuleItem> levelRules =
          rules.where((RuleItem rule) => rule.level == level).toList(growable: false);

          return _LevelMiniCard(
            level: level,
            total: levelRules.length,
            completed: _completedFor(levelRules),
            selected: selectedLevel == _levelTitle(level),
            onTap: () => onSelected(_levelTitle(level)),
          );
        },
      ),
    );
  }
}

class _AllLevelCard extends StatelessWidget {
  final int total;
  final int completed;
  final bool selected;
  final VoidCallback onTap;

  const _AllLevelCard({
    required this.total,
    required this.completed,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SelectorCard(
      width: 155,
      color: AppColors.primary,
      selected: selected,
      onTap: onTap,
      icon: Icons.auto_awesome_rounded,
      title: 'All Levels',
      subtitle: '$completed/$total completed',
    );
  }
}

class _LevelMiniCard extends StatelessWidget {
  final RuleLevel level;
  final int total;
  final int completed;
  final bool selected;
  final VoidCallback onTap;

  const _LevelMiniCard({
    required this.level,
    required this.total,
    required this.completed,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SelectorCard(
      width: 155,
      color: _levelColor(level),
      selected: selected,
      onTap: onTap,
      icon: _levelIcon(level),
      title: _levelTitle(level),
      subtitle: '$completed/$total completed',
    );
  }
}

class _SelectorCard extends StatelessWidget {
  final double width;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  const _SelectorCard({
    required this.width,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? color : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: selected
            ? [
          BoxShadow(
            color: color.withAlpha(40),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ]
            : [
          BoxShadow(
            color: AppColors.navy.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withAlpha(40) : color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white.withAlpha(220) : AppColors.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelSectionHeader extends StatelessWidget {
  final RuleLevel level;
  final List<RuleItem> rules;
  final Map<String, RuleProgress> progressMap;

  const _LevelSectionHeader({
    required this.level,
    required this.rules,
    required this.progressMap,
  });

  @override
  Widget build(BuildContext context) {
    final int completed = rules.where((RuleItem rule) {
      return (progressMap[rule.id] ?? const RuleProgress()).isCompleted;
    }).length;

    final double progress = rules.isEmpty ? 0 : completed / rules.length;
    final Color color = _levelColor(level);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(40), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _levelIcon(level),
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _levelTitle(level),
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _levelSubtitle(level),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$completed/${rules.length}',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBox({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search rules...',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.navy,
            size: 24,
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 22),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color color = Colors.transparent, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.navy,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final RuleItem rule;
  final RuleProgress progress;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _RuleTile({
    required this.rule,
    required this.progress,
    required this.isUnlocked,
    required this.onTap,
  });

  String get _buttonText {
    if (progress.isCompleted) return 'Done';
    if (progress.isStarted) return 'Continue';
    return 'Start';
  }

  IconData get _statusIcon {
    if (progress.isCompleted) return Icons.check_circle_rounded;
    return Icons.play_arrow_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = rule.color;
    final bool completed = progress.isCompleted;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: activeColor.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: activeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    rule.icon,
                    color: activeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rule.shortMeaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress.progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  constraints: const BoxConstraints(minWidth: 80),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: completed ? activeColor : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: activeColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _statusIcon,
                        size: 16,
                        color: completed ? Colors.white : activeColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _buttonText,
                        style: TextStyle(
                          color: completed ? Colors.white : activeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(height: 80),
        Icon(
          Icons.search_off_rounded,
          size: 64,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 16),
        Text(
          'কোনো Rule পাওয়া যায়নি',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}