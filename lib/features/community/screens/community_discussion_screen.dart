import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/community_api.dart';
import '../services/community_auth_service.dart';
import '../widgets/community_content_menu.dart';
import '../widgets/community_search_cards.dart';
import 'community_login_screen.dart';

class CommunityDiscussionScreen extends StatefulWidget {
  final int postId;

  const CommunityDiscussionScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CommunityDiscussionScreen> createState() =>
      _CommunityDiscussionScreenState();
}

class _CommunityDiscussionScreenState
    extends State<CommunityDiscussionScreen> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _comments = <Map<String, dynamic>>[];

  Map<String, dynamic>? _post;
  Map<String, dynamic>? _reply;
  String? _error;

  int _page = 0;
  int _generation = 0;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
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
        _post = null;
        _comments.clear();
        _page = 0;
        _hasMore = false;
      }
    });

    try {
      final responses = await Future.wait([
        CommunityApi.request(
          'community/get_post.php',
          query: {'post_id': '${widget.postId}'},
        ),
        CommunityApi.request(
          'community/get_comments.php',
          query: {
            'post_id': '${widget.postId}',
            'page': '$nextPage',
            'limit': '20',
          },
        ),
      ]);

      if (!mounted || generation != _generation) return;

      final rawPost = responses[0]['post'];
      final rawComments = responses[1]['comments'];

      if (rawPost is! Map || rawComments is! List) {
        throw Exception('Discussion response সঠিক নয়।');
      }

      setState(() {
        _post = Map<String, dynamic>.from(rawPost);

        final ids = _comments.map((item) => '${item['id']}').toSet();

        for (final item in rawComments) {
          if (item is Map && ids.add('${item['id']}')) {
            _comments.add(Map<String, dynamic>.from(item));
          }
        }

        _page = nextPage;

        final pagination = responses[1]['pagination'];
        _hasMore = pagination is Map &&
            CommunityApi.flag(pagination['has_more']);
      });
    } on LoginRequired {
      if (mounted && generation == _generation) {
        setState(() {
          _error = 'Server এই content দেখতে login চাইছে।';
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

    if (!mounted) return;

    // নতুন session অনুযায়ী ownership ও likes refresh।
    await _load();

    if (success == true && mounted) {
      _message('Login হয়েছে। এখন action-টি আবার চাপো।');
    }
  }

  Future<bool> _authorized() async {
    final token = await CommunityAuthService.getToken();

    if (!mounted) return false;
    if (token != null && token.isNotEmpty) return true;

    await _login();

    // Login-এর আগের ownership দিয়ে action চালাব না।
    return false;
  }

  Future<void> _perform(Future<void> Function() action) async {
    if (_busy || _loading || _loadingMore || _post == null) return;

    setState(() => _busy = true);

    try {
      if (!await _authorized() || !mounted) return;
      await action();
    } on LoginRequired {
      if (mounted) await _login();
    } catch (e) {
      if (!mounted) return;

      _message(CommunityApi.errorText(e));

      // Failed mutation নিজে থেকে আবার পাঠানো হবে না।
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    final body = _text.text.trim();

    if (body.isEmpty) {
      _message('আগে তোমার comment লিখো।');
      return;
    }

    if (body.runes.length > 1000) {
      _message('Comment সর্বোচ্চ ১০০০ অক্ষরের হবে।');
      return;
    }

    await _perform(() async {
      try {
        await CommunityApi.request(
          'community/add_comment.php',
          body: {
            'post_id': widget.postId,
            'body': body,
            if (_reply != null)
              'parent_id': CommunityApi.number(_reply!['id']),
          },
        );
      } on LoginRequired {
        rethrow;
      } catch (e) {
        throw Exception(
          '${CommunityApi.errorText(e)}\n'
              'আবার পাঠানোর আগে comments দেখে নাও—'
              'response না এলেও comment জমা হয়ে থাকতে পারে।',
        );
      }

      if (!mounted) return;

      _text.clear();
      _focus.unfocus();
      setState(() => _reply = null);

      _message('Comment added');
      await _load();
    });
  }

  Future<void> _like(
      Map<String, dynamic> item, {
        required bool isComment,
      }) async {
    await _perform(() async {
      final id = CommunityApi.number(item['id']);

      final response = isComment
          ? await CommunityApi.request(
        'community/toggle_comment_like.php',
        body: {'comment_id': id},
      )
          : await CommunityApi.like(id);

      if (!mounted) return;

      setState(() {
        item['is_liked'] = CommunityApi.flag(response['is_liked']);
        item['likes_count'] =
            CommunityApi.number(response['likes_count']);
      });
    });
  }

  Future<void> _selectReply(Map<String, dynamic>? comment) async {
    await _perform(() async {
      setState(() => _reply = comment);
      _focus.requestFocus();
    });
  }

  Future<void> _menu(
      Map<String, dynamic> item, {
        required bool isComment,
      }) async {
    await _perform(() async {
      final authorId = CommunityApi.number(
        item[isComment ? 'user_id' : 'author_id'],
      );

      final result = await CommunityContentMenu.show(
        context,
        isComment: isComment,
        isOwner: CommunityApi.flag(item['is_owner']),
        contentId: CommunityApi.number(item['id']),
        authorId: authorId,
      );

      if (!mounted || result == CommunityMenuResult.cancelled) return;

      final blockedPostAuthor =
          result == CommunityMenuResult.blocked &&
              authorId == CommunityApi.number(_post?['author_id']);

      if (result == CommunityMenuResult.postRemoved ||
          blockedPostAuthor) {
        Navigator.pop(context, true);
        return;
      }

      setState(() => _reply = null);

      _message(
        result == CommunityMenuResult.blocked
            ? 'User blocked'
            : 'Action completed',
      );

      await _load();
    });
  }

  Future<void> _openMedia(String url) async {
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _message('Media খোলা যাচ্ছে না।');
      }
    } catch (_) {
      if (mounted) _message('Media খোলা যাচ্ছে না।');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _date(dynamic value) {
    final text = '${value ?? ''}';

    return text.length >= 16
        ? text.substring(0, 16).replaceFirst('T', ' ')
        : text;
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _busy || _loading || _loadingMore;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F7F1),
        foregroundColor: searchInk,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Discussion',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          if (_busy) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              color: searchGreen,
              onRefresh: () async {
                if (!_busy) await _load();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                children: [
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    if (_post != null) ...[
                      _contentCard(_post!, isComment: false),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Replies',
                          style: TextStyle(
                            color: searchInk,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      for (final comment in _comments)
                        _contentCard(comment, isComment: true),
                      if (_comments.isEmpty && _error == null)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'এখনো কোনো reply নেই। প্রথম reply তুমি দাও।',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                    ],
                    if (_error != null)
                      searchCard(
                        Column(
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _busy
                                  ? null
                                  : () => _load(
                                more: _page > 0 && _hasMore,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    if (_loadingMore)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_hasMore && _error == null)
                      OutlinedButton(
                        onPressed: disabled
                            ? null
                            : () => _load(more: true),
                        child: const Text('Load more replies'),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (_post != null) _composer(disabled),
        ],
      ),
    );
  }

  Widget _contentCard(
      Map<String, dynamic> item, {
        required bool isComment,
      }) {
    final prefix = isComment ? 'user' : 'author';
    final liked = CommunityApi.flag(item['is_liked']);
    final disabled = _busy || _loading || _loadingMore;

    final media = CommunityApi.mediaUrl(item['media_key']);
    final isImage = item['post_type'] == 'image' ||
        '${item['media_type']}'.startsWith('image/');

    return searchCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              searchAvatar(item['${prefix}_avatar_key']),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['${prefix}_name'] ?? ''}',
                      style: const TextStyle(
                        color: searchInk,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lv. ${item['${prefix}_level'] ?? 0} · '
                          '${_date(item['created_at'])}',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isComment ? 'Comment options' : 'Post options',
                onPressed: disabled
                    ? null
                    : () => _menu(item, isComment: isComment),
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isComment)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                const {
                  'ask_doubt': 'Ask Doubt',
                  'speaking': 'Speaking',
                  'vocabulary': 'Vocabulary',
                  'notes': 'Notes',
                }[item['category']] ??
                    'Community',
                style: const TextStyle(
                  color: searchGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (isComment && item['parent_id'] != null)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '↳ Reply to a comment',
                style: TextStyle(
                  color: searchGreen,
                  fontSize: 12,
                ),
              ),
            ),
          Text(
            '${item['body'] ?? ''}',
            style: const TextStyle(
              color: searchInk,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if ('${item['english_sentence'] ?? ''}'.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${item['english_sentence']}',
                style: const TextStyle(
                  color: searchInk,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
          if ('${item['bangla_meaning'] ?? ''}'.trim().isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'অর্থ: ${item['bangla_meaning']}',
                style: const TextStyle(
                  color: searchInk,
                  height: 1.5,
                ),
              ),
            ),
          if (media != null) ...[
            const SizedBox(height: 12),
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  media,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Image unavailable'),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _openMedia(media),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Open media'),
              ),
          ],
          const Divider(height: 26),
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed: disabled
                    ? null
                    : () => _like(item, isComment: isComment),
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: liked ? Colors.redAccent : Colors.blueGrey,
                ),
                label: Text(
                  '${item['likes_count'] ?? 0} Likes',
                  style: const TextStyle(color: searchInk),
                ),
              ),
              TextButton.icon(
                onPressed: disabled
                    ? null
                    : () => _selectReply(isComment ? item : null),
                icon: const Icon(
                  Icons.reply,
                  size: 20,
                  color: searchGreen,
                ),
                label: Text(
                  isComment
                      ? 'Reply'
                      : '${item['comments_count'] ?? 0} Comments',
                  style: const TextStyle(color: searchInk),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _composer(bool disabled) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_reply != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Replying to ${_reply!['user_name'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: searchGreen),
                      ),
                    ),
                    IconButton(
                      onPressed: disabled
                          ? null
                          : () => setState(() => _reply = null),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      focusNode: _focus,
                      readOnly: disabled,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write a helpful reply…',
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF2F6F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: disabled ? null : _send,
                    style: IconButton.styleFrom(
                      backgroundColor: searchGreen,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}