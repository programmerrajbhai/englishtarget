import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_legal_info.dart';
import 'settings_info_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _openSupportEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppLegalInfo.supportEmail,
      queryParameters: <String, String>{
        'subject': '${AppLegalInfo.appName} Support Request',
        'body':
            'Hello ${AppLegalInfo.organizationName},\n\n'
            'Please describe your problem:\n\n'
            'Device model:\n'
            'Android version:\n'
            'App version: '
            '${AppLegalInfo.versionLabel}\n\n',
      },
    );

    try {
      final bool opened = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        _showEmailError(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showEmailError(context);
      }
    }
  }

  void _showEmailError(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'No email app was found. Email us at '
            '${AppLegalInfo.supportEmail}',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsInfoScreen(
      title: 'Help & Support',
      subtitle: 'Get assistance or report an app problem',
      icon: Icons.support_agent_rounded,
      actionLabel: 'Contact Support',
      actionIcon: Icons.email_rounded,
      onAction: () => _openSupportEmail(context),
      sections: const <SettingsInfoSection>[
        SettingsInfoSection(
          title: 'Before contacting us',
          icon: Icons.build_circle_outlined,
          body:
              'If something is not working, close and reopen '
              'the app, check your internet connection where '
              'required and confirm that the necessary '
              'permission has been allowed.',
        ),
        SettingsInfoSection(
          title: 'Support email',
          icon: Icons.alternate_email_rounded,
          body: AppLegalInfo.supportEmail,
        ),
        SettingsInfoSection(
          title: 'What to include',
          icon: Icons.list_alt_rounded,
          body:
              'Please include:\n'
              '• A clear description of the problem\n'
              '• The steps that caused it\n'
              '• Your device model\n'
              '• Android version\n'
              '• App version\n'
              '• A screenshot, when useful',
        ),
        SettingsInfoSection(
          title: 'Protect your privacy',
          icon: Icons.shield_outlined,
          body:
              'Do not send passwords, payment information, '
              'identity documents or unnecessary personal '
              'information. English Target does not require '
              'your password for support.',
        ),
        SettingsInfoSection(
          title: 'Developer',
          icon: Icons.business_outlined,
          body:
              '${AppLegalInfo.organizationName}\n'
              '${AppLegalInfo.appName}\n'
              'Version ${AppLegalInfo.versionLabel}',
        ),
      ],
    );
  }
}
