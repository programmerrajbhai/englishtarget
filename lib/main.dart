import 'package:flutter/material.dart';
import 'app.dart';
import 'core/ads/ad_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Non-blocking initialization - অ্যাপ স্টার্টআপ স্লো হবে না
  AdManager.instance.initialize();

  runApp(const EnglishTargetApp());
}