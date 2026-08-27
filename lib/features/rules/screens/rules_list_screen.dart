import 'package:flutter/material.dart';

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

  return raw
      .split('_')
      .map((String word) {
    if (word.isEmpty) {
      return word;
    }

    return '${word[0].toUpperCase()}'
        '${word.substring(1)}';
  })
      .join(' ');
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

  final TextEditingController _searchController =
  TextEditingController();

  Map<String, RuleProgress> _progressMap =
  const <String, RuleProgress>{};

  String _selectedCategory = 'All';
  String _selectedLevel = _allLevels;
  String _searchQuery = '';
  bool _isLoading = true;

  List<String> get _orderedRuleIds {
    return RulesData.rules
        .map((RuleItem rule) => rule.id)
        .toList(growable: false);
  }

  List<RuleItem> get _filteredRules {
    final String query = _searchQuery.trim().toLowerCase();

    return RulesData.rules.where((RuleItem rule) {
      final bool matchesCategory = _selectedCategory == 'All' ||
          rule.category == _selectedCategory;

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
    final Map<RuleLevel, List<RuleItem>> grouped =
    <RuleLevel, List<RuleItem>>{
      for (final RuleLevel level in RuleLevel.values)
        level: <RuleItem>[],
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

    if (!mounted) {
      return;
    }

    setState(() {
      _progressMap = progress;
      _isLoading = false;
    });
  }

  bool _isRuleUnlocked(RuleItem rule) {
    if (RuleConfig.unlockAllForTesting) {
      return RulesRepository.findById(rule.id) != null;
    }

    final int ruleIndex = RulesData.rules.indexWhere(
          (RuleItem item) => item.id == rule.id,
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
      _showMessage(
        'আগের Rule-এর Learn, Test ও Speaking সম্পূর্ণ করুন।',
      );
      return;
    }

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

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
          isError ? AppColors.error : AppColors.navy,
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

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding =
    (MediaQuery.of(context).size.width * 0.05)
        .clamp(18.0, 30.0)
        .toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
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
                  _Header(
                    showBackButton: widget.showBackButton,
                    completedRules: _completedRulesCount,
                    totalRules: RulesData.rules.length,
                  ),
                  const SizedBox(height: 18),
                  _ProgressSummary(
                    completed: _completedRulesCount,
                    total: RulesData.rules.length,
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 14),
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
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 39,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                itemCount: RulesData.categories.length,
                separatorBuilder: (_, _) {
                  return const SizedBox(width: 8);
                },
                itemBuilder: (BuildContext context, int index) {
                  final String category =
                  RulesData.categories[index];

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
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
                  : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadProgress,
                child: _filteredRules.isEmpty
                    ? const _EmptyState()
                    : _RulesGroupedList(
                  levels: _visibleLevels,
                  groupedRules: _groupedRules,
                  progressMap: _progressMap,
                  isRuleUnlocked: _isRuleUnlocked,
                  onRuleTap: _openRule,
                  horizontalPadding:
                  horizontalPadding,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulesGroupedList extends StatelessWidget {
  final List<RuleLevel> levels;
  final Map<RuleLevel, List<RuleItem>> groupedRules;
  final Map<String, RuleProgress> progressMap;
  final bool Function(RuleItem rule) isRuleUnlocked;
  final Future<void> Function(
      RuleItem rule,
      bool isUnlocked,
      ) onRuleTap;
  final double horizontalPadding;

  const _RulesGroupedList({
    required this.levels,
    required this.groupedRules,
    required this.progressMap,
    required this.isRuleUnlocked,
    required this.onRuleTap,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        2,
        horizontalPadding,
        30,
      ),
      children: [
        for (final RuleLevel level in levels) ...[
          _LevelSectionHeader(
            level: level,
            rules: groupedRules[level]!,
            progressMap: progressMap,
          ),
          const SizedBox(height: 10),
          for (final RuleItem rule in groupedRules[level]!)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: _RuleTile(
                rule: rule,
                progress:
                progressMap[rule.id] ?? const RuleProgress(),
                isUnlocked: isRuleUnlocked(rule),
                onTap: () {
                  onRuleTap(
                    rule,
                    isRuleUnlocked(rule),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

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
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
            color: AppColors.navy,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFDDA2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.amber,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                '$completedRules/$totalRules',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
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

class _ProgressSummary extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressSummary({
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double value =
    total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);

    final int percentage = (value * 100).round();

    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF2FBF6),
            Color(0xFFE7F8EF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFCBE8D9),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFFD5EADF),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your learning journey',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$completed of $total rules completed',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColors.primary,
              size: 27,
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
      return (progressMap[rule.id] ?? const RuleProgress())
          .isCompleted;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: RuleLevel.values.length + 1,
        separatorBuilder: (_, _) {
          return const SizedBox(width: 9);
        },
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

          final List<RuleItem> levelRules = rules
              .where((RuleItem rule) => rule.level == level)
              .toList(growable: false);

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
      width: 142,
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
      width: 142,
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
      duration: const Duration(milliseconds: 220),
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected ? color : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color : AppColors.border,
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? [
          BoxShadow(
            color: color.withAlpha(35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withAlpha(38)
                      : color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : color,
                  size: 19,
                ),
              ),
              const SizedBox(width: 8),
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
                        color: selected
                            ? Colors.white
                            : AppColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? Colors.white.withAlpha(220)
                            : AppColors.textSecondary,
                        fontSize: 10,
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
      return (progressMap[rule.id] ?? const RuleProgress())
          .isCompleted;
    }).length;

    final double progress =
    rules.isEmpty ? 0 : completed / rules.length;

    final Color color = _levelColor(level);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withAlpha(14),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withAlpha(45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withAlpha(28),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _levelIcon(level),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _levelTitle(level),
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _levelSubtitle(level),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: color.withAlpha(30),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$completed/${rules.length}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
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
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search rules',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.navy,
            size: 22,
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
            onPressed: onClear,
            icon: const Icon(
              Icons.close_rounded,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(
            color: AppColors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border({
    Color color = AppColors.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
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
          color: selected
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 8,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : AppColors.navy,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
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
    if (!isUnlocked) {
      return 'Locked';
    }

    if (progress.isCompleted) {
      return 'Done';
    }

    if (progress.isStarted) {
      return 'Continue';
    }

    return 'Start';
  }

  IconData get _statusIcon {
    if (!isUnlocked) {
      return Icons.lock_rounded;
    }

    if (progress.isCompleted) {
      return Icons.check_rounded;
    }

    return Icons.arrow_forward_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = isUnlocked
        ? rule.color
        : const Color(0xFF98A2B3);

    final bool completed =
        progress.isCompleted && isUnlocked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isUnlocked
                ? rule.color.withAlpha(12)
                : const Color(0xFFF6F7F7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnlocked
                  ? rule.color.withAlpha(55)
                  : const Color(0xFFE3E6E5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? rule.color.withAlpha(25)
                      : const Color(0xFFE9ECEF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: activeColor.withAlpha(75),
                  ),
                ),
                child: Icon(
                  isUnlocked
                      ? rule.icon
                      : Icons.lock_rounded,
                  color: activeColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isUnlocked
                            ? AppColors.navy
                            : AppColors.textSecondary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rule.shortMeaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: isUnlocked
                            ? progress.progress
                            : 0,
                        minHeight: 5,
                        backgroundColor:
                        activeColor.withAlpha(22),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          activeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: completed
                      ? activeColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: activeColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      _statusIcon,
                      size: 15,
                      color: completed
                          ? Colors.white
                          : activeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _buttonText,
                      style: TextStyle(
                        color: completed
                            ? Colors.white
                            : activeColor,
                        fontSize: 11,
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 90),
        Icon(
          Icons.search_off_rounded,
          size: 58,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 12),
        Text(
          'কোনো Rule পাওয়া যায়নি',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}