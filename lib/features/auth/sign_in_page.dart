import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _emailSignIn({required bool create}) async {
    setState(() { _busy = true; _error = null; });
    try {
      final auth = FirebaseAuth.instance;
      if (create) {
        await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(), password: _password.text);
      } else {
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(), password: _password.text);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('EcoSustain', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ),
              TextField(controller: _email, keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(controller: _password, obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password')),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: FilledButton(
                  onPressed: _busy ? null : () => _emailSignIn(create: false),
                  child: _busy
                      ? const SizedBox(height:20,width:20,child:CircularProgressIndicator(strokeWidth:2))
                      : const Text('Sign in'),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(
                  onPressed: _busy ? null : () => _emailSignIn(create: true),
                  child: const Text('Create account'),
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
