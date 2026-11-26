import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'support_screen.dart';
import 'terms_of_use_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // তোমার সার্ভারে আপলোড করা delete_account.php ফাইলের লাইভ URL বসাও
  static const String _deleteAccountUrl =
      'https://yourdomain.com/api/users/delete_account.php';

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _openDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'অ্যাকাউন্ট ডিলিট করার পেজটি ব্রাউজারে ওপেন হবে। সেখানে আপনার Email বা Phone এবং Password দিয়ে স্থায়ীভাবে অ্যাকাউন্ট ডিলিট করতে পারবেন।',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final opened = await launchUrl(
        Uri.parse(_deleteAccountUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delete account পেজটি খোলা যাচ্ছে না।'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Browser open করতে সমস্যা হয়েছে। আবার চেষ্টা করো।'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.navy,
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.settings_rounded,
                    color: AppColors.primary,
                    size: 29,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'English Target',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Manage your app experience',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel(title: 'Privacy & Safety'),
          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            color: AppColors.primary,
            title: 'Privacy Policy',
            subtitle: 'How English Target uses information',
            onTap: () {
              _open(context, const PrivacyPolicyScreen());
            },
          ),
          _SettingsTile(
            icon: Icons.gavel_rounded,
            color: AppColors.blue,
            title: 'Terms of Use',
            subtitle: 'Rules for using the app',
            onTap: () {
              _open(context, const TermsOfUseScreen());
            },
          ),
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            color: Colors.redAccent,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and data',
            onTap: () {
              _openDeleteAccount(context);
            },
          ),
          const SizedBox(height: 20),
          const _SectionLabel(title: 'Help'),
          _SettingsTile(
            icon: Icons.support_agent_rounded,
            color: AppColors.purple,
            title: 'Help & Support',
            subtitle: 'Get help or report a problem',
            onTap: () {
              _open(context, const SupportScreen());
            },
          ),
          const SizedBox(height: 20),
          const _SectionLabel(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            color: AppColors.amber,
            title: 'About English Target',
            subtitle: 'App information and version',
            onTap: () {
              _open(context, const AboutScreen());
            },
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'English Target • Learn every day',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 9),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withAlpha(22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}