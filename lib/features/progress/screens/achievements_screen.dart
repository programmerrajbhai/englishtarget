import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import 'progress_screen.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final GlobalKey _posterKey = GlobalKey();

  late Future<LearningProgressSnapshot> _future;

  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _future = LearningProgressSnapshot.load();
  }

  Future<void> _refresh() async {
    final Future<LearningProgressSnapshot> future =
    LearningProgressSnapshot.load();

    setState(() {
      _future = future;
    });

    await future;
  }

  Future<Uint8List> _capturePoster() async {
    await WidgetsBinding.instance.endOfFrame;

    final BuildContext? context = _posterKey.currentContext;

    if (context == null) {
      throw StateError('Poster is not ready.');
    }

    final RenderObject? object = context.findRenderObject();

    if (object is! RenderRepaintBoundary) {
      throw StateError('Poster could not be captured.');
    }

    final ui.Image image = await object.toImage(pixelRatio: 3);

    try {
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw StateError('Image data is empty.');
      }

      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _shareProgress(
      LearningProgressSnapshot data,
      ) async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      final Uint8List bytes = await _capturePoster();

      final Directory cacheDirectory =
      await getTemporaryDirectory();

      final File imageFile = File(
        '${cacheDirectory.path}/english_target_progress.png',
      );

      await imageFile.writeAsBytes(
        bytes,
        flush: true,
      );

      await Share.shareXFiles(
        <XFile>[
          XFile(
            imageFile.path,
            mimeType: 'image/png',
          ),
        ],
        text:
        'I am learning with English Target! '
            '${data.xp} XP, Level ${data.level}.',
        subject: 'My English Target Progress',
      );
    } catch (error) {
      _showMessage(
        'Progress share করা যায়নি। আবার চেষ্টা করুন।',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }


  Future<void> _saveProgress() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      final Uint8List bytes = await _capturePoster();

      final Directory directory =
      await getTemporaryDirectory();

      final File imageFile = File(
        '${directory.path}/english_target_progress.png',
      );

      await imageFile.writeAsBytes(
        bytes,
        flush: true,
      );

      bool hasAccess = await Gal.hasAccess(
        toAlbum: true,
      );

      if (!hasAccess) {
        hasAccess = await Gal.requestAccess(
          toAlbum: true,
        );
      }

      if (!hasAccess) {
        _showMessage(
          'Gallery permission প্রয়োজন।',
        );
        return;
      }

      try {
        await Gal.putImage(
          imageFile.path,
          album: 'English Target',
        );
      } on GalException {
        await Gal.putImage(
          imageFile.path,
        );
      }

      _showMessage(
        'Progress card Gallery-তে save হয়েছে।',
      );
    } on GalException catch (error) {
      _showMessage(error.type.message);
    } catch (error) {
      _showMessage(
        'Image save করা যায়নি। আবার চেষ্টা করুন।',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<LearningProgressSnapshot>(
          future: _future,
          builder: (
              BuildContext context,
              AsyncSnapshot<LearningProgressSnapshot> snapshot,
              ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: FilledButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              );
            }

            final LearningProgressSnapshot data = snapshot.data!;
            final List<_Achievement> achievements =
            _createAchievements(data);

            final int unlocked = achievements
                .where((_Achievement item) => item.unlocked)
                .length;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  32,
                ),
                children: <Widget>[
                  _buildHeader(),
                  const SizedBox(height: 18),
                  RepaintBoundary(
                    key: _posterKey,
                    child: _ProgressPoster(
                      data: data,
                      unlocked: unlocked,
                      total: achievements.length,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButtons(data),
                  const SizedBox(height: 28),
                  _SectionTitle(
                    title: 'Your milestones',
                    subtitle:
                    '$unlocked of ${achievements.length} unlocked',
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 168,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: achievements.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 11),
                      itemBuilder: (
                          BuildContext context,
                          int index,
                          ) {
                        final _Achievement achievement =
                        achievements[index];

                        return _AchievementCard(
                          achievement: achievement,
                          onTap: () {
                            _showAchievement(achievement);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle(
                    title: 'Next goals',
                    subtitle: 'Keep improving every day',
                  ),
                  const SizedBox(height: 14),
                  ...achievements
                      .where((_Achievement item) => !item.unlocked)
                      .take(3)
                      .map(
                        (_Achievement item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _GoalCard(
                        achievement: item,
                        onTap: () {
                          _showAchievement(item);
                        },
                      ),
                    ),
                  ),
                  if (unlocked == achievements.length)
                    const _CompleteCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Achievements',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Turn your progress into a story worth sharing.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.mint,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withAlpha(40),
            ),
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.primary,
            size: 25,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      LearningProgressSnapshot data,
      ) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isBusy ? null : _saveProgress,
            icon: const Icon(
              Icons.download_rounded,
              size: 19,
            ),
            label: const Text('Save card'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: const BorderSide(
                color: AppColors.border,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: _isBusy
                ? null
                : () {
              _shareProgress(data);
            },
            icon: _isBusy
                ? const SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.ios_share_rounded,
              size: 18,
            ),
            label: Text(
              _isBusy ? 'Preparing...' : 'Share progress',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAchievement(_Achievement achievement) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            14,
            24,
            28,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              _AchievementIcon(
                achievement: achievement,
                size: 72,
              ),
              const SizedBox(height: 14),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                achievement.unlocked
                    ? 'Achievement unlocked! Keep going.'
                    : achievement.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              if (!achievement.unlocked)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 7,
                    backgroundColor:
                    achievement.color.withAlpha(25),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(
                      achievement.color,
                    ),
                  ),
                )
              else
                const Text(
                  'Unlocked ✓',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressPoster extends StatelessWidget {
  final LearningProgressSnapshot data;
  final int unlocked;
  final int total;

  const _ProgressPoster({
    required this.data,
    required this.unlocked,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage =
    (data.overallProgress * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        21,
        20,
        21,
        18,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.navy,
            Color(0xFF1A4260),
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withAlpha(45),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'ENGLISH TARGET',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'MY JOURNEY',
                style: TextStyle(
                  color: Colors.white.withAlpha(170),
                  fontSize: 9,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'I am becoming\nmore confident.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Small practice. Big progress.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 91,
                height: 91,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 91,
                      height: 91,
                      child: CircularProgressIndicator(
                        value: data.overallProgress,
                        strokeWidth: 8,
                        backgroundColor:
                        Colors.white.withAlpha(35),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(
                          Color(0xFF67E8B0),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'complete',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          Row(
            children: <Widget>[
              _PosterMetric(
                icon: Icons.bolt_rounded,
                value: '${data.xp}',
                label: 'XP earned',
                color: AppColors.amber,
              ),
              const _PosterDivider(),
              _PosterMetric(
                icon: Icons.local_fire_department_rounded,
                value: '${data.streak}',
                label: 'day streak',
                color: Color(0xFFFF8D58),
              ),
              const _PosterDivider(),
              _PosterMetric(
                icon: Icons.workspace_premium_rounded,
                value: '$unlocked/$total',
                label: 'badges',
                color: Color(0xFF9DEBC8),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.only(top: 13),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withAlpha(35),
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'LEVEL ${data.level}',
                  style: const TextStyle(
                    color: Color(0xFF9DEBC8),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  'english-target',
                  style: TextStyle(
                    color: Colors.white.withAlpha(145),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

class _PosterMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _PosterMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(170),
                    fontSize: 9,
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

class _PosterDivider extends StatelessWidget {
  const _PosterDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: Colors.white.withAlpha(38),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;
  final VoidCallback onTap;

  const _AchievementCard({
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? achievement.color.withAlpha(18)
                  : Colors.white,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: achievement.unlocked
                    ? achievement.color.withAlpha(70)
                    : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                _AchievementIcon(
                  achievement: achievement,
                  size: 49,
                ),
                const Spacer(),
                Text(
                  achievement.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.unlocked
                      ? 'Unlocked'
                      : '${(achievement.progress * 100).round()}% ready',
                  style: TextStyle(
                    color: achievement.unlocked
                        ? achievement.color
                        : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

class _AchievementIcon extends StatelessWidget {
  final _Achievement achievement;
  final double size;

  const _AchievementIcon({
    required this.achievement,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? achievement.color.withAlpha(32)
            : AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(
          color: achievement.unlocked
              ? achievement.color.withAlpha(80)
              : AppColors.border,
        ),
      ),
      child: Icon(
        achievement.unlocked
            ? achievement.icon
            : Icons.lock_rounded,
        color: achievement.unlocked
            ? achievement.color
            : AppColors.textSecondary,
        size: size * .46,
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final _Achievement achievement;
  final VoidCallback onTap;

  const _GoalCard({
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: <Widget>[
              _AchievementIcon(
                achievement: achievement,
                size: 45,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      achievement.title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: achievement.progress,
                        minHeight: 6,
                        backgroundColor:
                        achievement.color.withAlpha(22),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          achievement.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: achievement.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompleteCard extends StatelessWidget {
  const _CompleteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withAlpha(45),
        ),
      ),
      child: const Row(
        children: <Widget>[
          Icon(
            Icons.celebration_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Every milestone is unlocked. Amazing work!',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<_Achievement> _createAchievements(
    LearningProgressSnapshot data,
    ) {
  double ratio(int current, int target) {
    if (target <= 0) {
      return 0;
    }

    return (current / target).clamp(0.0, 1.0).toDouble();
  }

  return <_Achievement>[
    _Achievement(
      title: 'First Step',
      description: 'Complete your first learning unit',
      icon: Icons.flag_rounded,
      color: AppColors.primary,
      unlocked: data.completedUnits >= 1,
      progress: ratio(data.completedUnits, 1),
    ),
    _Achievement(
      title: 'Rule Learner',
      description: 'Complete 5 grammar rules',
      icon: Icons.menu_book_rounded,
      color: AppColors.blue,
      unlocked: data.completedRules >= 5,
      progress: ratio(data.completedRules, 5),
    ),
    _Achievement(
      title: 'Sentence Builder',
      description: 'Complete 5 sentence topics',
      icon: Icons.chat_bubble_rounded,
      color: AppColors.purple,
      unlocked: data.completedBasicTopics >= 5,
      progress: ratio(data.completedBasicTopics, 5),
    ),
    _Achievement(
      title: 'Question Maker',
      description: 'Complete 5 question topics',
      icon: Icons.quiz_rounded,
      color: AppColors.amber,
      unlocked: data.completedQuestionTopics >= 5,
      progress: ratio(data.completedQuestionTopics, 5),
    ),
    _Achievement(
      title: 'Daily Star',
      description: 'Complete today’s challenge',
      icon: Icons.emoji_events_rounded,
      color: Colors.orange,
      unlocked: data.dailyTotal > 0 &&
          data.dailyCompleted >= data.dailyTotal,
      progress: ratio(
        data.dailyCompleted,
        data.dailyTotal,
      ),
    ),
    _Achievement(
      title: '7 Day Streak',
      description: 'Maintain a 7 day learning streak',
      icon: Icons.local_fire_department_rounded,
      color: Colors.deepOrange,
      unlocked: data.streak >= 7,
      progress: ratio(data.streak, 7),
    ),
    _Achievement(
      title: 'XP Hunter',
      description: 'Earn 500 XP in English Target',
      icon: Icons.bolt_rounded,
      color: Colors.amber.shade700,
      unlocked: data.xp >= 500,
      progress: ratio(data.xp, 500),
    ),
  ];
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final double progress;

  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
    required this.progress,
  });
}