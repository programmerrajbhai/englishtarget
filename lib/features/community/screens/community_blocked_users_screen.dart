import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../widgets/community_search_cards.dart';
import 'community_login_screen.dart';

class CommunityBlockedUsersScreen extends StatefulWidget {
  const CommunityBlockedUsersScreen({super.key});

  @override
  State<CommunityBlockedUsersScreen> createState() =>
      _CommunityBlockedUsersScreenState();
}

class _CommunityBlockedUsersScreenState
    extends State<CommunityBlockedUsersScreen> {
  final _users = <Map<String, dynamic>>[];

  int _page = 0;
  int _generation = 0;
  int? _busyId;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _needsLogin = false;

  String? _error;

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
        _users.clear();
        _page = 0;
        _hasMore = false;
      }
    });

    try {
      final data = await CommunityApi.request(
        'community/get_blocked_users.php',
        query: {
          'page': '$nextPage',
          'limit': '20',
        },
        guestRetry: false,
      );

      if (!mounted || generation != _generation) return;

      final rows = data['users'];

      if (rows is! List) {
        throw Exception('Blocked list response সঠিক নয়।');
      }

      setState(() {
        _needsLogin = false;

        final ids = _users.map((user) => '${user['id']}').toSet();

        for (final row in rows) {
          if (row is Map && ids.add('${row['id']}')) {
            _users.add(Map<String, dynamic>.from(row));
          }
        }

        _page = nextPage;
        final pagination = data['pagination'];

        _hasMore = pagination is Map &&
            CommunityApi.flag(pagination['has_more']);
      });
    } on LoginRequired {
      if (mounted && generation == _generation) {
        setState(() {
          _needsLogin = true;
          _users.clear();
          _hasMore = false;
        });
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

  Future<void> _login() async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CommunityLoginScreen(),
      ),
    );

    if (mounted && success == true) await _load();
  }

  Future<void> _unblock(Map<String, dynamic> user) async {
    if (_busyId != null || _loading || _loadingMore) return;

    final id = CommunityApi.number(user['id']);
    setState(() => _busyId = id);

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Unblock ${user['name']}?'),
          content: const Text(
            'তোমার দেওয়া block সরানো হবে। '
                'আগের Follow সম্পর্ক নিজে থেকে ফিরে আসবে না।',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Unblock'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      final result = await CommunityApi.request(
        'community/toggle_block.php',
        body: {'user_id': id},
      );

      if (!mounted) return;

      _message(
        CommunityApi.flag(result['is_blocked'])
            ? 'Block status বদলেছে। Updated list দেখো।'
            : 'User unblocked',
      );

      await _load();
    } on LoginRequired {
      if (mounted) await _load();
    } catch (e) {
      if (!mounted) return;

      _message(CommunityApi.errorText(e));

      // Response হারালে toggle আবার পাঠাব না।
      // Fresh list ছাড়া একই পুরোনো action ব্যবহার হবে না।
      await _load();
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F7F1),
      appBar: AppBar(
        title: const Text('Your blocked users'),
        backgroundColor: const Color(0xFFE8F7F1),
        foregroundColor: searchInk,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_busyId == null) await _load();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            searchCard(
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: searchGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Manage the people you have blocked.\n'
                          'Unblocking does not automatically follow them.',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_needsLogin)
              _notice(
                'Blocked list দেখতে login করো।',
                label: 'Sign in',
                action: _login,
              )
            else ...[
                for (final user in _users)
                  searchCard(
                    Row(
                      children: [
                        searchAvatar(user['avatar_key']),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user['name'] ?? ''}',
                                style: const TextStyle(
                                  color: searchInk,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lv. ${user['level'] ?? 0}',
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _busyId != null || _loadingMore
                              ? null
                              : () => _unblock(user),
                          child: _busyId ==
                              CommunityApi.number(user['id'])
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Text('Unblock'),
                        ),
                      ],
                    ),
                  ),
                if (_error != null)
                  _notice(
                    _error!,
                    label: 'Retry',
                    action: _busyId != null
                        ? null
                        : () => _load(
                      more: _page > 0 && _hasMore,
                    ),
                  )
                else if (_users.isEmpty)
                  _notice('তুমি কাউকে block করোনি।'),
                if (_loadingMore)
                  const Center(child: CircularProgressIndicator())
                else if (_hasMore && _error == null)
                  OutlinedButton(
                    onPressed: _busyId != null
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

  Widget _notice(
      String text, {
        String? label,
        VoidCallback? action,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.shield_outlined,
            color: searchGreen,
            size: 42,
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
          if (label != null)
            TextButton(
              onPressed: action,
              child: Text(label),
            ),
        ],
      ),
    );
  }
}