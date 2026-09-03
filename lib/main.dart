import 'package:flutter/material.dart';
import 'app.dart';
import 'core/ads/ad_manager.dart'; // যুক্ত করা হয়েছে

void main() async {
  // Widgets binding নিশ্চিত করা এবং AdMob চালু করা
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.instance.initialize();

  runApp(const EnglishTargetApp());
}