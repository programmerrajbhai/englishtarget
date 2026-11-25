import 'package:flutter/material.dart';

import '../services/community_api.dart';
import '../services/community_auth_service.dart';
import 'community_register_screen.dart';

class CommunityLoginScreen extends StatefulWidget {
  const CommunityLoginScreen({super.key});

  @override
  State<CommunityLoginScreen> createState() =>
      _CommunityLoginScreenState();
}

class _CommunityLoginScreenState extends State<CommunityLoginScreen> {
  static const green = Color(0xFF008B48);
  static const ink = Color(0xFF102038);
  static const mint = Color(0xFFE8F7F1);

  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;
  bool _openingRegister = false;
  bool _hidden = true;
  String? _error;

  bool get _disabled => _busy || _openingRegister;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_disabled || !_form.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await CommunityAuthService.login(
        _identifier.text.trim(),
        _password.text,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = CommunityApi.errorText(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    if (_disabled) return;

    FocusScope.of(context).unfocus();
    setState(() => _openingRegister = true);

    try {
      final registered = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const CommunityRegisterScreen(),
        ),
      );

      if (!mounted) return;

      if (registered == true) {
        // Register API-এর token আগেই save হয়েছে।
        // Original screen-এ login success ফেরত পাঠাব।
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _openingRegister = false);
    }
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
        title: const Text('Join the conversation'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 24),
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.forum_outlined,
                    color: green,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ink,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to post, reply and connect\n'
                      'with the English Target community.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
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
                          controller: _identifier,
                          readOnly: _disabled,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: _decoration(
                            'Email or phone',
                            Icons.person_outline,
                          ),
                          validator: (value) =>
                          (value ?? '').trim().isEmpty
                              ? 'Email অথবা Phone দাও'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _password,
                          readOnly: _disabled,
                          obscureText: _hidden,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _login(),
                          decoration: _decoration(
                            'Password',
                            Icons.lock_outline,
                            suffix: IconButton(
                              tooltip: _hidden
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(
                                    () => _hidden = !_hidden,
                              ),
                              icon: Icon(
                                _hidden
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) =>
                          (value ?? '').isEmpty
                              ? 'Password দাও'
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
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _disabled ? null : _login,
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
                            'Sign in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: _disabled ? null : _register,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: green,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _disabled
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text(
                    'Continue browsing',
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