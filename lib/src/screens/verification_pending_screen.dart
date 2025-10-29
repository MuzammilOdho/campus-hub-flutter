import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class VerificationPendingScreen extends ConsumerStatefulWidget {
  final String email;
  const VerificationPendingScreen({super.key, required this.email});

  @override
  ConsumerState<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends ConsumerState<VerificationPendingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final api = ref.read(apiServiceProvider);
    try {
      await api.verifyUser(widget.email, _codeController.text.trim());
      if (!mounted) return;
      // On success, show message then navigate to login screen.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account verified. You may now login.')));
      if (mounted) context.go('/login');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: $msg')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _loading = true);
    final api = ref.read(apiServiceProvider);
    try {
      await api.resendVerificationCode(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification code resent.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error resending code: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: 8),
                  const Icon(Icons.email_outlined, size: 72, color: Colors.indigo),
                  const SizedBox(height: 12),
                  Text('We sent a verification code to', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(widget.email, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'Verification code', hintText: 'Enter code from email'),
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Please enter the verification code';
                      if (t.length < 3) return 'Code seems too short';
                      return null;
                    },
                    onFieldSubmitted: (_) => _verify(),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: (_loading || _codeController.text.trim().isEmpty) ? null : _verify,
                        child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Verify'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _loading ? null : _resend, child: const Text('Resend code'))
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
