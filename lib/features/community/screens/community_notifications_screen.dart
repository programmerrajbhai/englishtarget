import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../widgets/community_search_cards.dart';
import 'community_discussion_screen.dart';
import 'community_login_screen.dart';
import 'community_profile_screen.dart';

class CommunityNotificationsScreen extends StatefulWidget {
  const CommunityNotificationsScreen({super.key});

  @override
  State<CommunityNotificationsScreen> createState() =>
      _CommunityNotificationsScreenState();
}

class _CommunityNotificationsScreenState
    extends State<CommunityNotificationsScreen> {
  static const filters = {
    'all': 'All',
    'replies': 'Replies',
    'follows': 'Follows',
    'likes': 'Likes',
  };

  final _items = <Map<String, dynamic>>[];

  String _type = 'all';
  String? _error;
  int _page = 0;
  int _generation = 0;
  int _unread = 0;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _needsLogin = false;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loading || _loadingMore || !_hasMore)) return;

    final generation = ++_generation;
    final nextPage = more ? _page + 1 : 1;

    setState(() {
      _error = null;
      _loading = !more;
      _loadingMore = more;

      if (!more) {
        _items.clear();
        _page = 0;
        _hasMore = false;
      }
    });

    try {
      final data = await CommunityApi.request(
        'community/get_notifications.php',
        query: {
          'type': _type,
          'page': '$nextPage',
          'limit': '20',
        },
        guestRetry: false,
      );

      if (!mounted || generation != _generation) return;

      final rows = data['notifications'];

      if (rows is! List) {
        throw Exception('Notification response সঠিক নয়।');
      }

      setState(() {
        _needsLogin = false;
        _unread = CommunityApi.number(data['unread_count']);

        final ids = _items.map((item) => '${item['id']}').toSet();

        for (final row in rows) {
          if (row is Map && ids.add('${row['id']}')) {
            _items.add(Map<String, dynamic>.from(row));
          }
        }

        _page = nextPage;
        final pagination = data['pagination'];
        _hasMore = pagination is Map &&
            CommunityApi.flag(pagination['has_more']);
      });
    } on LoginRequired {
      if (mounted && generation == _generation) {
        _showLogin();
      }
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _error = CommunityApi.errorText(e));
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _showLogin() {
    _generation++;

    setState(() {
      _needsLogin = true;
      _items.clear();
      _unread = 0;
      _hasMore = false;
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _login() async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CommunityLoginScreen(),
      ),
    );

    if (mounted && success == true) await _load();
  }

  Future<void> _markAll() async {
    if (_working || _unread == 0) return;

    setState(() => _working = true);

    try {
      await CommunityApi.request(
        'community/mark_notifications_read.php',
        body: {'all': true},
      );

      if (mounted) await _load();
    } on LoginRequired {
      if (mounted) _showLogin();
    } catch (e) {
      if (mounted) _message(CommunityApi.errorText(e));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _openNotification(Map<String, dynamic> item) async {
    if (_working) return;

    setState(() => _working = true);

    try {
      if (!CommunityApi.flag(item['is_read'])) {
        await CommunityApi.request(
          'community/mark_notifications_read.php',
          body: {
            'notification_id': CommunityApi.number(item['id']),
          },
        );
      }

      if (!mounted) return;

      final postId = CommunityApi.number(item['post_id']);
      final actorId = CommunityApi.number(item['actor_id']);

      if (postId > 0) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityDiscussionScreen(postId: postId),
          ),
        );
      } else if (item['type'] == 'follow' && actorId > 0) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityProfileScreen(userId: actorId),
          ),
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              '${item['title'] ?? ''}'.trim().isEmpty
                  ? 'Notification'
                  : '${item['title']}',
            ),
            content: Text(_description(item)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }

      if (mounted) await _load();
    } on LoginRequired {
      if (mounted) _showLogin();
    } catch (e) {
      if (mounted) _message(CommunityApi.errorText(e));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _description(Map<String, dynamic> item) {
    final message = '${item['message'] ?? ''}'.trim();
    if (message.isNotEmpty) return message;

    final name = '${item['actor_name'] ?? 'Someone'}';
    final comment = '${item['comment_body'] ?? ''}'.trim();

    switch (item['type']) {
      case 'like':
        return '$name liked your post.';
      case 'comment':
        return comment.isEmpty
            ? '$name replied to your post.'
            : '$name replied: $comment';
      case 'comment_like':
        return '$name liked your comment.';
      case 'follow':
        return '$name started following you.';
      case 'mention':
        return '$name mentioned you.';
      default:
        final title = '${item['title'] ?? ''}'.trim();
        return title.isEmpty ? 'Community update' : title;
    }
  }

  IconData _icon(dynamic type) {
    switch (type) {
      case 'like':
      case 'comment_like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'follow':
        return Icons.person_add_alt_1;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F7F1),
        foregroundColor: searchInk,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            onPressed: _working ||
                _loading ||
                _loadingMore ||
                _needsLogin ||
                _unread == 0
                ? null
                : _markAll,
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: searchGreen,
        onRefresh: () => _load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters.entries.map((entry) {
                final selected = _type == entry.key;

                return ChoiceChip(
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: searchGreen,
                  backgroundColor: Colors.white,
                  label: Text(entry.value),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : searchInk,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: _working
                      ? null
                      : (_) {
                    if (_type == entry.key) return;
                    setState(() => _type = entry.key);
                    _load();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            if (!_needsLogin && !_loading)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  '$_unread unread across all notifications',
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ),
            if (_working) const LinearProgressIndicator(),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_needsLogin)
              _notice(
                'Notifications দেখতে login করো।',
                button: 'Sign in',
                action: _login,
              )
            else ...[
                for (final item in _items) _notificationCard(item),
                if (_error != null)
                  _notice(
                    _error!,
                    button: 'Retry',
                    action: () => _load(
                      more: _page > 0 && _hasMore,
                    ),
                  )
                else if (_items.isEmpty)
                  _notice('এখনো কোনো notification নেই।'),
                if (_loadingMore)
                  const Center(child: CircularProgressIndicator())
                else if (_hasMore && _error == null)
                  OutlinedButton(
                    onPressed: _working
                        ? null
                        : () => _load(more: true),
                    child: const Text('Load more'),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> item) {
    final read = CommunityApi.flag(item['is_read']);
    final date = '${item['created_at'] ?? ''}';

    return searchCard(
      InkWell(
        onTap: _working ? null : () => _openNotification(item),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                searchAvatar(item['actor_avatar_key']),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFFE8F7F1),
                    child: Icon(
                      _icon(item['type']),
                      size: 14,
                      color: searchGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _description(item),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: searchInk,
                      height: 1.5,
                      fontWeight:
                      read ? FontWeight.w400 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    date.length >= 16
                        ? date.substring(0, 16).replaceFirst('T', ' ')
                        : date,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!read)
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 5),
                child: Icon(
                  Icons.circle,
                  size: 9,
                  color: searchGreen,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _notice(
      String text, {
        String? button,
        VoidCallback? action,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_none,
            size: 44,
            color: searchGreen,
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.blueGrey,
              height: 1.5,
            ),
          ),
          if (button != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: action,
              child: Text(button),
            ),
          ],
        ],
      ),
    );
  }
}