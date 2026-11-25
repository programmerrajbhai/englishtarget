import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommunityAuthService {
// উদাহরণ—এখানে তোমার Mac-এর আসল IP বসাবে।
  static const baseUrl =
      'http://192.168.1.102/english_target_api';
  static const _tokenKey = 'community_token';
  static final _storage = SharedPreferencesAsync();

  static Future<String?> getToken() => _storage.getString(_tokenKey);

  static Future<void> clearSession() => _storage.remove(_tokenKey);

  static Future<bool> restoreSession() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/profile.php'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401 || response.statusCode == 403) {
        await clearSession();
        return false;
      }

      final data = _decode(response);
      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception('Session যাচাই করা যায়নি। আবার চেষ্টা করো।');
      }
      return true;
    } on TimeoutException {
      throw Exception('Server response দিচ্ছে না। XAMPP চালু আছে?');
    } on SocketException {
      throw Exception('Server connection হয়নি। XAMPP চেক করো।');
    } on http.ClientException {
      throw Exception('API connection হয়নি। Server address চেক করো।');
    }
  }

  static Future<void> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email_or_phone': identifier.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = _decode(response);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] is String
            ? data['message']
            : 'Login failed');
      }

      final token = data['token'];
      if (token is! String ||
          !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(token)) {
        throw Exception('Server থেকে valid token পাওয়া যায়নি।');
      }

      await _storage.setString(_tokenKey, token);
    } on TimeoutException {
      throw Exception('Server response দিচ্ছে না। আবার চেষ্টা করো।');
    } on SocketException {
      throw Exception('Server connection হয়নি। XAMPP চালু করো।');
    } on http.ClientException {
      throw Exception('API connection হয়নি। Server address চেক করো।');
    }
  }

  static Map<String, dynamic> _decode(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map<String, dynamic>) return data;
    } catch (_) {
      // নিচে user-friendly error দেওয়া হচ্ছে।
    }
    throw Exception('API থেকে JSON আসেনি। URL ও PHP error চেক করো।');
  }
}