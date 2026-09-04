import 'package:flutter/material.dart';

import '../../../core/ads/ad_manager.dart'; // <--- AD MANAGER IMPORT
import '../../../core/ads/banner_ad_widget.dart'; // <--- BANNER AD IMPORT
import '../../../core/constants/app_colors.dart';
import '../models/basic_sentence_topic.dart';

class BasicSentenceResultScreen extends StatelessWidget {
  final BasicSentenceTopic topic;
  final int total;
  final int correct;
  final int skipped;

  const BasicSentenceResultScreen({
    super.key,
    required this.topic,
    required this.total,
    required this.correct,
    required this.skipped,
  });

  @override
  Widget build(BuildContext context) {
    final int score = total == 0
        ? 0
        : ((correct / total) * 100)
        .round()
        .clamp(0, 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Practice complete'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- STICKY BANNER AD START ---
            const BannerAdWidget(),
            // --- STICKY BANNER AD END ---

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 18),
                    Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        color: topic.color.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: topic.color,
                          width: 7,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$score%',
                          style: TextStyle(
                            color: topic.color,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Great job!',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      topic.title,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: <Widget>[
                        _StatCard(
                          title: 'Correct',
                          value: '$correct',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          title: 'Skipped',
                          value: '$skipped',
                          color: AppColors.amber,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          title: 'Total',
                          value: '$total',
                          color: AppColors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: () {
                          // --- INTERSTITIAL AD TRIGGER ---
                          // সেশন শেষ করে ব্যাক করার সময় অ্যাড শো করবে
                          AdManager.instance.showInterstitialAd(
                            onAdDismissed: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        child: const Text('Back to topics'),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}