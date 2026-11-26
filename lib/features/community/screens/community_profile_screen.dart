import 'package:flutter/material.dart';

import '../../../core/ads/banner_ad_widget.dart';
import '../../coins/screens/coin_wallet_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../services/community_api.dart';
import '../services/community_auth_service.dart';
import '../widgets/community_search_cards.dart';

import 'community_blocked_users_screen.dart';
import 'community_connections_screen.dart';
import 'community_create_post_screen.dart';
import 'community_discussion_screen.dart';
import 'community_edit_profile_screen.dart';
import 'community_feed_screen.dart';
import 'community_login_screen.dart';
import 'community_notifications_screen.dart';
import 'community_search_screen.dart';

typedef JsonMap = Map<String, dynamic>;

class CommunityProfileScreen extends StatefulWidget {
  final int? userId;
  final ValueChanged<JsonMap>? onChanged;

  const CommunityProfileScreen({
    super.key,
    this.userId,
    this.onChanged,
  });

  @override
  State<CommunityProfileScreen> createState() =>
      _CommunityProfileScreenState();
}

class _CommunityProfileScreenState
    extends State<CommunityProfileScreen> {
  static const mint = Color(0xFFE8F7F1);

  final List<JsonMap> _posts = [];

  JsonMap? _profile;
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
        JsonMap.from(_profile!),
      );
    }
  }

  Future<void> _load({bool more = false}) async {
    if (!mounted) return;

    if (more && (_loading || _loadingMore || !_hasMore)) {
      return;
    }

    final generation = ++_generation;
    final nextPage = more ? _page + 1 : 1;

    setState(() {
      _error = null;
      _loading = !more;
      _loadingMore = more;
      _needsLogin = false;

      if (!more) {
        _profile = null;
        _posts.clear();
        _page = 0;
        _hasMore = false;
      }
    });

    try {
      final token = await CommunityAuthService.getToken();
      if (!mounted || generation != _generation) return;

      if (token == null || token.isEmpty) {
        setState(() {
          _needsLogin = true;
          _profile = null;
          _posts.clear();
          _hasMore = false;
        });
        return;
      }

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
        _profile = JsonMap.from(profile);

        final ids = _posts.map((post) => '${post['id']}').toSet();

        for (final row in rows) {
          if (row is Map && ids.add('${row['id']}')) {
            _posts.add(JsonMap.from(row));
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
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _error = CommunityApi.errorText(error));
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
    if (_disabled) return;
    setState(() => _opening = true);

    try {
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const CommunityLoginScreen(),
        ),
      );

      if (mounted && success == true) {
        await _load();
      }
    } finally {
      if (mounted) {
        setState(() => _opening = false);
      }
    }
  }

  Future<void> _openWithAuth(Widget screen) async {
    if (_disabled) return;

    final token = await CommunityAuthService.getToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      setState(() => _opening = true);
      bool? success;
      try {
        success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const CommunityLoginScreen(),
          ),
        );
      } finally {
        if (mounted) setState(() => _opening = false);
      }

      if (!mounted || success != true) return;
    }

    await _open(screen);
  }

  Future<void> _logout() async {
    if (_disabled) return;

    final confirmed = await _confirm(
      'Log out?',
      'তুমি কি account থেকে log out করতে চাও? '
          'পরে আবার email বা phone দিয়ে sign in করতে পারবে।',
      'Log out',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    setState(() => _working = true);

    try {
      await CommunityAuthService.clearSession();

      if (!mounted) return;

      _message('Logged out successfully');

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _working = false;
          _needsLogin = true;
          _profile = null;
          _posts.clear();
          _hasMore = false;
        });
      }
    } catch (error) {
      if (mounted) {
        _message(CommunityApi.errorText(error));
      }
    } finally {
      if (mounted) {
        setState(() => _working = false);
      }
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

      if (mounted) {
        await _load();
      }
    } finally {
      if (mounted) {
        setState(() => _opening = false);
      }
    }
  }

  Future<bool> _confirm(
      String title,
      String message,
      String label, {
        bool isDestructive = false,
      }) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            )
                : null,
            onPressed: () =>
                Navigator.pop(dialogContext, true),
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
      if (mounted) {
        await _load();
      }
    } catch (error) {
      if (!mounted) return;

      _message(CommunityApi.errorText(error));
      await _load();
    } finally {
      if (mounted) {
        setState(() => _working = false);
      }
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
            'পরে Blocked users থেকে Unblock করতে পারবে।',
        'Block',
        isDestructive: true,
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
        _message('Block status বদলেছে। Profile refresh হচ্ছে।');
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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _needsLogin
        ? 'Profile'
        : _self
        ? 'My Profile'
        : 'Member Profile';

    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: mint,
        foregroundColor: searchInk,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_needsLogin)
            IconButton(
              tooltip: 'Settings',
              onPressed: _disabled
                  ? null
                  : () => _open(const SettingsScreen()),
              icon: const Icon(Icons.settings_outlined),
            )
          else
            PopupMenuButton<String>(
              enabled: !_disabled,
              tooltip: 'Profile options',
              onSelected: (value) {
                switch (value) {
                  case 'mine':
                    _open(const CommunityProfileScreen());
                    break;
                  case 'coins':
                    _open(const CoinWalletScreen());
                    break;
                  case 'settings':
                    _open(const SettingsScreen());
                    break;
                  case 'blocked':
                    _open(const CommunityBlockedUsersScreen());
                    break;
                  case 'logout':
                    _logout();
                    break;
                  case 'block':
                    _block();
                    break;
                }
              },
              itemBuilder: (_) => [
                if (!_self)
                  const PopupMenuItem(
                    value: 'mine',
                    child: Text('My profile'),
                  ),
                if (_self)
                  const PopupMenuItem(
                    value: 'coins',
                    child: Text('My Coins'),
                  ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Settings & Privacy'),
                ),
                const PopupMenuItem(
                  value: 'blocked',
                  child: Text('Your blocked users'),
                ),
                if (_self)
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 19,
                          color: Colors.redAccent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Log out',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
      bottomNavigationBar: const BannerAdWidget(),
      body: RefreshIndicator(
        color: searchGreen,
        onRefresh: () async {
          if (!_disabled) {
            await _load();
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            if (_working || _opening)
              const LinearProgressIndicator(color: searchGreen),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(60),
                child: Center(
                  child: CircularProgressIndicator(color: searchGreen),
                ),
              )
            else if (_needsLogin)
              _guestDashboard()
            else ...[
                if (_profile != null) ...[
                  _hero(),

                  // Only your own profile shows these shortcuts and account controls.
                  if (_self) ...[
                    _coinsCard(),
                    _quickShortcutsSection(isGuest: false),
                    _settingsCard(),
                    _blockedCard(),
                    _logoutCard(),
                  ],

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
                  const Center(
                    child: CircularProgressIndicator(color: searchGreen),
                  )
                else if (_hasMore && _error == null)
                  OutlinedButton(
                    onPressed:
                    _disabled ? null : () => _load(more: true),
                    child: const Text('Load more posts'),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _guestDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Guest Profile Hero Card
        Container(
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
                height: 168,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      height: 118,
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
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Learn English. Earn Coins. Grow Together.',
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
                        child: const CircleAvatar(
                          radius: 46,
                          backgroundColor: mint,
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: searchGreen,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                child: Column(
                  children: [
                    const Text(
                      'Guest Learner',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: searchInk,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: mint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Guest Mode · Free Access',
                        style: TextStyle(
                          color: searchGreen,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sign in করলে তোমার learning progress, daily coins, '
                          'এবং community posts সব ডিভাইসে সেভ থাকবে।',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: FilledButton.icon(
                            onPressed: _disabled ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: searchGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.login_rounded, size: 20),
                            label: const Text(
                              'Sign In / Join',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            onPressed: _disabled
                                ? null
                                : () => _open(const CommunityFeedScreen()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: searchGreen,
                              side: const BorderSide(color: searchGreen),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.forum_outlined, size: 19),
                            label: const Text(
                              'Feed',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    const Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Free',
                                style: TextStyle(
                                  color: searchInk,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'All Lessons',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Daily',
                                style: TextStyle(
                                  color: searchGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Coin Rewards',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Open',
                                style: TextStyle(
                                  color: searchInk,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Community',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Coins Promo Banner
        _coinsCard(isGuest: true),

        // Quick App Shortcuts Grid
        _quickShortcutsSection(isGuest: true),

        // Account & App Options Card
        searchCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'App & Account',
                style: TextStyle(
                  color: searchInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _tileIcon(
                  Icons.notifications_outlined,
                  searchGreen,
                ),
                title: const Text(
                  'Notifications',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Replies, likes & follower alerts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _disabled
                    ? null
                    : () => _openWithAuth(
                  const CommunityNotificationsScreen(),
                ),
              ),
              const Divider(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _tileIcon(
                  Icons.settings_outlined,
                  const Color(0xFF2563EB),
                ),
                title: const Text(
                  'Settings & Privacy',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Privacy policy, support & account options',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _disabled
                    ? null
                    : () => _open(const SettingsScreen()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickShortcutsSection({required bool isGuest}) {
    return searchCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: searchGreen, size: 21),
              SizedBox(width: 6),
              Text(
                'Quick Shortcuts',
                style: TextStyle(
                  color: searchInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _shortcutTile(
                  icon: Icons.forum_rounded,
                  color: searchGreen,
                  title: 'Community Feed',
                  subtitle: 'Explore posts',
                  onTap: () => _open(const CommunityFeedScreen()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _shortcutTile(
                  icon: Icons.search_rounded,
                  color: const Color(0xFF0284C7),
                  title: 'Search',
                  subtitle: 'People & topics',
                  onTap: () => _open(const CommunitySearchScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _shortcutTile(
                  icon: Icons.edit_note_rounded,
                  color: const Color(0xFF7C3AED),
                  title: 'Create Post',
                  subtitle: isGuest ? 'Sign in to post' : 'Ask or share',
                  onTap: () => _openWithAuth(
                    const CommunityCreatePostScreen(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _shortcutTile(
                  icon: Icons.notifications_active_outlined,
                  color: const Color(0xFFD97706),
                  title: 'Notifications',
                  subtitle: isGuest ? 'Sign in to view' : 'Activity alerts',
                  onTap: () => _openWithAuth(
                    const CommunityNotificationsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shortcutTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF6FBF9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _disabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: searchInk,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tileIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }

  Widget _coinsCard({bool isGuest = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: const Color(0xFFFFF7DF),
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _disabled
              ? null
              : () => isGuest
              ? _openWithAuth(const CoinWalletScreen())
              : _open(const CoinWalletScreen()),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFFFFE6A3),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: Color(0xFFB67C00),
                    size: 31,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Coins & Rewards',
                        style: TextStyle(
                          color: searchInk,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGuest
                            ? 'Sign in to claim daily coins & rewards'
                            : 'Daily reward, balance & history',
                        style: const TextStyle(
                          color: Color(0xFF887347),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB67C00),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsCard() {
    return searchCard(
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _tileIcon(
          Icons.settings_outlined,
          const Color(0xFF2563EB),
        ),
        title: const Text(
          'Settings & Privacy',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('Privacy policy, support & delete account'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _disabled
            ? null
            : () => _open(const SettingsScreen()),
      ),
    );
  }

  Widget _blockedCard() {
    return searchCard(
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _tileIcon(
          Icons.shield_outlined,
          searchGreen,
        ),
        title: const Text(
          'Blocked users',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('Manage your block list'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _disabled
            ? null
            : () => _open(const CommunityBlockedUsersScreen()),
      ),
    );
  }

  Widget _logoutCard() {
    return searchCard(
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFECEC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Colors.redAccent,
            size: 21,
          ),
        ),
        title: const Text(
          'Log out',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: const Text('Sign out from this device'),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.redAccent,
        ),
        onTap: _disabled ? null : _logout,
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
                            ? _avatarPlaceholder()
                            : Image.network(
                          avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _avatarPlaceholder(),
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
                        profile: JsonMap.from(profile),
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

  Widget _avatarPlaceholder() {
    return const ColoredBox(
      color: mint,
      child: Icon(
        Icons.person,
        color: searchGreen,
        size: 54,
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
                  color:
                  onTap == null ? Colors.blueGrey : searchGreen,
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