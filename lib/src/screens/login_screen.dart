import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../utils/error_util.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    final api = ref.read(apiServiceProvider);
    try {
      final loginResp = await api.login(_emailController.text.trim(), _passwordController.text.trim());
      try {
        final masked = loginResp.token.isEmpty ? '<no-token>' : '${loginResp.token.substring(0, loginResp.token.length>6?6:loginResp.token.length)}...';
        debugPrint('Login successful. token: $masked expiresAt: ${loginResp.expiresAt}');
      } catch (_) {}
      await ref.read(authNotifierProvider.notifier).loadProfile();
      final user = ref.read(authNotifierProvider);
      if (!mounted) return;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to load profile.')));
        return;
      }
      // If login succeeds and profile loads, user is verified (backend validates this)
      if (mounted) context.go('/home');
    } catch (e) {
      if (!mounted) return;
      final msg = userFriendlyError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Campus Hub', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: _loading ? null : _login, child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Login')),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: const Text('Create an account'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
