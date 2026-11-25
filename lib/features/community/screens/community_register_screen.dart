import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../services/community_registration_service.dart';

class CommunityRegisterScreen extends StatefulWidget {
  const CommunityRegisterScreen({super.key});

  @override
  State<CommunityRegisterScreen> createState() =>
      _CommunityRegisterScreenState();
}

class _CommunityRegisterScreenState
    extends State<CommunityRegisterScreen> {
  static const green = Color(0xFF008B48);
  static const ink = Color(0xFF102038);
  static const mint = Color(0xFFE8F7F1);

  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _busy = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_busy || !_form.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await CommunityRegistrationService.register(
        name: _name.text,
        email: _email.text,
        phone: _phone.text,
        password: _password.text,
      );

      if (!mounted) return;

      // Login screen-এ success জানাবে।
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = CommunityApi.errorText(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return _phone.text.trim().isEmpty
          ? 'Email অথবা Phone—একটি দাও'
          : null;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'সঠিক Email address দাও';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();

    if (phone.isEmpty) return null;

    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone)) {
      return '৭–১৫ digit দাও; শুরুতে + থাকতে পারে';
    }

    return null;
  }

  InputDecoration _decoration(
      String label,
      IconData icon, {
        Widget? suffix,
      }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: green),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF5F9F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        backgroundColor: mint,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.school_outlined,
                    color: green,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Join English Target',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ink,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask questions, share your learning\n'
                      'and connect with other learners.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _name,
                          readOnly: _busy,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          decoration: _decoration(
                            'Full name',
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _email,
                          readOnly: _busy,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          autofillHints: const [AutofillHints.email],
                          decoration: _decoration(
                            'Email',
                            Icons.email_outlined,
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phone,
                          readOnly: _busy,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.telephoneNumber,
                          ],
                          decoration: _decoration(
                            'Phone',
                            Icons.phone_outlined,
                          ),
                          validator: _validatePhone,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          child: Text(
                            'Email অথবা Phone—অন্তত একটি দাও।',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _password,
                          readOnly: _busy,
                          obscureText: _hidePassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          decoration: _decoration(
                            'Password',
                            Icons.lock_outline,
                            suffix: IconButton(
                              tooltip: _hidePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) =>
                          (value ?? '').runes.length < 8
                              ? 'কমপক্ষে ৮ অক্ষরের password দাও'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirm,
                          readOnly: _busy,
                          obscureText: _hideConfirm,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _register(),
                          decoration: _decoration(
                            'Confirm password',
                            Icons.lock_outline,
                            suffix: IconButton(
                              tooltip: _hideConfirm
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(
                                    () => _hideConfirm = !_hideConfirm,
                              ),
                              icon: Icon(
                                _hideConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) =>
                          value != _password.text
                              ? 'দুটি password মিলছে না'
                              : null,
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                height: 1.5,
                              ),
                            ),
                          ),
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: _busy ? null : _register,
                          style: FilledButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _busy
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Create account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text(
                    'Already have an account? Sign in',
                    style: TextStyle(color: green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}