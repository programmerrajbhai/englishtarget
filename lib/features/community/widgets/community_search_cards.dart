import 'package:flutter/material.dart';

import '../screens/community_profile_screen.dart';
import '../services/community_api.dart';

const searchGreen = Color(0xFF008B48);
const searchInk = Color(0xFF102038);

Widget searchCard(Widget child) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}

Widget searchAvatar(dynamic key) {
  final url = CommunityApi.mediaUrl(key);

  return ClipOval(
    child: SizedBox(
      width: 48,
      height: 48,
      child: url == null
          ? const ColoredBox(
        color: Color(0xFFE8F7F1),
        child: Icon(Icons.person, color: searchGreen),
      )
          : Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.person, color: searchGreen),
      ),
    ),
  );
}

class SearchPersonCard extends StatefulWidget {
  final Map<String, dynamic> person;
  final bool busy;
  final VoidCallback onFollow;

  const SearchPersonCard({
    super.key,
    required this.person,
    required this.busy,
    required this.onFollow,
  });

  @override
  State<SearchPersonCard> createState() => _SearchPersonCardState();
}

class _SearchPersonCardState extends State<SearchPersonCard> {
  bool _opening = false;

  Future<void> _openProfile() async {
    if (_opening || widget.busy) return;
    _opening = true;

    final id = CommunityApi.number(widget.person['id']);

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityProfileScreen(
            userId: id,
            onChanged: (profile) {
              if (!mounted ||
                  CommunityApi.number(widget.person['id']) != id) {
                return;
              }

              // Profile-এ follow বদলালে Search card-ও update হবে।
              setState(() {
                widget.person['name'] = profile['name'];
                widget.person['avatar_key'] = profile['avatar_key'];
                widget.person['level'] = profile['level'];
                widget.person['followers_count'] =
                profile['followers_count'];
                widget.person['is_following'] =
                profile['is_following'];
                widget.person['is_mutual'] =
                    CommunityApi.flag(profile['is_following']) &&
                        CommunityApi.flag(widget.person['follows_you']);
              });
            },
          ),
        ),
      );
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    final following = CommunityApi.flag(person['is_following']);

    return searchCard(
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _openProfile,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  searchAvatar(person['avatar_key']),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${person['name'] ?? ''}',
                          style: const TextStyle(
                            color: searchInk,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Lv. ${person['level'] ?? 0} · '
                              '${person['followers_count'] ?? 0} followers',
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                        if (CommunityApi.flag(person['is_mutual']))
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
          FilledButton(
            onPressed: widget.busy ? null : widget.onFollow,
            style: FilledButton.styleFrom(
              backgroundColor:
              following ? const Color(0xFFE8F7F1) : searchGreen,
              foregroundColor: following ? searchGreen : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: widget.busy
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
}

class SearchPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onOpen;

  const SearchPostCard({
    super.key,
    required this.post,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final image = CommunityApi.mediaUrl(post['media_key']);
    final isImage = post['post_type'] == 'image' ||
        '${post['media_type']}'.startsWith('image/');

    final category = const {
      'ask_doubt': 'Ask Doubt',
      'speaking': 'Speaking',
      'vocabulary': 'Vocabulary',
      'notes': 'Notes',
    }[post['category']] ??
        'Community';

    return Semantics(
      button: true,
      label: 'Open post',
      child: GestureDetector(
        onTap: onOpen,
        child: searchCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  searchAvatar(post['author_avatar_key']),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${post['author_name'] ?? ''}',
                      style: const TextStyle(
                        color: searchInk,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    'Lv. ${post['author_level'] ?? 0}',
                    style: const TextStyle(color: searchGreen),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                category,
                style: const TextStyle(
                  color: searchGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${post['body'] ?? ''}',
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: searchInk,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              if (image != null && isImage)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      image,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Text('Image unavailable'),
                    ),
                  ),
                ),
              if (image != null && !isImage)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Media attached · Open post to view',
                    style: TextStyle(color: searchGreen),
                  ),
                ),
              const Divider(height: 26),
              Text(
                '♡ ${post['likes_count'] ?? 0} Likes'
                    '     ·     ${post['comments_count'] ?? 0} Comments',
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}