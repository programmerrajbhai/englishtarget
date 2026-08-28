import 'package:flutter/material.dart';

import 'settings_info_screen.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsInfoScreen(
      title: 'Terms of Use',
      icon: Icons.gavel_rounded,
      sections: <SettingsInfoSection>[
        SettingsInfoSection(
          title: 'Use of the App',
          body:
          'English Target is an educational application for learning English grammar, sentences and pronunciation.',
        ),
        SettingsInfoSection(
          title: 'Educational Content',
          body:
          'Learning content is provided for educational purposes. We do not guarantee a particular exam or language-learning result.',
        ),
        SettingsInfoSection(
          title: 'Acceptable Use',
          body:
          'You must not misuse the app, attempt to damage the service or use the content for unlawful purposes.',
        ),
        SettingsInfoSection(
          title: 'Changes',
          body:
          'We may update these Terms when the app or its features change.',
        ),
        SettingsInfoSection(
          title: 'Contact',
          body:
          'Replace this text with your organization legal name and official support email before publishing.',
        ),
      ],
    );
  }
}