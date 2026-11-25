import 'dart:convert';

import 'package:http/http.dart' as http;

import 'community_api.dart';
import 'community_auth_service.dart';

class CommunityUploadService {
  static Future<int> upload({
    required String path,
    required String purpose,
  }) async {
    final token = await CommunityAuthService.getToken();

    if (token == null || token.isEmpty) {
      throw LoginRequired();
    }

    final client = http.Client();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${CommunityAuthService.baseUrl}/api/media/upload.php',
        ),
      )
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['purpose'] = purpose
        ..files.add(await http.MultipartFile.fromPath('file', path));

      // MultipartRequest নিজেই সঠিক Content-Type সেট করে।
      final response = await (() async {
        final stream = await client.send(request);
        return http.Response.fromStream(stream);
      })().timeout(const Duration(minutes: 3));

      if (response.statusCode == 401) {
        await CommunityAuthService.clearSession();
        throw LoginRequired();
      }

      dynamic data;

      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        throw Exception('Upload server থেকে সঠিক response পাওয়া যায়নি।');
      }

      if (data is! Map ||
          response.statusCode >= 400 ||
          data['success'] != true) {
        throw Exception(
          data is Map
              ? data['message'] ?? 'Upload failed'
              : 'Upload failed',
        );
      }

      final upload = data['upload'];
      final id = upload is Map
          ? CommunityApi.number(upload['id'])
          : 0;

      if (id < 1) {
        throw Exception('Upload ID পাওয়া যায়নি।');
      }

      return id;
    } finally {
      client.close();
    }
  }
}