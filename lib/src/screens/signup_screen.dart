import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../utils/error_util.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _signup() async {
    setState(() => _loading = true);
    final api = ref.read(apiServiceProvider);
    try {
      await api.signup(_name.text.trim(), _email.text.trim(), _password.text.trim());
      if (!mounted) return;
      // After signup, navigate to verification screen with email parameter
      context.go('/verify?email=${Uri.encodeComponent(_email.text.trim())}');
    } catch (e) {
      if (!mounted) return;
      final msg = userFriendlyError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _loading ? null : _signup, child: _loading ? const CircularProgressIndicator() : const Text('Sign up')))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
