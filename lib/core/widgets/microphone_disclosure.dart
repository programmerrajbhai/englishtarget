import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';

abstract final class MicrophoneDisclosure {
  static const String _acceptedKey =
      'microphone_disclosure_accepted_v1';

  static Future<bool> ensureAccepted(
      BuildContext context,
      ) async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final bool alreadyAccepted =
        preferences.getBool(_acceptedKey) ?? false;

    if (alreadyAccepted) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

    final bool accepted =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (
              BuildContext dialogContext,
              ) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(24),
              ),
              titlePadding:
              const EdgeInsets.fromLTRB(
                22,
                22,
                22,
                0,
              ),
              contentPadding:
              const EdgeInsets.fromLTRB(
                22,
                16,
                22,
                8,
              ),
              actionsPadding:
              const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
              title: const Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 23,
                    backgroundColor:
                    Color(0xFFE8F8F1),
                    child: Icon(
                      Icons.mic_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      'Speaking Practice',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 19,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'English Target uses your microphone '
                        'only when you start a speaking '
                        'practice.',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 13),
                  _DisclosurePoint(
                    icon: Icons.record_voice_over_rounded,
                    text:
                    'Your voice is converted into text '
                        'to check your pronunciation.',
                  ),
                  SizedBox(height: 10),
                  _DisclosurePoint(
                    icon: Icons.security_rounded,
                    text:
                    'English Target does not '
                        'intentionally store your voice '
                        'recordings on its own servers.',
                  ),
                  SizedBox(height: 10),
                  _DisclosurePoint(
                    icon: Icons.cloud_outlined,
                    text:
                    'Your device speech service may '
                        'process audio on-device or through '
                        'its provider.',
                  ),
                  SizedBox(height: 13),
                  Text(
                    'You can choose “Not now” and continue '
                        'using other learning features.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text(
                    'Not now',
                    style: TextStyle(
                      color:
                      AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(
                    Icons.mic_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
            false;

    if (!accepted) {
      return false;
    }

    await preferences.setBool(
      _acceptedKey,
      true,
    );

    return true;
  }
}

class _DisclosurePoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DisclosurePoint({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(18),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}