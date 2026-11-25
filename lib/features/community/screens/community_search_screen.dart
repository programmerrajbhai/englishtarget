import 'dart:async';

import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../widgets/community_search_cards.dart';
import 'community_discussion_screen.dart';
import 'community_login_screen.dart';

class CommunitySearchScreen extends StatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  State<CommunitySearchScreen> createState() =>
      _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends State<CommunitySearchScreen> {
  final _text = TextEditingController();
  final _people = <Map<String, dynamic>>[];
  final _posts = <Map<String, dynamic>>[];
  final _following = <int>{};

  Timer? _debounce;
  String _type = 'all';
  String? _error;
  int _page = 0, _generation = 0;

  bool _loading = false;
  bool _more = false;
  bool _hasMore = false;
  bool _needsLogin = false;

  bool get _validQuery {
    final length = _text.text.trim().runes.length;
    return length >= 2 && length <= 80;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _changed(String _) {
    _debounce?.cancel();
    _generation++;

    setState(() {
      _people.clear();
      _posts.clear();
      _page = 0;
      _hasMore = false;
      _more = false;
      _error = null;
      _loading = _validQuery && !_needsLogin;
    });

    if (_validQuery && !_needsLogin) {
      _debounce = Timer(
        const Duration(milliseconds: 450),
            () => _search(),
      );
    }
  }

  void _merge(
      List<Map<String, dynamic>> target,
      dynamic incoming,
      ) {
    if (incoming is! List) return;

    final ids = target.map((item) => item['id']).toSet();

    for (final item in incoming) {
      if (item is Map && ids.add(item['id'])) {
        target.add(Map<String, dynamic>.from(item));
      }
    }
  }

  Future<void> _search({bool more = false}) async {
    _debounce?.cancel();

    if (!_validQuery) return;
    if (more && (_loading || _more || !_hasMore)) return;

    final generation = ++_generation;
    final nextPage = more ? _page + 1 : 1;
    final query = _text.text.trim();
    final type = _type;

    setState(() {
      _error = null;
      _loading = !more;
      _more = more;

      if (!more) {
        _people.clear();
        _posts.clear();
        _hasMore = false;
      }
    });

    try {
      final data = await CommunityApi.request(
        'community/search.php',
        query: {
          'q': query,
          'type': type,
          'page': '$nextPage',
          'limit': '10',
        },
        guestRetry: false,
      );

      if (!mounted || generation != _generation) return;

      setState(() {
        _needsLogin = false;
        _merge(_people, data['people']);
        _merge(_posts, data['posts']);
        _page = nextPage;

        final pagination = data['pagination'];
        _hasMore = pagination is Map &&
            (CommunityApi.flag(pagination['has_more_people']) ||
                CommunityApi.flag(pagination['has_more_posts']));
      });
    } on LoginRequired {
      if (!mounted || generation != _generation) return;

      setState(() {
        _needsLogin = true;
        _people.clear();
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
          _more = false;
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

    if (!mounted || success != true) return;

    setState(() => _needsLogin = false);
    await _search();
  }

  Future<void> _follow(Map<String, dynamic> person) async {
    final id = CommunityApi.number(person['id']);

    if (_following.contains(id)) return;
    setState(() => _following.add(id));

    try {
      await CommunityApi.request(
        'community/toggle_follow.php',
        body: {'user_id': id},
      );

      // Server থেকেই updated count ও follow status আনব।
      if (mounted) await _search();
    } on LoginRequired {
      if (mounted) {
        setState(() {
          _needsLogin = true;
          _people.clear();
          _posts.clear();
          _hasMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(CommunityApi.errorText(e))),
      );

      // Response হারালেও toggle আবার পাঠাব না; status reload করব।
      await _search();
    } finally {
      if (mounted) setState(() => _following.remove(id));
    }
  }

  Future<void> _openPost(Map<String, dynamic> post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDiscussionScreen(
          postId: CommunityApi.number(post['id']),
        ),
      ),
    );

    if (mounted) await _search();
  }

  Widget _notice(String message, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(
            Icons.manage_search_rounded,
            size: 54,
            color: searchGreen,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.blueGrey,
              height: 1.5,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
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
          'Search Community',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: _text,
            maxLength: 80,
            textInputAction: TextInputAction.search,
            onChanged: _changed,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search people or English topics',
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search, color: searchGreen),
              suffixIcon: _text.text.isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  _text.clear();
                  _changed('');
                },
                icon: const Icon(Icons.close),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const {
              'all': 'All',
              'people': 'People',
              'posts': 'Posts',
              'questions': 'Questions',
            }.entries.map((entry) {
              return ChoiceChip(
                selected: _type == entry.key,
                showCheckmark: false,
                selectedColor: searchGreen,
                backgroundColor: Colors.white,
                label: Text(entry.value),
                labelStyle: TextStyle(
                  color: _type == entry.key ? Colors.white : searchInk,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) {
                  _type = entry.key;
                  _changed(_text.text);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (_needsLogin)
            _notice(
              'Community search ব্যবহার করতে login করো।',
              action: FilledButton(
                onPressed: _login,
                child: const Text('Sign in'),
              ),
            )
          else if (!_validQuery)
            _notice('নাম বা topic লিখে খুঁজে দেখো।\nকমপক্ষে ২ অক্ষর লিখবে।')
          else if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
                for (final person in _people)
                  SearchPersonCard(
                    person: person,
                    busy: _following.contains(
                      CommunityApi.number(person['id']),
                    ),
                    onFollow: () => _follow(person),
                  ),
                for (final post in _posts)
                  SearchPostCard(
                    post: post,
                    onOpen: () => _openPost(post),
                  ),
                if (_error != null)
                  _notice(
                    _error!,
                    action: OutlinedButton(
                      onPressed: () => _search(more: _page > 0 && _hasMore),
                      child: const Text('Retry'),
                    ),
                  )
                else if (_people.isEmpty && _posts.isEmpty)
                  _notice('কোনো result পাওয়া যায়নি।\nঅন্য শব্দ দিয়ে চেষ্টা করো।'),
                if (_more)
                  const Center(child: CircularProgressIndicator())
                else if (_hasMore && _error == null)
                  OutlinedButton(
                    onPressed: () => _search(more: true),
                    child: const Text('Load more'),
                  ),
              ],
        ],
      ),
    );
  }
}