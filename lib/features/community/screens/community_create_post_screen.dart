import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/ads/ad_manager.dart';
import '../../../core/ads/banner_ad_widget.dart';
import '../services/community_api.dart';
import '../services/community_auth_service.dart';
import '../services/community_upload_service.dart';
import 'community_login_screen.dart';

class CommunityCreatePostScreen extends StatefulWidget {
  const CommunityCreatePostScreen({super.key});

  @override
  State<CommunityCreatePostScreen> createState() =>
      _CommunityCreatePostScreenState();
}

class _CommunityCreatePostScreenState
    extends State<CommunityCreatePostScreen> {
  static const green = Color(0xFF008B48);
  static const ink = Color(0xFF102038);
  static const mint = Color(0xFFE8F7F1);

  static const categories = {
    'ask_doubt': 'Ask Doubt',
    'speaking': 'Speaking',
    'vocabulary': 'Vocabulary',
    'notes': 'Notes',
  };

  final _form = GlobalKey<FormState>();
  final _body = TextEditingController();
  final _english = TextEditingController();
  final _bangla = TextEditingController();

  String _category = 'ask_doubt';
  String? _path, _filename, _purpose, _error;
  String _stage = 'Share Post';
  int? _uploadId, _postId;

  bool _busy = false;
  bool _picking = false;
  bool _createUncertain = false;

  bool get _locked =>
      _busy ||
          _picking ||
          _uploadId != null ||
          _postId != null ||
          _createUncertain;

  @override
  void initState() {
    super.initState();
    AdManager.instance.loadInterstitialAd();
  }

  @override
  void dispose() {
    _body.dispose();
    _english.dispose();
    _bangla.dispose();
    super.dispose();
  }

  Future<void> _pick(String purpose) async {
    if (_locked) return;

    setState(() {
      _picking = true;
      _error = null;
    });

    try {
      final extensions = switch (purpose) {
        'post_image' => ['jpg', 'jpeg', 'png', 'webp'],
        'post_video' => ['mp4', 'webm'],
        _ => ['mp3', 'm4a', 'aac', 'ogg', 'wav', 'webm'],
      };

      // ফাইল পিকার থেকে ফেরার সময় যেন App Open Ad না আসে
      AdManager.instance.suppressNextAppOpenAd();

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final selected = result.files.single;
      final path = selected.path;

      if (path == null) {
        throw Exception('এই file পড়া যাচ্ছে না। অন্য file বাছাই করো।');
      }

      final bytes = await File(path).length();
      final maxMb = purpose == 'post_video' ? 50 : 10;

      if (bytes == 0 || bytes > maxMb * 1024 * 1024) {
        throw Exception('File খালি হতে পারবে না; সর্বোচ্চ $maxMb MB।');
      }

      if (!mounted) return;

      setState(() {
        _path = path;
        _filename = selected.name;
        _purpose = purpose;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = CommunityApi.errorText(e));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<bool> _ensureLogin() async {
    final token = await CommunityAuthService.getToken();

    if (!mounted) return false;
    if (token != null && token.isNotEmpty) return true;

    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CommunityLoginScreen(),
      ),
    ) ==
        true;
  }

  void _setStage(String value) {
    if (mounted) setState(() => _stage = value);
  }

  Future<void> _submit() async {
    if (_busy || _picking || _createUncertain) return;
    if (!_form.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    // Create request-এর response হারালে blind retry করব না।
    var creating = false;

    try {
      if (!await _ensureLogin() || !mounted) return;

      if (_path != null && _uploadId == null) {
        _setStage('Uploading media…');

        _uploadId = await CommunityUploadService.upload(
          path: _path!,
          purpose: _purpose!,
        );
      }

      if (!mounted) return;

      if (_postId == null) {
        _setStage('Creating post…');
        creating = true;

        final result = await CommunityApi.request(
          'community/create_post.php',
          body: {
            'category': _category,
            'body': _body.text.trim(),
            'english_sentence': _english.text.trim(),
            'bangla_meaning': _bangla.text.trim(),
          },
        );

        final post = result['post'];
        final id = post is Map ? CommunityApi.number(post['id']) : 0;

        if (id < 1) {
          throw Exception('Post ID পাওয়া যায়নি।');
        }

        _postId = id;
        creating = false;
      }

      if (!mounted) return;

      if (_uploadId != null) {
        _setStage('Attaching media…');

        await CommunityApi.request(
          'community/attach_post_media.php',
          body: {
            'post_id': _postId,
            'upload_id': _uploadId,
          },
        );
      }

      if (!mounted) return;

      // পোস্ট সফলভাবে তৈরি হলে Interstitial Ad দেখিয়ে Feed-এ ফিরবে
      AdManager.instance.showInterstitialAd(
        onAdDismissed: () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        },
      );
    } on LoginRequired {
      if (mounted) {
        setState(() {
          _error = 'Session শেষ হয়েছে। আবার চাপলে login করতে পারবে।';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _createUncertain = creating;

        _error = creating
            ? '${CommunityApi.errorText(e)}\n'
            'Post তৈরি হয়েছে কি না নিশ্চিত করা যায়নি। '
            'Feed-এ ফিরে দেখে তারপর আবার চেষ্টা করো।'
            : _postId != null
            ? 'Text post তৈরি হয়েছে, media attach হয়নি। '
            'Retry চাপো।\n${CommunityApi.errorText(e)}'
            : CommunityApi.errorText(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _stage = 'Share Post';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        backgroundColor: mint,
        appBar: AppBar(
          backgroundColor: mint,
          foregroundColor: ink,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Create Post',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        bottomNavigationBar: const BannerAdWidget(),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.entries.map((entry) {
                  final selected = _category == entry.key;

                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: green,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : ink,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: _locked
                        ? null
                        : (_) => setState(
                          () => _category = entry.key,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heading(Icons.edit_note, 'Your post'),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _body,
                      readOnly: _locked,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 500,
                      decoration: _decoration(
                        'Write in English or Bangla…',
                      ),
                      validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'তোমার post লিখো'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _heading(
                      Icons.menu_book_outlined,
                      'English Sentence (Optional)',
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _english,
                      readOnly: _locked,
                      maxLength: 500,
                      minLines: 1,
                      maxLines: 3,
                      decoration: _decoration(
                        'e.g. Could you please help me?',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _heading(
                      Icons.translate,
                      'Bangla Meaning (Optional)',
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _bangla,
                      readOnly: _locked,
                      maxLength: 1000,
                      minLines: 1,
                      maxLines: 4,
                      decoration: _decoration('বাংলা অর্থ লিখো…'),
                    ),
                    const Divider(height: 28),
                    _heading(
                      Icons.attach_file,
                      'Attach Media (Optional)',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _attachButton(
                          'Photo',
                          Icons.image_outlined,
                          'post_image',
                        ),
                        _attachButton(
                          'Video',
                          Icons.videocam_outlined,
                          'post_video',
                        ),
                        _attachButton(
                          'Voice',
                          Icons.mic_none,
                          'post_voice',
                        ),
                      ],
                    ),
                    if (_picking)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(),
                      ),
                    if (_path != null) ...[
                      const SizedBox(height: 12),
                      if (_purpose == 'post_image')
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_path!),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Text('Preview unavailable'),
                          ),
                        ),
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            color: green,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _filename!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove attachment',
                            onPressed: _locked
                                ? null
                                : () => setState(() {
                              _path = null;
                              _filename = null;
                              _purpose = null;
                            }),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _card(
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_outlined, color: green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keep your post respectful and relevant '
                            'to English learning.\n'
                            'Your post will be visible to the community.',
                        style: TextStyle(color: ink, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      height: 1.5,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _busy || _picking
                    ? null
                    : _createUncertain
                    ? () => Navigator.pop(context, true)
                    : _submit,
                icon: _busy
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _busy
                      ? _stage
                      : _createUncertain
                      ? 'Back to Feed'
                      : _postId != null
                      ? 'Retry attachment'
                      : 'Share Post',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachButton(String label, IconData icon, String purpose) {
    return OutlinedButton.icon(
      onPressed: _locked ? null : () => _pick(purpose),
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(foregroundColor: green),
    );
  }

  Widget _heading(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF7FAF9),
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDDE6E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDDE6E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
    );
  }
}