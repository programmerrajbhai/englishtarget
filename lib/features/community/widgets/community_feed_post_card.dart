import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/community_api.dart';
import 'community_search_cards.dart';

class CommunityFeedPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool disabled;
  final bool liking;
  final VoidCallback onOpen;
  final VoidCallback onAuthor;
  final VoidCallback onLike;
  final VoidCallback onMenu;

  const CommunityFeedPostCard({
    super.key,
    required this.post,
    required this.disabled,
    required this.liking,
    required this.onOpen,
    required this.onAuthor,
    required this.onLike,
    required this.onMenu,
  });

  Future<void> _openMedia(BuildContext context, String url) async {
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (!opened) throw Exception('Media unavailable');
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media খোলা যাচ্ছে না।')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final liked = CommunityApi.flag(post['is_liked']);
    final media = CommunityApi.mediaUrl(post['media_key']);

    final isImage = post['post_type'] == 'image' ||
        '${post['media_type']}'.startsWith('image/');

    final date = '${post['created_at'] ?? ''}';
    final english = '${post['english_sentence'] ?? ''}'.trim();
    final bangla = '${post['bangla_meaning'] ?? ''}'.trim();

    final category = const {
      'ask_doubt': 'Ask Doubt',
      'speaking': 'Speaking',
      'vocabulary': 'Vocabulary',
      'notes': 'Notes',
    }[post['category']] ??
        'Community';

    return searchCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: disabled ? null : onAuthor,
                  child: Row(
                    children: [
                      searchAvatar(post['author_avatar_key']),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${post['author_name'] ?? ''}',
                              style: const TextStyle(
                                color: searchInk,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lv. ${post['author_level'] ?? 0} · '
                                  '${date.length >= 16 ? date.substring(0, 16).replaceFirst('T', ' ') : date}',
                              style: const TextStyle(
                                color: Colors.blueGrey,
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
              IconButton(
                tooltip: 'Post options',
                onPressed: disabled || liking ? null : onMenu,
                icon: const Icon(Icons.more_vert, color: searchInk),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: searchGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: disabled ? null : onOpen,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                '${post['body'] ?? ''}',
                style: const TextStyle(
                  color: searchInk,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (english.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                english,
                style: const TextStyle(
                  color: searchInk,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
          if (bangla.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'অর্থ: $bangla',
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
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) =>
                  progress == null
                      ? child
                      : const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 100,
                    child: Center(child: Text('Image unavailable')),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _openMedia(context, media),
                icon: Icon(
                  post['post_type'] == 'video'
                      ? Icons.play_circle_outline
                      : Icons.volume_up_outlined,
                ),
                label: Text(
                  post['post_type'] == 'video'
                      ? 'Open video'
                      : 'Listen to audio',
                ),
              ),
          ],
          const Divider(height: 26),
          Wrap(
            spacing: 10,
            children: [
              TextButton.icon(
                onPressed: disabled || liking ? null : onLike,
                icon: liking
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.redAccent : Colors.blueGrey,
                  size: 21,
                ),
                label: Text(
                  '${post['likes_count'] ?? 0} Likes',
                  style: const TextStyle(color: searchInk),
                ),
              ),
              TextButton.icon(
                onPressed: disabled ? null : onOpen,
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: Colors.blueGrey,
                ),
                label: Text(
                  '${post['comments_count'] ?? 0} Comments',
                  style: const TextStyle(color: searchInk),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}