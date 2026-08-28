import 'package:flutter/material.dart';

import 'settings_info_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsInfoScreen(
      title: 'Help & Support',
      icon: Icons.support_agent_rounded,
      sections: <SettingsInfoSection>[
        SettingsInfoSection(
          title: 'Need help?',
          body:
          'If something is not working, restart the app and try again. For technical support, contact the official English Target support email.',
        ),
        SettingsInfoSection(
          title: 'Support Email',
          body:
          'Replace this line with your official organization support email before publishing.',
        ),
        SettingsInfoSection(
          title: 'App Feedback',
          body:
          'Please include your device model, Android version and a screenshot when reporting a problem.',
        ),
      ],
    );
  }
}