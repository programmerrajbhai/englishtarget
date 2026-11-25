import 'package:flutter/material.dart';

import '../services/community_auth_service.dart';

class CommunityLoginScreen extends StatefulWidget {
  const CommunityLoginScreen({super.key});

  @override
  State<CommunityLoginScreen> createState() =>
      _CommunityLoginScreenState();
}

class _CommunityLoginScreenState extends State<CommunityLoginScreen> {
  static const green = Color(0xFF008B48);

  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;
  bool _hidden = true;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await CommunityAuthService.login(
        _identifier.text,
        _password.text,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: green),
      filled: true,
      fillColor: const Color(0xFFF4FAF6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F7F1),
      appBar: AppBar(
        title: const Text('Join the conversation'),
        backgroundColor: const Color(0xFFE8F7F1),
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.groups_rounded, size: 65, color: green),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to Community',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF102038),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to like, reply and share.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _identifier,
                    enabled: !_busy,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(
                      'Email or phone',
                      Icons.person_outline,
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Email অথবা phone দাও'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    enabled: !_busy,
                    obscureText: _hidden,
                    autocorrect: false,
                    enableSuggestions: false,
                    onFieldSubmitted: (_) => _login(),
                    decoration: _decoration(
                      'Password',
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _hidden = !_hidden),
                        icon: Icon(_hidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                      ),
                    ),
                    validator: (value) => (value ?? '').isEmpty
                        ? 'Password দাও'
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _login,
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: _busy
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}