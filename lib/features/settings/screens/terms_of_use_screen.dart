import 'package:flutter/material.dart';

import '../data/app_legal_info.dart';
import 'settings_info_screen.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsInfoScreen(
      title: 'Terms of Use',
      subtitle: 'Rules and conditions for using English Target',
      icon: Icons.gavel_rounded,
      sections: <SettingsInfoSection>[
        SettingsInfoSection(
          title: 'Acceptance',
          icon: Icons.check_circle_outline_rounded,
          body:
              'Effective date: ${AppLegalInfo.effectiveDate}\n\n'
              'By downloading or using '
              '${AppLegalInfo.appName}, you agree to these '
              'Terms of Use. If you do not agree, you should '
              'stop using the app.',
        ),
        SettingsInfoSection(
          title: 'Educational purpose',
          icon: Icons.school_outlined,
          body:
              '${AppLegalInfo.appName} provides English '
              'grammar, sentences, question-making, speaking '
              'practice and daily learning challenges. The '
              'content is provided for general educational '
              'purposes.',
        ),
        SettingsInfoSection(
          title: 'No guaranteed result',
          icon: Icons.fact_check_outlined,
          body:
              'Learning results depend on practice, ability '
              'and other personal factors. We do not guarantee '
              'a particular examination score, employment '
              'result, fluency level or learning outcome.',
        ),
        SettingsInfoSection(
          title: 'Permission-based features',
          icon: Icons.admin_panel_settings_outlined,
          body:
              'Speaking activities require optional microphone '
              'permission. Saving a progress card may require '
              'access to device media storage on supported '
              'Android versions. You may decline optional '
              'permissions, but the related feature may not '
              'work.',
        ),
        SettingsInfoSection(
          title: 'Acceptable use',
          icon: Icons.verified_user_outlined,
          body:
              'You must not misuse the app, interfere with its '
              'operation, attempt unauthorized access, reverse '
              'engineer protected parts of the application, '
              'distribute malicious code or use the app for '
              'unlawful activities.',
        ),
        SettingsInfoSection(
          title: 'Intellectual property',
          icon: Icons.copyright_rounded,
          body:
              'The English Target name, original design, '
              'learning structure, branding and original '
              'content belong to '
              '${AppLegalInfo.organizationName} unless '
              'otherwise stated. Open-source packages remain '
              'subject to their respective licenses.',
        ),
        SettingsInfoSection(
          title: 'Third-party services',
          icon: Icons.extension_outlined,
          body:
              'Some features depend on services available on '
              'your device, including speech recognition, '
              'text-to-speech, email and sharing applications. '
              'Their availability and processing are governed '
              'by their respective providers.',
        ),
        SettingsInfoSection(
          title: 'Availability and updates',
          icon: Icons.system_update_alt_rounded,
          body:
              'We may improve, modify, suspend or remove app '
              'features when reasonably necessary. Certain '
              'features may vary according to device, Android '
              'version, language or installed service.',
        ),
        SettingsInfoSection(
          title: 'Disclaimer',
          icon: Icons.info_outline_rounded,
          body:
              'The app is provided on an “as available” basis. '
              'To the extent permitted by applicable law, '
              '${AppLegalInfo.organizationName} does not make '
              'warranties that every feature will always be '
              'available, uninterrupted or error-free.',
        ),
        SettingsInfoSection(
          title: 'Limitation of liability',
          icon: Icons.balance_rounded,
          body:
              'To the extent permitted by applicable law, '
              '${AppLegalInfo.organizationName} will not be '
              'responsible for indirect or consequential loss '
              'arising from use of, or inability to use, the '
              'app or an external service.',
        ),
        SettingsInfoSection(
          title: 'Changes to these terms',
          icon: Icons.update_rounded,
          body:
              'These Terms may be updated when the app, legal '
              'requirements or services change. Continued use '
              'after an update means you accept the revised '
              'Terms.',
        ),
        SettingsInfoSection(
          title: 'Contact',
          icon: Icons.email_outlined,
          body:
              'Developer: ${AppLegalInfo.organizationName}\n'
              'Email: ${AppLegalInfo.supportEmail}',
        ),
      ],
    );
  }
}
