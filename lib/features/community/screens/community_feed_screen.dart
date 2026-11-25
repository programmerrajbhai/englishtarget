import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../services/community_auth_service.dart';
import '../widgets/community_content_menu.dart';
import '../widgets/community_feed_post_card.dart';
import '../widgets/community_search_cards.dart';
import 'community_create_post_screen.dart';
import 'community_discussion_screen.dart';
import 'community_login_screen.dart';
import 'community_notifications_screen.dart';
import 'community_profile_screen.dart';
import 'community_search_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() =>
      _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  static const mint = Color(0xFFE8F7F1);

  static const categories = {
    '': 'All',
    'ask_doubt': 'Ask Doubt',
    'speaking': 'Speaking',
    'vocabulary': 'Vocabulary',
    'notes': 'Notes',
  };

  final _posts = <Map<String, dynamic>>[];
  final _liking = <int>{};

  String _type = 'for_you';
  String _category = '';
  String? _error;

  int _page = 0;
  int _generation = 0;

  bool _guest = true;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
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
        _page = 0;
        _hasMore = false;
      }
    });

    try {
      final data = await CommunityApi.feed(
        page: nextPage,
        type: _type,
        category: _category,
      );

      final token = await CommunityAuthService.getToken();

      if (!mounted || generation != _generation) return;

      final rows = data['posts'];

      if (rows is! List) {
        throw Exception('Feed response সঠিক নয়।');
      }

      setState(() {
        final ids = _posts.map((post) => '${post['id']}').toSet();

        for (final row in rows) {
          if (row is Map && ids.add('${row['id']}')) {
            _posts.add(Map<String, dynamic>.from(row));
          }
        }

        _guest = data.containsKey('is_guest')
            ? CommunityApi.flag(data['is_guest'])
            : token == null || token.isEmpty;

        _page = nextPage;

        final pagination = data['pagination'];
        _hasMore = pagination is Map &&
            CommunityApi.flag(pagination['has_more']);
      });
    } on LoginRequired {
      if (!mounted || generation != _generation) return;

      if (_type == 'following') {
        setState(() {
          _guest = true;
          _type = 'for_you';
        });

        _message('Following feed দেখতে login করো।');
        await _load();
        return;
      }

      setState(() {
        _guest = true;
        _error = 'Server feed দেখতে login চাইছে। '
            'Public feed API update হয়েছে কি না দেখো।';
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

  Future<bool> _ensureLogin() async {
    final token = await CommunityAuthService.getToken();

    if (!mounted) return false;
    if (token != null && token.isNotEmpty) return true;

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CommunityLoginScreen(),
      ),
    );

    if (!mounted || success != true) return false;

    await _load();
    return mounted;
  }

  Future<void> _open(
      Widget screen, {
        bool requiresLogin = false,
      }) async {
    if (_opening) return;

    setState(() => _opening = true);

    try {
      if (requiresLogin && !await _ensureLogin()) return;
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );

      if (mounted) await _load();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _selectFeed(String type) async {
    if (_type == type || _opening) return;

    if (type == 'following') {
      setState(() => _opening = true);

      try {
        if (!await _ensureLogin()) return;
      } finally {
        if (mounted) setState(() => _opening = false);
      }
    }

    if (!mounted) return;

    setState(() => _type = type);
    await _load();
  }

  Future<void> _like(Map<String, dynamic> post) async {
    final id = CommunityApi.number(post['id']);

    if (_liking.contains(id) || _opening) return;

    if (_guest) {
      await _open(const CommunityLoginScreen());
      return;
    }

    setState(() => _liking.add(id));

    try {
      final data = await CommunityApi.like(id);

      if (!mounted) return;

      setState(() {
        for (final current in _posts) {
          if (CommunityApi.number(current['id']) == id) {
            current['is_liked'] =
                CommunityApi.flag(data['is_liked']);
            current['likes_count'] =
                CommunityApi.number(data['likes_count']);
          }
        }
      });
    } on LoginRequired {
      if (!mounted) return;

      _message('Session শেষ হয়েছে। আবার login করো।');
      await _load();
    } catch (e) {
      if (!mounted) return;

      _message(CommunityApi.errorText(e));
      await _load();
    } finally {
      if (mounted) setState(() => _liking.remove(id));
    }
  }

  Future<void> _postMenu(Map<String, dynamic> post) async {
    final id = CommunityApi.number(post['id']);

    if (_opening || _liking.contains(id)) return;

    setState(() => _opening = true);

    try {
      if (!await _ensureLogin() || !mounted) return;

      // Login বা account state বদলালে পুরোনো ownership ব্যবহার নয়।
      final data = await CommunityApi.request(
        'community/get_post.php',
        query: {'post_id': '$id'},
        guestRetry: false,
      );

      if (!mounted) return;

      final fresh = data['post'];

      if (fresh is! Map) {
        throw Exception('Post পাওয়া যায়নি।');
      }

      final result = await CommunityContentMenu.show(
        context,
        isComment: false,
        isOwner: CommunityApi.flag(fresh['is_owner']),
        contentId: id,
        authorId: CommunityApi.number(fresh['author_id']),
      );

      if (!mounted || result == CommunityMenuResult.cancelled) return;

      _message(
        result == CommunityMenuResult.blocked
            ? 'User blocked'
            : result == CommunityMenuResult.postRemoved
            ? 'Post feed থেকে সরানো হয়েছে'
            : 'Action completed',
      );

      await _load();
    } on LoginRequired {
      if (!mounted) return;

      _message('Session শেষ হয়েছে। আবার login করো।');
      await _load();
    } catch (e) {
      if (!mounted) return;

      _message(CommunityApi.errorText(e));

      // Block toggle বা অন্য mutation automatic retry নয়।
      await _load();
    } finally {
      if (mounted) setState(() => _opening = false);
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
      backgroundColor: mint,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _opening
            ? null
            : () => _open(
          const CommunityCreatePostScreen(),
          requiresLogin: true,
        ),
        backgroundColor: searchGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Create Post'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: searchGreen,
          onRefresh: () async {
            if (!_opening) await _load();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
            children: [
              _header(),
              const SizedBox(height: 18),
              _feedTabs(),
              const SizedBox(height: 12),
              _categoryTabs(),
              const SizedBox(height: 16),
              if (_opening) const LinearProgressIndicator(),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                for (final post in _posts)
                  CommunityFeedPostCard(
                    key: ValueKey(post['id']),
                    post: post,
                    disabled: _opening,
                    liking: _liking.contains(
                      CommunityApi.number(post['id']),
                    ),
                    onOpen: () => _open(
                      CommunityDiscussionScreen(
                        postId: CommunityApi.number(post['id']),
                      ),
                    ),
                    onAuthor: () => _open(
                      CommunityProfileScreen(
                        userId: CommunityApi.number(post['author_id']),
                      ),
                      requiresLogin: true,
                    ),
                    onLike: () => _like(post),
                    onMenu: () => _postMenu(post),
                  ),
                if (_error != null)
                  _notice(_error!, retry: true)
                else if (_posts.isEmpty)
                  _notice(
                    _type == 'following'
                        ? 'এখনো কোনো post নেই।\n'
                        'Search থেকে অন্য learners-কে follow করো।'
                        : 'এখানে এখনো কোনো post নেই।\n'
                        'তোমার প্রশ্ন বা অভিজ্ঞতা share করো।',
                  ),
                if (_loadingMore)
                  const Center(child: CircularProgressIndicator())
                else if (_hasMore && _error == null)
                  OutlinedButton(
                    onPressed: _opening
                        ? null
                        : () => _load(more: true),
                    child: const Text('Load more'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Community',
                style: TextStyle(
                  color: searchInk,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Search community',
              onPressed: _opening
                  ? null
                  : () => _open(const CommunitySearchScreen()),
              icon: const Icon(Icons.search, color: searchInk),
            ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: _opening
                  ? null
                  : () => _open(
                const CommunityNotificationsScreen(),
                requiresLogin: true,
              ),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: searchInk,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Learn, ask and grow together',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 12,
                ),
              ),
            ),
            if (_guest)
              TextButton(
                onPressed: _opening
                    ? null
                    : () => _open(const CommunityLoginScreen()),
                child: const Text(
                  'Sign in',
                  style: TextStyle(color: searchGreen),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _feedTabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: const {
          'for_you': 'For you',
          'following': 'Following',
        }.entries.map((entry) {
          final selected = _type == entry.key;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _opening
                  ? null
                  : () => _selectFeed(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 13),
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

  Widget _categoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: _category == entry.key,
              showCheckmark: false,
              selectedColor: const Color(0xFFC9EED9),
              backgroundColor: Colors.white,
              label: Text(entry.value),
              labelStyle: const TextStyle(
                color: searchInk,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              onSelected: _opening
                  ? null
                  : (_) {
                if (_category == entry.key) return;
                setState(() => _category = entry.key);
                _load();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _notice(String text, {bool retry = false}) {
    return searchCard(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              retry ? Icons.cloud_off : Icons.forum_outlined,
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
            if (retry) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _opening
                    ? null
                    : () => _load(
                  more: _posts.isNotEmpty && _hasMore,
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}