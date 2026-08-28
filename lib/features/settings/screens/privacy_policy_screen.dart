import 'package:flutter/material.dart';

import 'settings_info_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsInfoScreen(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_rounded,
      sections: <SettingsInfoSection>[
        SettingsInfoSection(
          title: 'English Target',
          body:
          'This Privacy Policy explains how English Target uses information while you use the app.',
        ),
        SettingsInfoSection(
          title: 'Learning Data',
          body:
          'Your XP, streak, completed lessons and practice progress are stored to provide your learning experience.',
        ),
        SettingsInfoSection(
          title: 'Microphone',
          body:
          'Microphone access is used only when you start a speaking practice activity. Add your exact speech-processing details here before publishing.',
        ),
        SettingsInfoSection(
          title: 'Gallery',
          body:
          'Gallery access is used only when you choose to save your progress card. English Target does not save images without your action.',
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