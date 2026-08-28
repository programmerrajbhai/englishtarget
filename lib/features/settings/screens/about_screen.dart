import 'package:flutter/material.dart';

import 'settings_info_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsInfoScreen(
      title: 'About English Target',
      icon: Icons.school_rounded,
      sections: <SettingsInfoSection>[
        SettingsInfoSection(
          title: 'English Target',
          body:
          'Learn English through rules, real-life sentences, question making and daily challenges.',
        ),
        SettingsInfoSection(
          title: 'Version',
          body: 'Version 1.0.0',
        ),
        SettingsInfoSection(
          title: 'Developer',
          body:
          'Replace this text with your official organization name before publishing.',
        ),
        SettingsInfoSection(
          title: 'Open-source Licenses',
          body:
          'This app uses open-source Flutter packages. Their licenses are available through the Flutter license screen.',
        ),
      ],
    );
  }
}