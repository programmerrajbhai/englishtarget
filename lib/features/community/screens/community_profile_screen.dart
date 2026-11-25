import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../widgets/community_search_cards.dart';
import 'community_blocked_users_screen.dart';
import 'community_connections_screen.dart';
import 'community_discussion_screen.dart';
import 'community_edit_profile_screen.dart';
import 'community_login_screen.dart';

class CommunityProfileScreen extends StatefulWidget {
  // null হলে নিজের profile।
  final int? userId;
  final ValueChanged<Map<String, dynamic>>? onChanged;

  const CommunityProfileScreen({
    super.key,
    this.userId,
    this.onChanged,
  });

  @override
  State<CommunityProfileScreen> createState() =>
      _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityProfileScreen> {
  static const mint = Color(0xFFE8F7F1);

  final _posts = <Map<String, dynamic>>[];

  Map<String, dynamic>? _profile;
  String? _error;

  int _viewerId = 0;
  int _page = 0;
  int _generation = 0;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _needsLogin = false;
  bool _working = false;
  bool _opening = false;

  bool get _self =>
      _profile != null &&
          CommunityApi.number(_profile!['id']) == _viewerId;

  bool get _disabled =>
      _working || _opening || _loading || _loadingMore;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _publish() {
    if (_profile != null) {
      widget.onChanged?.call(
        Map<String, dynamic>.from(_profile!),
      );
    }
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
        _profile = null;
        _posts.clear();
        _page = 0;
        _hasMore = false;
      }
    });

    try {
      final own = await CommunityApi.request(
        'users/profile.php',
        query: {
          'page': widget.userId == null ? '$nextPage' : '1',
          'limit': widget.userId == null ? '10' : '1',
        },
        guestRetry: false,
      );

      if (!mounted || generation != _generation) return;

      final ownProfile = own['profile'];

      if (ownProfile is! Map) {
        throw Exception('Account response সঠিক নয়।');
      }

      final viewerId = CommunityApi.number(ownProfile['id']);

      final data = widget.userId == null
          ? own
          : await CommunityApi.request(
        'users/profile.php',
        query: {
          'user_id': '${widget.userId}',
          'page': '$nextPage',
          'limit': '10',
        },
        guestRetry: false,
      );

      if (!mounted || generation != _generation) return;

      final profile = data['profile'];
      final rows = data['posts'];

      if (profile is! Map || rows is! List) {
        throw Exception('Profile response সঠিক নয়।');
      }

      setState(() {
        _viewerId = viewerId;
        _needsLogin = false;
        _profile = Map<String, dynamic>.from(profile);

        final ids = _posts.map((post) => '${post['id']}').toSet();

        for (final row in rows) {
          if (row is Map && ids.add('${row['id']}')) {
            _posts.add(Map<String, dynamic>.from(row));
          }
        }

        _page = nextPage;
        _hasMore = rows.length == 10;
      });

      _publish();
    } on LoginRequired {
      if (mounted && generation == _generation) {
        setState(() {
          _needsLogin = true;
          _profile = null;
          _posts.clear();
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
    if (_opening) return;
    setState(() => _opening = true);

    try {
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const CommunityLoginScreen(),
        ),
      );

      if (mounted && success == true) await _load();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _open(Widget screen) async {
    if (_disabled) return;
    setState(() => _opening = true);

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );

      if (mounted) await _load();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<bool> _confirm(
      String title,
      String message,
      String label,
      ) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(label),
          ),
        ],
      ),
    ) ==
        true;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_disabled || _profile == null) return;
    setState(() => _working = true);

    try {
      await action();
    } on LoginRequired {
      if (mounted) await _load();
    } catch (e) {
      if (!mounted) return;

      _message(CommunityApi.errorText(e));

      // Toggle নিজে থেকে retry নয়; fresh status আনবে।
      await _load();
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _follow() async {
    if (_self) return;

    await _run(() async {
      final profile = _profile!;
      final following = CommunityApi.flag(profile['is_following']);

      if (following) {
        final confirmed = await _confirm(
          'Unfollow ${profile['name']}?',
          'তাঁর posts তোমার Following feed-এ আর আসবে না।',
          'Unfollow',
        );

        if (!confirmed || !mounted) return;
      }

      final result = await CommunityApi.request(
        'community/toggle_follow.php',
        body: {
          'user_id': CommunityApi.number(profile['id']),
        },
      );

      if (!mounted) return;

      setState(() {
        _profile!['is_following'] =
            CommunityApi.flag(result['is_following']);
        _profile!['followers_count'] =
            CommunityApi.number(result['followers_count']);
      });

      _publish();
    });
  }

  Future<void> _block() async {
    if (_self) return;

    await _run(() async {
      final profile = _profile!;

      final confirmed = await _confirm(
        'Block ${profile['name']}?',
        'তোমার account থেকে তাঁর content লুকানো হবে। '
            'দুজনের Follow সম্পর্কও সরিয়ে দেওয়া হবে। '
            'পরে Your blocked users থেকে Unblock করতে পারবে।',
        'Block',
      );

      if (!confirmed || !mounted) return;

      final result = await CommunityApi.request(
        'community/toggle_block.php',
        body: {
          'user_id': CommunityApi.number(profile['id']),
        },
      );

      if (!mounted) return;

      if (CommunityApi.flag(result['is_blocked'])) {
        _message('User blocked');
        Navigator.pop(context, true);
      } else {
        _message('Block status বদলেছে। Profile refresh করা হচ্ছে।');
        await _load();
      }
    });
  }

  void _connections(String type) {
    if (_profile == null) return;

    _open(
      CommunityConnectionsScreen(
        userId: CommunityApi.number(_profile!['id']),
        initialType: type,
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: Text(_self ? 'My Profile' : 'Member Profile'),
        backgroundColor: mint,
        foregroundColor: searchInk,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            enabled: !_disabled,
            tooltip: 'Profile options',
            onSelected: (value) {
              if (value == 'mine') {
                _open(const CommunityProfileScreen());
              } else if (value == 'blocked') {
                _open(const CommunityBlockedUsersScreen());
              } else if (value == 'block') {
                _block();
              }
            },
            itemBuilder: (_) => [
              if (!_self)
                const PopupMenuItem(
                  value: 'mine',
                  child: Text('My profile'),
                ),
              const PopupMenuItem(
                value: 'blocked',
                child: Text('Your blocked users'),
              ),
              if (_profile != null && !_self)
                const PopupMenuItem(
                  value: 'block',
                  child: Text(
                    'Block this user',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: searchGreen,
        onRefresh: () async {
          if (!_working && !_opening) await _load();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            if (_working) const LinearProgressIndicator(),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_needsLogin)
              _notice(
                'Profile দেখতে login করো।',
                label: 'Sign in',
                action: _opening ? null : _login,
              )
            else ...[
                if (_profile != null) ...[
                  _hero(),
                  if (_self)
                    searchCard(
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.shield_outlined,
                          color: searchGreen,
                        ),
                        title: const Text(
                          'Blocked users',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text(
                          'Manage your block list',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _disabled
                            ? null
                            : () => _open(
                          const CommunityBlockedUsersScreen(),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          color: searchGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Posts (${_profile!['posts_count'] ?? 0})',
                          style: const TextStyle(
                            color: searchInk,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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
                    _notice(
                      _self
                          ? 'তোমার প্রথম learning post share করো।'
                          : 'এখনো কোনো post নেই।',
                    ),
                ],
                if (_error != null)
                  _notice(
                    _error!,
                    label: 'Retry',
                    action: _disabled
                        ? null
                        : () => _load(
                      more: _page > 0 && _hasMore,
                    ),
                  ),
                if (_loadingMore)
                  const Center(child: CircularProgressIndicator())
                else if (_hasMore && _error == null)
                  OutlinedButton(
                    onPressed: _disabled
                        ? null
                        : () => _load(more: true),
                    child: const Text('Load more posts'),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    final profile = _profile!;
    final avatar = CommunityApi.mediaUrl(profile['avatar_key']);
    final bio = '${profile['bio'] ?? ''}'.trim();
    final following = CommunityApi.flag(profile['is_following']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A004D29),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF006D3A),
                        Color(0xFF00A563),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: Colors.white,
                          size: 27,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Keep learning. Keep growing.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: avatar == null
                            ? const ColoredBox(
                          color: mint,
                          child: Icon(
                            Icons.person,
                            color: searchGreen,
                            size: 54,
                          ),
                        )
                            : Image.network(
                          avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const ColoredBox(
                            color: mint,
                            child: Icon(
                              Icons.person,
                              color: searchGreen,
                              size: 54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: Column(
              children: [
                Text(
                  '${profile['name'] ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: searchInk,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: mint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Lv. ${profile['level'] ?? 0}  ·  '
                        '${profile['xp'] ?? 0} XP',
                    style: const TextStyle(
                      color: searchGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (bio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (_self)
                  _primaryButton(
                    'Edit profile',
                    Icons.edit_outlined,
                        () => _open(
                      CommunityEditProfileScreen(
                        profile: Map<String, dynamic>.from(profile),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _primaryButton(
                          following ? 'Following' : 'Follow',
                          following
                              ? Icons.check
                              : Icons.person_add_alt_1,
                          _follow,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.outlined(
                        tooltip: 'Block user',
                        onPressed: _disabled ? null : _block,
                        icon: const Icon(
                          Icons.block,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
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
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(
      String label,
      IconData icon,
      VoidCallback action,
      ) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _disabled ? null : action,
        style: FilledButton.styleFrom(
          backgroundColor: searchGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _stat(
      String label,
      dynamic value, {
        VoidCallback? onTap,
      }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _disabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            children: [
              Text(
                '${value ?? 0}',
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
        String? label,
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