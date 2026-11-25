import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../widgets/community_search_cards.dart';
import 'community_connections_screen.dart';
import 'community_discussion_screen.dart';
import 'community_login_screen.dart';

class CommunityProfileScreen extends StatefulWidget {
  final int userId;
  final ValueChanged<Map<String, dynamic>>? onChanged;

  const CommunityProfileScreen({
    super.key,
    required this.userId,
    this.onChanged,
  });

  @override
  State<CommunityProfileScreen> createState() =>
      _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityProfileScreen> {
  final _posts = <Map<String, dynamic>>[];

  Map<String, dynamic>? _profile;
  String? _error;

  int _viewerId = 0;
  int _page = 0;
  int _generation = 0;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _followingBusy = false;
  bool _needsLogin = false;
  bool _opening = false;

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
        _posts.clear();
        _hasMore = false;
        _page = 0;
      }
    });

    try {
      final results = await Future.wait([
        CommunityApi.request(
          'users/profile.php',
          query: {
            'user_id': '${widget.userId}',
            'page': '$nextPage',
            'limit': '10',
          },
          guestRetry: false,
        ),
        CommunityApi.request(
          'users/profile.php',
          query: {'limit': '1'},
          guestRetry: false,
        ),
      ]);

      if (!mounted || generation != _generation) return;

      final data = results[0];
      final ownProfile = results[1]['profile'];
      final rawProfile = data['profile'];
      final rawPosts = data['posts'];

      if (rawProfile is! Map ||
          rawPosts is! List ||
          ownProfile is! Map) {
        throw Exception('Profile response সঠিক নয়।');
      }

      setState(() {
        _needsLogin = false;
        _viewerId = CommunityApi.number(ownProfile['id']);
        _profile = Map<String, dynamic>.from(rawProfile);

        final ids = _posts.map((post) => '${post['id']}').toSet();

        for (final item in rawPosts) {
          if (item is Map && ids.add('${item['id']}')) {
            _posts.add(Map<String, dynamic>.from(item));
          }
        }

        _page = nextPage;
        _hasMore = rawPosts.length == 10;
      });

      widget.onChanged?.call(Map<String, dynamic>.from(_profile!));
    } on LoginRequired {
      if (!mounted || generation != _generation) return;

      setState(() {
        _needsLogin = true;
        _profile = null;
        _posts.clear();
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

  Future<void> _login() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CommunityLoginScreen(),
      ),
    );

    if (mounted && result == true) await _load();
  }

  Future<void> _follow() async {
    if (_followingBusy || _loading || _loadingMore) return;

    setState(() => _followingBusy = true);

    try {
      await CommunityApi.request(
        'community/toggle_follow.php',
        body: {'user_id': widget.userId},
      );

      if (mounted) await _load();
    } on LoginRequired {
      if (!mounted) return;

      _generation++;

      setState(() {
        _needsLogin = true;
        _profile = null;
        _posts.clear();
        _hasMore = false;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(CommunityApi.errorText(e))),
      );

      await _load();
    } finally {
      if (mounted) setState(() => _followingBusy = false);
    }
  }

  Future<void> _open(Widget screen) async {
    if (_opening || _followingBusy) return;
    _opening = true;

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );

      if (mounted) await _load();
    } finally {
      _opening = false;
    }
  }

  void _connections(String type) {
    _open(
      CommunityConnectionsScreen(
        userId: widget.userId,
        initialType: type,
      ),
    );
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
          'Member Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: searchGreen,
        onRefresh: () => _load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_needsLogin)
              _notice(
                'Profile দেখতে login করো।',
                button: 'Sign in',
                action: _login,
              )
            else ...[
                if (_profile != null) ...[
                  _profileCard(),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16, top: 8),
                    child: Text(
                      'Posts',
                      style: TextStyle(
                        color: searchInk,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  for (final post in _posts)
                    SearchPostCard(
                      post: {
                        ...post,
                        'author_id': _profile!['id'],
                        'author_name': _profile!['name'],
                        'author_avatar_key': _profile!['avatar_key'],
                        'author_level': _profile!['level'],
                      },
                      onOpen: () => _open(
                        CommunityDiscussionScreen(
                          postId: CommunityApi.number(post['id']),
                        ),
                      ),
                    ),
                  if (_posts.isEmpty && _error == null)
                    _notice('এখনো কোনো post নেই।'),
                ],
                if (_error != null)
                  _notice(
                    _error!,
                    button: 'Retry',
                    action: () => _load(
                      more: _page > 0 && _hasMore,
                    ),
                  ),
                if (_loadingMore)
                  const Center(child: CircularProgressIndicator())
                else if (_hasMore && _error == null)
                  OutlinedButton(
                    onPressed: () => _load(more: true),
                    child: const Text('Load more posts'),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    final profile = _profile!;
    final self = CommunityApi.number(profile['id']) == _viewerId;
    final following = CommunityApi.flag(profile['is_following']);
    final avatar = CommunityApi.mediaUrl(profile['avatar_key']);
    final bio = '${profile['bio'] ?? ''}'.trim();

    return searchCard(
      Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFE8F7F1),
            child: ClipOval(
              child: SizedBox(
                width: 96,
                height: 96,
                child: avatar == null
                    ? const Icon(
                  Icons.person,
                  size: 52,
                  color: searchGreen,
                )
                    : Image.network(
                  avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 52,
                    color: searchGreen,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${profile['name'] ?? ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: searchInk,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lv. ${profile['level'] ?? 0}',
            style: const TextStyle(
              color: searchGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                bio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  height: 1.5,
                ),
              ),
            ),
          if (!self) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _followingBusy || _loadingMore
                  ? null
                  : _follow,
              style: FilledButton.styleFrom(
                backgroundColor: searchGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
              ),
              icon: _followingBusy
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Icon(
                following
                    ? Icons.check
                    : Icons.person_add_alt_1,
              ),
              label: Text(following ? 'Following' : 'Follow'),
            ),
          ],
          const Divider(height: 32),
          Row(
            children: [
              _stat('Posts', profile['posts_count']),
              _stat(
                'Followers',
                profile['followers_count'],
                onTap: () => _connections('followers'),
              ),
              _stat(
                'Following',
                profile['following_count'],
                onTap: () => _connections('following'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(
      String label,
      dynamic count, {
        VoidCallback? onTap,
      }) {
    return Expanded(
      child: InkWell(
        onTap: _followingBusy ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                '${count ?? 0}',
                style: const TextStyle(
                  color: searchInk,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: onTap == null
                      ? Colors.blueGrey
                      : searchGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
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