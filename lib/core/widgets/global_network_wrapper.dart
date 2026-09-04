import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../constants/app_colors.dart';

class GlobalNetworkWrapper extends StatefulWidget {
  final Widget child;

  const GlobalNetworkWrapper({
    super.key,
    required this.child,
  });

  @override
  State<GlobalNetworkWrapper> createState() => _GlobalNetworkWrapperState();
}

class _GlobalNetworkWrapperState extends State<GlobalNetworkWrapper> {
  bool _hasInternet = true;
  bool _isChecking = false; // রিফ্রেশ লোডিং অ্যানিমেশনের জন্য
  StreamSubscription<InternetStatus>? _internetSubscription;

  @override
  void initState() {
    super.initState();
    _setupInternetListener();
  }

  // অটোমেটিক রিয়েল-টাইম চেকার
  void _setupInternetListener() {
    _internetSubscription = InternetConnection().onStatusChange.listen((InternetStatus status) {
      if (mounted) {
        setState(() {
          _hasInternet = status == InternetStatus.connected;
        });
      }
    });
  }

  // ম্যানুয়াল রিফ্রেশ বাটন চেকার
  Future<void> _manualCheck() async {
    setState(() => _isChecking = true);

    // প্রিমিয়াম UX-এর জন্য হালকা একটু ডিলে (যাতে লোডিং অ্যানিমেশনটা বোঝা যায়)
    await Future.delayed(const Duration(milliseconds: 800));

    // FIXED: hasInternet এর বদলে hasInternetAccess ব্যবহার করা হয়েছে
    final bool isConnected = await InternetConnection().hasInternetAccess;

    if (mounted) {
      setState(() {
        _hasInternet = isConnected;
        _isChecking = false;
      });
    }
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        // মূল অ্যাপ
        widget.child,

        // ইন্টারনেট না থাকলে অ্যানিমেটেড ব্লক স্ক্রিন
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: !_hasInternet
              ? Material(
            key: const ValueKey('no_internet_screen'),
            color: Colors.white,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- অ্যানিমেটেড ওয়াইফাই আইকন ---
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            size: 72,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- টাইটেল ---
                      const Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- ডেসক্রিপশন ---
                      const Text(
                        'Please check your Wi-Fi or mobile data network and try again to continue learning.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- অ্যানিমেটেড রিফ্রেশ বাটন ---
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isChecking ? null : _manualCheck,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _isChecking
                                ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Row(
                              key: ValueKey('button_text'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Try Again',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              : const SizedBox.shrink(key: ValueKey('has_internet')),
        ),
      ],
    );
  }
}