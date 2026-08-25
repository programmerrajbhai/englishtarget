import 'package:shared_preferences/shared_preferences.dart';

abstract final class LocalStorageService {
  static const String _onboardingCompletedKey =
      'onboarding_completed';

  static final SharedPreferencesAsync _preferences =
  SharedPreferencesAsync();

  static Future<bool> isOnboardingCompleted() async {
    return await _preferences.getBool(
      _onboardingCompletedKey,
    ) ??
        false;
  }

  static Future<void> completeOnboarding() async {
    await _preferences.setBool(
      _onboardingCompletedKey,
      true,
    );
  }

  static Future<void> resetOnboarding() async {
    await _preferences.remove(
      _onboardingCompletedKey,
    );
  }
}