import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../widgets/community_search_cards.dart';
import 'community_login_screen.dart';
import 'community_profile_screen.dart';

class CommunityConnectionsScreen extends StatefulWidget {
  final int userId;
  final String initialType;

  const CommunityConnectionsScreen({
    super.key,
    required this.userId,
    this.initialType = 'followers',
  });

  @override
  State<CommunityConnectionsScreen> createState() =>
      _CommunityConnectionsScreenState();
}

class _CommunityConnectionsScreenState
    extends State<CommunityConnectionsScreen> {
  final _search = TextEditingController();
  final _users = <Map<String, dynamic>>[];
  final _following = <int>{};

  late String _type;
  String _query = '';
  String? _error;

  int _page = 0;
  int _generation = 0;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _needsLogin = false;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType == 'following'
        ? 'following'
        : 'followers';
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
        'community/get_follow_list.php',
        query: {
          'user_id': '${widget.userId}',
          'type': _type,
          'q': _query,
          'page': '$nextPage',
          'limit': '20',
        },
        guestRetry: false,
      );

      if (!mounted || generation != _generation) return;

      final rows = data['users'];

      if (rows is! List) {
        throw Exception('Connections response সঠিক নয়।');
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
      if (!mounted || generation != _generation) return;

      setState(() {
        _needsLogin = true;
        _users.clear();
        _hasMore = false;
      });
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

  void _submitSearch() {
    _query = _search.text.trim();
    FocusScope.of(context).unfocus();
    _load();
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

  Future<void> _follow(Map<String, dynamic> user) async {
    final id = CommunityApi.number(user['id']);

    if (_following.contains(id) ||
        CommunityApi.flag(user['is_self'])) {
      return;
    }

    setState(() => _following.add(id));

    try {
      await CommunityApi.request(
        'community/toggle_follow.php',
        body: {'user_id': id},
      );

      // Unfollow করলে নিজের Following list থেকেও সরবে।
      if (mounted) await _load();
    } on LoginRequired {
      if (!mounted) return;

      // চলমান পুরোনো list request-এর result বাতিল।
      _generation++;

      setState(() {
        _needsLogin = true;
        _users.clear();
        _hasMore = false;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(CommunityApi.errorText(e))),
      );

      // Toggle পুনরায় না পাঠিয়ে server state reload।
      await _load();
    } finally {
      if (mounted) setState(() => _following.remove(id));
    }
  }

  Future<void> _openProfile(Map<String, dynamic> user) async {
    if (_opening) return;
    _opening = true;

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityProfileScreen(
            userId: CommunityApi.number(user['id']),
          ),
        ),
      );

      if (mounted) await _load();
    } finally {
      _opening = false;
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
          'Connections',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: searchGreen,
        onRefresh: () => _load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(18),
          children: [
            _tabs(),
            const SizedBox(height: 18),
            TextField(
              controller: _search,
              maxLength: 80,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submitSearch(),
              decoration: InputDecoration(
                hintText: 'Search connections',
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.search,
                  color: searchGreen,
                ),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: _submitSearch,
                  icon: const Icon(Icons.arrow_forward),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_needsLogin)
              _notice(
                'Connections দেখতে login করো।',
                button: 'Sign in',
                action: _login,
              )
            else ...[
                for (final user in _users) _personCard(user),
                if (_error != null)
                  _notice(
                    _error!,
                    button: 'Retry',
                    action: () => _load(
                      more: _page > 0 && _hasMore,
                    ),
                  )
                else if (_users.isEmpty)
                  _notice(
                    _query.isNotEmpty
                        ? 'এই নামে কোনো connection পাওয়া যায়নি।'
                        : _type == 'followers'
                        ? 'এখনো কোনো follower নেই।'
                        : 'এখনো কাউকে follow করা হয়নি।',
                  ),
                if (_loadingMore)
                  const Center(child: CircularProgressIndicator())
                else if (_hasMore && _error == null)
                  OutlinedButton(
                    onPressed: () => _load(more: true),
                    child: const Text('Load more'),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: const {
          'followers': 'Followers',
          'following': 'Following',
        }.entries.map((entry) {
          final selected = _type == entry.key;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                if (_type == entry.key) return;

                setState(() => _type = entry.key);
                _load();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? searchGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : searchInk,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _personCard(Map<String, dynamic> user) {
    final id = CommunityApi.number(user['id']);
    final following = CommunityApi.flag(user['is_following']);
    final self = CommunityApi.flag(user['is_self']);
    final busy = _following.contains(id);

    return searchCard(
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _openProfile(user),
              child: Row(
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
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Lv. ${user['level'] ?? 0}',
                          style: const TextStyle(
                            color: searchGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (CommunityApi.flag(user['is_mutual']))
                          const Text(
                            'You follow each other',
                            style: TextStyle(
                              color: searchGreen,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (self)
            const Text(
              'You',
              style: TextStyle(color: Colors.blueGrey),
            )
          else
            FilledButton(
              onPressed: busy ? null : () => _follow(user),
              style: FilledButton.styleFrom(
                backgroundColor: following
                    ? const Color(0xFFE8F7F1)
                    : searchGreen,
                foregroundColor:
                following ? searchGreen : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: busy
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(following ? 'Following' : 'Follow'),
            ),
        ],
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
            Icons.people_outline,
            color: searchGreen,
            size: 44,
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