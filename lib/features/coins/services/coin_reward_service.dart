import '../../community/services/community_api.dart';

class CoinRewardService {
  static Future<Map<String, dynamic>> wallet({
    int? before,
  }) {
    return CommunityApi.request(
      'coins/wallet.php',
      query: before == null ? null : {'before': '$before'},
      guestRetry: false,
    );
  }

  static Future<Map<String, dynamic>> dailyCheckIn() {
    return CommunityApi.request(
      'coins/wallet.php',
      body: {'action': 'daily_checkin'},
      guestRetry: false,
    );
  }

  static Future<List<Map<String, dynamic>>> rules() async {
    final result = await CommunityApi.request(
      'coins/rules.php',
      guestRetry: false,
    );

    final rows = result['rules'];

    if (rows is! List || rows.any((row) => row is! Map)) {
      throw Exception('Invalid reward rules response');
    }

    return rows
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }
}