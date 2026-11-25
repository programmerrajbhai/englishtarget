import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../services/community_auth_service.dart';

import '../widgets/community_content_menu.dart';
import '../widgets/community_feed_header.dart';
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
  State<CommunityFeedScreen> createState() {
    return _CommunityFeedScreenState();
  }
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  static const Color background = Color(0xFFE4F6EF);

  static const Map<String, String> categories = {
    '': 'All',
    'ask_doubt': 'Ask Doubt',
    'speaking': 'Speaking',
    'vocabulary': 'Vocabulary',
    'notes': 'Notes',
  };

  final List<Map<String, dynamic>> _posts = [];
  final Set<int> _liking = {};

  String _type = 'for_you';
  String _category = '';
  String? _error;

  int _page = 0;
  int _generation = 0;

  bool _guest = true;
  bool _sessionChecked = false;
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
    if (!mounted) return;

    if (more && (_loading || _loadingMore || !_hasMore)) {
      return;
    }

    final int generation = ++_generation;
    final int nextPage = more ? _page + 1 : 1;

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
      final token = await CommunityAuthService.getToken();

      if (!mounted || generation != _generation) return;

      setState(() {
        _guest = token == null || token.isEmpty;
        _sessionChecked = true;
      });

      final data = await CommunityApi.feed(
        page: nextPage,
        type: _type,
        category: _category,
      );

      final currentToken = await CommunityAuthService.getToken();

      if (!mounted || generation != _generation) return;

      final rows = data['posts'];

      if (rows is! List) {
        throw Exception('Feed response সঠিক নয়।');
      }

      setState(() {
        final existingIds = _posts
            .map((post) => CommunityApi.number(post['id']))
            .toSet();

        for (final row in rows) {
          if (row is Map) {
            final post = Map<String, dynamic>.from(row);
            final id = CommunityApi.number(post['id']);

            if (existingIds.add(id)) {
              _posts.add(post);
            }
          }
        }

        if (data.containsKey('is_guest')) {
          _guest = CommunityApi.flag(data['is_guest']);
        } else {
          _guest = currentToken == null || currentToken.isEmpty;
        }

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
        setState(() {
          _error = CommunityApi.errorText(e);
        });
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

    if (token != null && token.isNotEmpty) {
      return true;
    }

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CommunityLoginScreen(),
      ),
    );

    if (!mounted || success != true) {
      return false;
    }

    await _load();
    return mounted;
  }

  Future<void> _open(
      Widget screen, {
        bool requiresLogin = false,
      }) async {
    if (_opening || !mounted) return;

    setState(() {
      _opening = true;
    });

    try {
      if (requiresLogin) {
        final authorized = await _ensureLogin();
        if (!authorized) return;
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );

      if (mounted) {
        await _load();
      }
    } finally {
      if (mounted) {
        setState(() {
          _opening = false;
        });
      }
    }
  }

  Future<void> _selectFeed(String type) async {
    if (_type == type || _opening) return;

    if (type == 'following') {
      setState(() {
        _opening = true;
      });

      try {
        final authorized = await _ensureLogin();
        if (!authorized) return;
      } finally {
        if (mounted) {
          setState(() {
            _opening = false;
          });
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _type = type;
    });

    await _load();
  }

  Future<void> _like(Map<String, dynamic> post) async {
    final id = CommunityApi.number(post['id']);

    if (_liking.contains(id) || _opening) return;

    if (_guest) {
      await _open(const CommunityLoginScreen());
      return;
    }

    setState(() {
      _liking.add(id);
    });

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
      if (mounted) {
        setState(() {
          _liking.remove(id);
        });
      }
    }
  }

  Future<void> _postMenu(Map<String, dynamic> post) async {
    final id = CommunityApi.number(post['id']);

    if (_opening || _liking.contains(id)) return;

    setState(() {
      _opening = true;
    });

    try {
      final authorized = await _ensureLogin();

      if (!authorized || !mounted) return;

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

      if (!mounted || result == CommunityMenuResult.cancelled) {
        return;
      }

      if (result == CommunityMenuResult.blocked) {
        _message('User blocked');
      } else if (result == CommunityMenuResult.postRemoved) {
        _message('Post feed থেকে সরানো হয়েছে');
      } else {
        _message('Action completed');
      }

      await _load();
    } on LoginRequired {
      if (!mounted) return;

      _message('Session শেষ হয়েছে। আবার login করো।');
      await _load();
    } catch (e) {
      if (!mounted) return;

      _message(CommunityApi.errorText(e));
      await _load();
    } finally {
      if (mounted) {
        setState(() {
          _opening = false;
        });
      }
    }
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'community-create-post',
        onPressed: _opening
            ? null
            : () => _open(
          const CommunityCreatePostScreen(),
          requiresLogin: true,
        ),
        backgroundColor: searchGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: const Icon(Icons.edit_outlined, size: 23),
        label: const Text(
          'Create Post',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: searchGreen,
          onRefresh: () async {
            if (!_opening) {
              await _load();
            }
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: _posts.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _topSection();
              }

              if (index == _posts.length + 1) {
                return _footer();
              }

              return _postItem(_posts[index - 1]);
            },
          ),
        ),
      ),
    );
  }

  Widget _topSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityFeedHeader(
          disabled: _opening,
          isGuest: _sessionChecked && _guest,
          onSearch: () => _open(
            const CommunitySearchScreen(),
          ),
          onNotifications: () => _open(
            const CommunityNotificationsScreen(),
            requiresLogin: true,
          ),
          onSignIn: () => _open(
            const CommunityLoginScreen(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: _feedTabs(),
        ),
        _categoryTabs(),
        const SizedBox(height: 22),
        if (_opening)
          const LinearProgressIndicator(
            minHeight: 2,
            color: searchGreen,
          ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(50),
            child: Center(
              child: CircularProgressIndicator(
                color: searchGreen,
              ),
            ),
          ),
      ],
    );
  }

  Widget _postItem(Map<String, dynamic> post) {
    final postId = CommunityApi.number(post['id']);
    final authorId = CommunityApi.number(post['author_id']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: CommunityFeedPostCard(
        key: ValueKey(postId),
        post: post,
        disabled: _opening,
        liking: _liking.contains(postId),
        onOpen: () => _open(
          CommunityDiscussionScreen(postId: postId),
        ),
        onAuthor: () => _open(
          CommunityProfileScreen(userId: authorId),
          requiresLogin: true,
        ),
        onLike: () => _like(post),
        onMenu: () => _postMenu(post),
      ),
    );
  }

  Widget _footer() {
    if (_loading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            _notice(_error!, retry: true),
          if (_error == null && _posts.isEmpty)
            _notice(
              _type == 'following'
                  ? 'এখনো কোনো post নেই।\n'
                  'Search থেকে অন্য learners-কে follow করো।'
                  : 'এখানে এখনো কোনো post নেই।\n'
                  'তোমার প্রশ্ন বা অভিজ্ঞতা share করো।',
            ),
          if (_loadingMore)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(
                  color: searchGreen,
                ),
              ),
            ),
          if (!_loadingMore && _hasMore && _error == null)
            OutlinedButton(
              onPressed: _opening
                  ? null
                  : () => _load(more: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: searchGreen,
                minimumSize: const Size.fromHeight(46),
              ),
              child: const Text('Load more'),
            ),
        ],
      ),
    );
  }

  Widget _feedTabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        children: [
          _feedTab('for_you', 'For you'),
          _feedTab('following', 'Following'),
        ],
      ),
    );
  }

  Widget _feedTab(String value, String label) {
    final selected = _type == value;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: _opening ? null : () => _selectFeed(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: selected ? searchGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : searchInk,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: categories.entries.map((entry) {
          return _categoryItem(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _categoryItem(String value, String label) {
    final selected = _category == value;

    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: Material(
        color: selected
            ? const Color(0xFFC5ECD8)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Semantics(
          selected: selected,
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _opening
                ? null
                : () {
              if (_category == value) return;

              setState(() {
                _category = value;
              });

              _load();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 13,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: searchInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
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
            if (retry)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton(
                  onPressed: _opening
                      ? null
                      : () => _load(
                    more: _posts.isNotEmpty && _hasMore,
                  ),
                  child: const Text('Retry'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}