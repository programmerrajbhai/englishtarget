import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'community_auth_service.dart';

class CommunityRegistrationService {
  static Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    late http.Response response;

    try {
      response = await http
          .post(
        Uri.parse(
          '${CommunityAuthService.baseUrl}/api/auth/register.php',
        ),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw Exception(
        'Server response আসেনি। Account তৈরি হয়ে থাকতে পারে—'
            'আবার Register করার আগে Sign in চেষ্টা করো।',
      );
    } on SocketException {
      throw Exception(
        'Server-এর সঙ্গে connection হয়নি। Wi-Fi ও API address দেখো।',
      );
    } on http.ClientException {
      throw Exception(
        'Connection interrupted হয়েছে। '
            'আবার Register করার আগে Sign in চেষ্টা করো।',
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw Exception(
        'Server থেকে সঠিক JSON response পাওয়া যায়নি। '
            'Account তৈরি হয়েছে কি না Sign in করে দেখো।',
      );
    }

    if (decoded is! Map) {
      throw Exception('Invalid registration response');
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      throw Exception(
        decoded['message'] ?? 'Registration failed',
      );
    }

    final token = decoded['token'];

    if (token is! String ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(token)) {
      throw Exception(
        'Account তৈরি হয়েছে, কিন্তু login token পাওয়া যায়নি। '
            'Sign in screen থেকে login করো।',
      );
    }

    try {
      await SharedPreferencesAsync().setString(
        'community_token',
        token,
      );
    } catch (_) {
      throw Exception(
        'Account তৈরি হয়েছে, কিন্তু session save হয়নি। '
            'Sign in screen থেকে login করো।',
      );
    }
  }
}