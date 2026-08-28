import 'package:flutter/material.dart';

import '../data/app_legal_info.dart';
import 'settings_info_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsInfoScreen(
      title: 'Privacy Policy',
      subtitle: 'How your information and permissions are handled',
      icon: Icons.privacy_tip_rounded,
      sections: <SettingsInfoSection>[
        SettingsInfoSection(
          title: 'About this policy',
          icon: Icons.description_outlined,
          body:
              'Effective date: ${AppLegalInfo.effectiveDate}\n\n'
              '${AppLegalInfo.organizationName} operates '
              '${AppLegalInfo.appName}. This Privacy Policy '
              'explains what information the app accesses, '
              'how it is used and the choices available to you.',
        ),
        SettingsInfoSection(
          title: 'Accounts and personal information',
          icon: Icons.person_off_outlined,
          body:
              '${AppLegalInfo.appName} does not currently '
              'require an account, login, name, phone number '
              'or email address to use its learning features. '
              'The reviewed version does not contain an '
              'advertising or analytics SDK.',
        ),
        SettingsInfoSection(
          title: 'Learning progress',
          icon: Icons.insights_rounded,
          body:
              'Learning information such as XP, streak, '
              'completed lessons, test scores, speaking '
              'results and progress is stored locally on '
              'your device. ${AppLegalInfo.organizationName} '
              'does not operate a server that receives this '
              'learning progress.',
        ),
        SettingsInfoSection(
          title: 'Microphone and speech recognition',
          icon: Icons.mic_rounded,
          body:
              'Microphone access is optional and is used only '
              'after you start a speaking activity. Your voice '
              'is provided to the speech-recognition service '
              'selected or supplied by your device so that '
              'spoken words can be converted into text.\n\n'
              'Depending on your device, language settings and '
              'speech provider, recognition may occur on the '
              'device or the audio may be processed by that '
              'provider. ${AppLegalInfo.organizationName} '
              'does not intentionally record or store copies '
              'of your voice on its own servers. Recognized '
              'text is used to evaluate the current speaking '
              'exercise.',
        ),
        SettingsInfoSection(
          title: 'Text-to-speech',
          icon: Icons.volume_up_rounded,
          body:
              'When you tap a listening button, lesson text '
              'is sent to the text-to-speech engine available '
              'on your device. Processing is controlled by the '
              'selected device or speech-service provider.',
        ),
        SettingsInfoSection(
          title: 'Saving progress cards',
          icon: Icons.image_outlined,
          body:
              'The app creates an achievement or progress card '
              'only when you request it. When you tap Save, '
              'the generated image is stored in your device '
              'gallery. The app does not read or upload your '
              'existing personal photos.',
        ),
        SettingsInfoSection(
          title: 'Sharing',
          icon: Icons.share_outlined,
          body:
              'When you tap Share, Android shows the apps '
              'available on your device. The generated card '
              'is transferred only to the application that '
              'you select. The selected application processes '
              'the image according to its own privacy policy.',
        ),
        SettingsInfoSection(
          title: 'Support communications',
          icon: Icons.support_agent_rounded,
          body:
              'If you voluntarily contact support, your email '
              'address, message, screenshots and device details '
              'included by you may be received through the '
              'email service. This information is used only to '
              'reply to you, investigate the issue and provide '
              'support.',
        ),
        SettingsInfoSection(
          title: 'Data sharing and sale',
          icon: Icons.handshake_outlined,
          body:
              '${AppLegalInfo.organizationName} does not sell '
              'your personal or sensitive information. Data '
              'is not shared for advertising. Information may '
              'be processed by your selected speech service, '
              'email provider or sharing application only when '
              'required for the feature you choose to use.',
        ),
        SettingsInfoSection(
          title: 'Retention and deletion',
          icon: Icons.delete_outline_rounded,
          body:
              'Local learning progress remains on your device '
              'until you clear the app data or uninstall the '
              'app. Saved progress cards remain in your gallery '
              'until you delete them.\n\n'
              'Because the app does not create an online '
              'account, there is no server-side account to '
              'delete. You may request deletion of support '
              'communications by contacting us.',
        ),
        SettingsInfoSection(
          title: 'Security',
          icon: Icons.security_rounded,
          body:
              'The app limits permissions to features that '
              'need them and keeps learning progress in local '
              'application storage. No electronic storage or '
              'transmission method can be guaranteed to be '
              'completely secure.',
        ),
        SettingsInfoSection(
          title: 'Children',
          icon: Icons.family_restroom_rounded,
          body:
              '${AppLegalInfo.appName} is a general English '
              'learning application and is not designed to '
              'collect personal information from children. '
              'Parents or guardians should supervise use where '
              'required by local law.',
        ),
        SettingsInfoSection(
          title: 'Policy updates',
          icon: Icons.update_rounded,
          body:
              'This policy may be updated when app features, '
              'permissions or data practices change. The '
              'effective date shown above will be updated when '
              'a material revision is published.',
        ),
        SettingsInfoSection(
          title: 'Privacy contact',
          icon: Icons.email_outlined,
          body:
              'Developer: ${AppLegalInfo.organizationName}\n'
              'App: ${AppLegalInfo.appName}\n'
              'Email: ${AppLegalInfo.supportEmail}',
        ),
      ],
    );
  }
}
