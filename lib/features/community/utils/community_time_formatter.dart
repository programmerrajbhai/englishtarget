abstract final class CommunityTimeFormatter {
  static String timeAgo(dynamic value) {
    final raw = '${value ?? ''}'.trim();
    if (raw.isEmpty) return '';

    final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) {
      return raw.length >= 16 ? raw.substring(0, 16).replaceFirst('T', ' ') : raw;
    }

    final localTime = parsed.isUtc ? parsed.toLocal() : parsed;
    final diff = DateTime.now().difference(localTime);

    if (diff.isNegative || diff.inSeconds < 60) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w ${w == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays < 365) {
      final mo = (diff.inDays / 30).floor();
      return '$mo ${mo == 1 ? 'month' : 'months'} ago';
    }

    final y = (diff.inDays / 365).floor();
    return '$y ${y == 1 ? 'year' : 'years'} ago';
  }
}