import 'package:flutter/material.dart';

import '../data/app_legal_info.dart';
import 'settings_info_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openLicenses(BuildContext context) async {
    showLicensePage(
      context: context,
      applicationName: AppLegalInfo.appName,
      applicationVersion: AppLegalInfo.versionLabel,
      applicationLegalese: AppLegalInfo.copyright,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsInfoScreen(
      title: 'About English Target',
      subtitle: 'Learn, practise and build speaking confidence',
      icon: Icons.school_rounded,
      actionLabel: 'View Open-source Licenses',
      actionIcon: Icons.article_outlined,
      onAction: () => _openLicenses(context),
      sections: const <SettingsInfoSection>[
        SettingsInfoSection(
          title: AppLegalInfo.appName,
          icon: Icons.auto_stories_rounded,
          body:
              'English Target helps learners improve English '
              'through grammar rules, real-life sentences, '
              'question making, pronunciation practice and '
              'daily challenges.',
        ),
        SettingsInfoSection(
          title: 'Our purpose',
          icon: Icons.track_changes_rounded,
          body:
              'Our goal is to make English learning clear, '
              'practical and encouraging for learners who want '
              'to communicate with greater confidence.',
        ),
        SettingsInfoSection(
          title: 'Version',
          icon: Icons.info_outline_rounded,
          body: AppLegalInfo.versionLabel,
        ),
        SettingsInfoSection(
          title: 'Developed by',
          icon: Icons.business_rounded,
          body: AppLegalInfo.organizationName,
        ),
        SettingsInfoSection(
          title: 'Support',
          icon: Icons.email_outlined,
          body: AppLegalInfo.supportEmail,
        ),
        SettingsInfoSection(
          title: 'Open-source software',
          icon: Icons.code_rounded,
          body:
              'English Target uses Flutter and other '
              'open-source packages. Tap the button below to '
              'view the licenses included with the app.',
        ),
        SettingsInfoSection(
          title: 'Copyright',
          icon: Icons.copyright_rounded,
          body: AppLegalInfo.copyright,
        ),
      ],
    );
  }
}
