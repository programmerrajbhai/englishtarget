import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'community_auth_service.dart';

class LoginRequired implements Exception {}

class CommunityApi {
  static const base = CommunityAuthService.baseUrl;

  static Future<Map<String, dynamic>> request(
      String path, {
        Map<String, String>? query,
        Map<String, dynamic>? body,
        bool guestRetry = true,
      }) async {
    final token = await CommunityAuthService.getToken();
    final uri = Uri.parse('$base/api/$path')
        .replace(queryParameters: query);

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    try {
      final response = await (body == null
          ? http.get(uri, headers: headers)
          : http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 401) {
        await CommunityAuthService.clearSession();

        // Expired token থাকলেও public GET guest হিসেবে চলবে।
        if (body == null && guestRetry && token != null) {
          return request(path, query: query, guestRetry: false);
        }
        throw LoginRequired();
      }

      final dynamic decoded;
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        throw Exception('Server থেকে JSON আসেনি। PHP API চেক করো।');
      }

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      if (response.statusCode >= 400 || decoded['success'] != true) {
        throw Exception(
          decoded['message'] is String
              ? decoded['message']
              : 'Request failed',
        );
      }

      return decoded;
    } on TimeoutException {
      throw Exception('Server response দিচ্ছে না। আবার চেষ্টা করো।');
    } on SocketException {
      throw Exception('Connection হয়নি। XAMPP চালু আছে কি না দেখো।');
    } on http.ClientException {
      throw Exception('Server connection failed');
    }
  }

  static Future<Map<String, dynamic>> feed({
    required int page,
    required String type,
    required String category,
  }) {
    return request(
      'community/feed.php',
      query: {
        'page': '$page',
        'limit': '10',
        'type': type,
        if (category.isNotEmpty) 'category': category,
      },
    );
  }

  static Future<Map<String, dynamic>> like(int postId) {
    return request(
      'community/toggle_like.php',
      body: {'post_id': postId},
    );
  }

  static int number(dynamic value) =>
      int.tryParse('$value') ?? 0;

  static bool flag(dynamic value) =>
      value == true || value == 1 || value == '1';

  static String? mediaUrl(dynamic key) {
    if (key is! String || key.trim().isEmpty) return null;

    // Local upload-এর database path: Upload/images/...
    if (!key.startsWith('Upload/')) return null;

    return Uri.parse('$base/').resolve(key).toString();
  }

  static String errorText(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}