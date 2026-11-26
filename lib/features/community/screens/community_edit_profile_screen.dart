import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/ads/ad_manager.dart';
import '../../../core/ads/banner_ad_widget.dart';
import '../services/community_api.dart';
import '../services/community_upload_service.dart';
import '../widgets/community_search_cards.dart';
import 'community_login_screen.dart';

typedef JsonMap = Map<String, dynamic>;

class CommunityEditProfileScreen extends StatefulWidget {
  final JsonMap profile;

  const CommunityEditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<CommunityEditProfileScreen> createState() =>
      _CommunityEditProfileScreenState();
}

class _CommunityEditProfileScreenState
    extends State<CommunityEditProfileScreen> {
  static const mint = Color(0xFFE8F7F1);

  final _form = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final int _ownerId;

  String? _avatarKey;
  String? _selectedPath;
  String? _selectedName;
  String? _error;
  int? _uploadId;

  bool _saving = false;
  bool _picking = false;
  bool _openingLogin = false;
  bool _needsLogin = false;
  bool _photoSaved = false;

  String _stage = 'Save changes';

  bool get _locked => _saving || _picking || _openingLogin;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(
      text: '${widget.profile['name'] ?? ''}',
    );

    _bio = TextEditingController(
      text: '${widget.profile['bio'] ?? ''}',
    );

    _ownerId = CommunityApi.number(widget.profile['id']);

    final key = widget.profile['avatar_key'];
    _avatarKey = key is String ? key : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_locked) return;

    setState(() {
      _picking = true;
      _error = null;
    });

    try {
      // গ্যালারি থেকে ফেরার সময় যেন অপ্রত্যাশিতভাবে App Open Ad না আসে
      AdManager.instance.suppressNextAppOpenAd();

      // file_picker 11.0.3 API
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final selected = result.files.single;
      final path = selected.path;

      if (path == null) {
        throw Exception('এই ছবি পড়া যাচ্ছে না। অন্য ছবি বাছাই করো।');
      }

      final size = await File(path).length();

      if (size < 1 || size > 5 * 1024 * 1024) {
        throw Exception('ছবির size সর্বোচ্চ ৫ MB হতে হবে।');
      }

      if (!mounted) return;

      setState(() {
        _selectedPath = path;
        _selectedName = selected.name;
        _uploadId = null;
        _photoSaved = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = CommunityApi.errorText(e));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _cancelSelection() {
    if (_locked || _photoSaved) return;

    setState(() {
      _selectedPath = null;
      _selectedName = null;
      _uploadId = null;
      _error = null;
    });
  }

  Future<void> _login() async {
    if (_locked) return;

    setState(() => _openingLogin = true);

    try {
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const CommunityLoginScreen(),
        ),
      );

      if (!mounted || success != true) return;

      setState(() {
        _needsLogin = false;
        _error = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login হয়েছে। এখন Save changes চাপো।'),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingLogin = false);
    }
  }

  void _setStage(String text) {
    if (mounted) setState(() => _stage = text);
  }

  Future<void> _save() async {
    if (_locked || !_form.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
      _error = null;
      _stage = 'Checking account…';
    });

    try {
      // Session বদলে গেলে অন্য account-এ edit apply হবে না।
      final account = await CommunityApi.request(
        'users/profile.php',
        query: {'limit': '1'},
        guestRetry: false,
      );

      if (!mounted) return;

      final currentProfile = account['profile'];

      if (currentProfile is! Map ||
          CommunityApi.number(currentProfile['id']) != _ownerId) {
        throw Exception(
          'এই profile এবং login করা account মিলছে না। '
              'ফিরে গিয়ে সঠিক account-এর profile খোলো।',
        );
      }

      if (_selectedPath != null && !_photoSaved) {
        if (_uploadId == null) {
          _setStage('Uploading photo…');

          _uploadId = await CommunityUploadService.upload(
            path: _selectedPath!,
            purpose: 'avatar',
          );
        }

        if (!mounted) return;

        _setStage('Updating profile photo…');

        final response = await CommunityApi.request(
          'users/set_avatar.php',
          body: {'upload_id': _uploadId},
        );

        if (!mounted) return;

        final updated = response['profile'];
        final key = updated is Map ? updated['avatar_key'] : null;

        if (key is! String || key.isEmpty) {
          throw Exception(
            'Profile photo response সঠিক নয়। আবার Save changes চাপো।',
          );
        }

        setState(() {
          _avatarKey = key;
          _photoSaved = true;
        });
      }

      if (!mounted) return;

      _setStage('Saving profile…');

      await CommunityApi.request(
        'users/update_profile.php',
        body: {
          'name': _name.text.trim(),
          'bio': _bio.text.trim(),
        },
      );

      if (!mounted) return;

      // PopScope unlock করে তারপর parent profile-এ ফিরবে।
      setState(() => _saving = false);
      await WidgetsBinding.instance.endOfFrame;

      if (mounted) Navigator.pop(context, true);
    } on LoginRequired {
      if (mounted) {
        setState(() {
          _needsLogin = true;
          _error = 'Session শেষ হয়েছে। '
              'একই account-এ Sign in করে আবার Save চাপো।';
        });
      }
    } catch (e) {
      if (!mounted) return;

      final message = CommunityApi.errorText(e);

      setState(() {
        _error = _photoSaved
            ? 'ছবি save হয়েছে, কিন্তু Name/Bio save শেষ হয়নি।\n'
            '$message\nআবার Save changes চাপতে পারো।'
            : message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _stage = 'Save changes';
        });
      }
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: searchGreen),
      filled: true,
      fillColor: const Color(0xFFF3F8F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: searchGreen,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: mint,
      child: Center(
        child: Icon(
          Icons.person,
          size: 62,
          color: searchGreen,
        ),
      ),
    );
  }

  Widget _photoPreview() {
    if (_selectedPath != null) {
      return Image.file(
        File(_selectedPath!),
        fit: BoxFit.cover,
        cacheWidth: 512,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    final url = CommunityApi.mediaUrl(_avatarKey);

    if (url == null) return _placeholder();

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _photoSection() {
    return searchCard(
      Column(
        children: [
          const Text(
            'Your profile photo',
            style: TextStyle(
              color: searchInk,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB9E7CE),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 116,
                    height: 116,
                    child: _photoPreview(),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: 0,
                child: IconButton.filled(
                  tooltip: 'Choose profile photo',
                  onPressed: _locked ? null : _pickPhoto,
                  style: IconButton.styleFrom(
                    backgroundColor: searchGreen,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _locked ? null : _pickPhoto,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              _picking ? 'Opening photos…' : 'Change photo',
            ),
            style: TextButton.styleFrom(
              foregroundColor: searchGreen,
            ),
          ),
          const Text(
            'JPG, PNG or WebP · Maximum 5 MB',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
          if (_selectedName != null) ...[
            const SizedBox(height: 12),
            Text(
              _selectedName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: searchInk,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _photoSaved ? 'Photo saved' : 'Ready to save',
              style: const TextStyle(
                color: searchGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!_photoSaved)
              TextButton(
                onPressed: _locked ? null : _cancelSelection,
                child: const Text('Cancel selection'),
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_locked,
      child: Scaffold(
        backgroundColor: mint,
        appBar: AppBar(
          title: const Text(
            'Edit profile',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          backgroundColor: mint,
          foregroundColor: searchInk,
          surfaceTintColor: Colors.transparent,
        ),
        bottomNavigationBar: const BannerAdWidget(),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    _photoSection(),
                    searchCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'About you',
                            style: TextStyle(
                              color: searchInk,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _name,
                            readOnly: _locked,
                            maxLength: 80,
                            textCapitalization:
                            TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: _decoration(
                              'Name',
                              Icons.person_outline,
                            ),
                            validator: (value) {
                              final length =
                                  (value ?? '').trim().runes.length;

                              return length < 2 || length > 80
                                  ? 'নাম ২–৮০ অক্ষরের হতে হবে'
                                  : null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bio,
                            readOnly: _locked,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 250,
                            decoration: _decoration(
                              'Bio',
                              Icons.edit_note,
                            ),
                            validator: (value) =>
                            (value ?? '').trim().runes.length > 250
                                ? 'Bio সর্বোচ্চ ২৫০ অক্ষর'
                                : null,
                          ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          if (_needsLogin)
                            OutlinedButton(
                              onPressed: _locked ? null : _login,
                              child: const Text('Sign in'),
                            ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _locked || _needsLogin
                                ? null
                                : _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: searchGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: _saving
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.check_rounded),
                            label: Text(
                              _stage,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}