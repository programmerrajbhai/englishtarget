import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

abstract final class UpdateService {
  static Future<void> checkForFlexibleUpdate() async {
    // এই প্যাকেজটি শুধুমাত্র Android-এর জন্য কাজ করে
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();

      // যদি আপডেট এভেইলেবল থাকে
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // ফ্লেক্সিবল আপডেট শুরু করবে (ব্যাকগ্রাউন্ডে ডাউনলোড হবে)
        await InAppUpdate.startFlexibleUpdate();
        // ডাউনলোড শেষ হলে ইন্সটল প্রম্পট দেখাবে
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      debugPrint('In-App Update Failed: $e');
    }
  }
}