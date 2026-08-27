import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../basic_sentences/services/basic_sentence_xp_service.dart';

class XpBalancePill extends StatefulWidget {
  final bool compact;

  const XpBalancePill({
    super.key,
    this.compact = true,
  });

  @override
  State<XpBalancePill> createState() =>
      _XpBalancePillState();
}

class _XpBalancePillState
    extends State<XpBalancePill> {
  @override
  void initState() {
    super.initState();

    unawaited(
      BasicSentenceXpService.load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable:
      BasicSentenceXpService.totalXp,
      builder: (
          BuildContext context,
          int xp,
          Widget? child,
          ) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(18),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.green.withAlpha(70),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.primary,
                size: 19,
              ),
              const SizedBox(width: 4),
              Text(
                widget.compact ? '$xp' : '$xp XP',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}