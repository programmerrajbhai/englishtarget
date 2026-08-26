import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../data/batches/rule_config.dart';
import '../models/rule_item.dart';
import '../models/rule_progress.dart';
import '../models/rules_data.dart';
import '../repositories/rules_repository.dart';
import '../services/rules_progress_service.dart';
import 'rule_details_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();

  Map<String, RuleProgress> _progressMap = const {};
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;

  List<String> get _orderedRuleIds =>
      RulesData.rules.map((rule) => rule.id).toList(growable: false);

  List<RuleItem> get _filteredRules {
    final query = _searchQuery.trim().toLowerCase();

    return RulesData.rules.where((rule) {
      final matchesCategory = _selectedCategory == 'All' ||
          rule.category == _selectedCategory;
      final matchesSearch = query.isEmpty ||
          rule.title.toLowerCase().contains(query) ||
          rule.shortMeaning.toLowerCase().contains(query) ||
          rule.explanation.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList(growable: false);
  }

  int get _completedRulesCount => RulesData.rules.where((rule) {
    return (_progressMap[rule.id] ?? const RuleProgress()).isCompleted;
  }).length;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await RulesProgressService.loadAllProgress();

    if (!mounted) return;

    setState(() {
      _progressMap = progress;
      _isLoading = false;
    });
  }

  bool _isRuleUnlocked(RuleItem rule) {
    if (RuleConfig.unlockAllForTesting) {
      // যেসব Rule-এর content আছে, শুধু সেগুলো test-এর জন্য unlock হবে।
      return RulesRepository.findById(rule.id) != null;
    }

    final int ruleIndex = RulesData.rules.indexWhere(
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
      _showMessage('আগের Rule-এর Learn, Test ও Speaking সম্পূর্ণ করুন।');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
            (constraints.maxWidth * 0.05).clamp(18.0, 32.0).toDouble();
            final columnCount = constraints.maxWidth >= 980
                ? 3
                : constraints.maxWidth >= 650
                ? 2
                : 1;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
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
                          ),
                          const SizedBox(height: 18),
                          _ProgressSummary(
                            completed: _completedRulesCount,
                            total: RulesData.rules.length,
                          ),
                          const SizedBox(height: 15),
                          _SearchBox(
                            controller: _searchController,
                            query: _searchQuery,
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            onClear: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
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
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = RulesData.categories[index];

                          return _CategoryChip(
                            label: category,
                            selected: category == _selectedCategory,
                            onTap: () {
                              setState(() => _selectedCategory = category);
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
                            : GridView.builder(
                          physics:
                          const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            2,
                            horizontalPadding,
                            28,
                          ),
                          itemCount: _filteredRules.length,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columnCount,
                            mainAxisSpacing: 11,
                            crossAxisSpacing: 11,
                            mainAxisExtent: 104,
                          ),
                          itemBuilder: (context, index) {
                            final rule = _filteredRules[index];
                            final progress =
                                _progressMap[rule.id] ??
                                    const RuleProgress();
                            final isUnlocked =
                            _isRuleUnlocked(rule);

                            return _RuleTile(
                              rule: rule,
                              progress: progress,
                              isUnlocked: isUnlocked,
                              onTap: () =>
                                  _openRule(rule, isUnlocked),
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

class _Header extends StatelessWidget {
  final bool showBackButton;
  final int completedRules;

  const _Header({
    required this.showBackButton,
    required this.completedRules,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton) ...[
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFDDA2)),
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
                '$completedRules',
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
    final value = total == 0 ? 0.0 : completed / total;

    return Container(
      height: 99,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF2FBF6), Color(0xFFE9F8F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBE8D9)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 67,
            height: 67,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFFD5EADF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  '$completed',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 23,
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
                  'rules learned',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completed of $total completed',
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(18),
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
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.navy,
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
    if (!isUnlocked) return 'Locked';
    if (progress.isCompleted) return 'Done';
    if (progress.isStarted) return 'Continue';
    return 'Start';
  }

  IconData get _statusIcon {
    if (!isUnlocked) return Icons.lock_rounded;
    if (progress.isCompleted) return Icons.check_rounded;
    return Icons.arrow_forward_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = isUnlocked ? AppColors.primary : const Color(0xFF98A2B3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0xFFF3FBF7) : const Color(0xFFF6F7F7),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isUnlocked
                  ? const Color(0xFFCBE7D8)
                  : const Color(0xFFE3E6E5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: isUnlocked
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                      : null,
                ),
                child: Icon(
                  isUnlocked ? rule.icon : Icons.lock_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isUnlocked
                            ? AppColors.navy
                            : AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: isUnlocked ? progress.progress : 0,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFDCEAE3),
                        valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 11),
              Container(
                constraints: const BoxConstraints(minWidth: 76),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: progress.isCompleted && isUnlocked
                      ? AppColors.primary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: activeColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _statusIcon,
                      size: 15,
                      color: progress.isCompleted && isUnlocked
                          ? Colors.white
                          : activeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _buttonText,
                      style: TextStyle(
                        color: progress.isCompleted && isUnlocked
                            ? Colors.white
                            : activeColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
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
