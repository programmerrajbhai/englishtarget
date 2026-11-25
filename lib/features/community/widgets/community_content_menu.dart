import 'package:flutter/material.dart';

import '../services/community_api.dart';

enum CommunityMenuResult {
  cancelled,
  changed,
  postRemoved,
  blocked,
}

class CommunityContentMenu {
  static Future<CommunityMenuResult> show(
      BuildContext context, {
        required bool isComment,
        required bool isOwner,
        required int contentId,
        required int authorId,
      }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        Widget option(String value, String label, IconData icon) {
          return ListTile(
            leading: Icon(icon, color: Colors.redAccent),
            title: Text(label),
            onTap: () => Navigator.pop(sheetContext, value),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwner)
                option(
                  'delete',
                  isComment ? 'Delete comment' : 'Delete post',
                  Icons.delete_outline,
                ),
              if (!isOwner && !isComment)
                option('report', 'Report post', Icons.flag_outlined),
              if (!isOwner && authorId > 0)
                option('block', 'Block user', Icons.block),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (action == null || !context.mounted) {
      return CommunityMenuResult.cancelled;
    }

    if (action == 'report') {
      final reason = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Why are you reporting this post?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              for (final entry in const {
                'spam': 'Spam',
                'inappropriate': 'Inappropriate content',
                'harassment': 'Harassment',
                'other': 'Other',
              }.entries)
                ListTile(
                  title: Text(entry.value),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(sheetContext, entry.key),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );

      if (reason == null || !context.mounted) {
        return CommunityMenuResult.cancelled;
      }

      final response = await CommunityApi.request(
        'community/report_post.php',
        body: {
          'post_id': contentId,
          'reason': reason,
        },
      );

      return CommunityApi.flag(response['post_hidden'])
          ? CommunityMenuResult.postRemoved
          : CommunityMenuResult.changed;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          action == 'block'
              ? 'Block this user?'
              : isComment
              ? 'Delete this comment?'
              : 'Delete this post?',
        ),
        content: Text(
          action == 'block'
              ? 'এই user-এর content তোমার account থেকে আর দেখা যাবে না। '
              'দুজনের follow সম্পর্কও সরিয়ে দেওয়া হবে।'
              : isComment
              ? 'এই comment এবং এর সরাসরি replies মুছে যাবে।'
              : 'এই post community থেকে সরিয়ে দেওয়া হবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action == 'block' ? 'Block' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return CommunityMenuResult.cancelled;
    }

    if (action == 'block') {
      final response = await CommunityApi.request(
        'community/toggle_block.php',
        body: {'user_id': authorId},
      );

      return CommunityApi.flag(response['is_blocked'])
          ? CommunityMenuResult.blocked
          : CommunityMenuResult.changed;
    }

    await CommunityApi.request(
      isComment
          ? 'community/delete_comment.php'
          : 'community/delete_post.php',
      body: {
        if (isComment) 'comment_id': contentId,
        if (!isComment) 'post_id': contentId,
      },
    );

    return isComment
        ? CommunityMenuResult.changed
        : CommunityMenuResult.postRemoved;
  }
}