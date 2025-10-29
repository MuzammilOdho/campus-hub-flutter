import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/error_util.dart';

class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key});

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  // Use a dropdown for category to avoid enum mismatches
  String _category = 'Miscellaneous';
  String _type = 'Share';
  File? _image;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final res = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (res != null) setState(() => _image = File(res.path));
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image before uploading')));
      return;
    }
    setState(() => _loading = true);
    final api = ref.read(apiServiceProvider);
    try {
      // Pre-flight: ensure token/profile is valid to give clearer UX on forbidden/401
      await api.getProfile();
      final req = CreateResourceRequest(name: _name.text.trim(), description: _desc.text.trim(), category: _category, resourceType: _type);
      await api.createResource(req, _image);
      if (!mounted) return;
      // Invalidate providers to refresh lists
      ref.invalidate(resourcesProvider);
      ref.invalidate(myResourcesProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resource uploaded successfully')));
      context.pop();
    } catch (e) {
      final msg = userFriendlyError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donate / Upload'), actions: [
        // Debug helper: show current saved token (masked) in logs/snackbar
        IconButton(
          icon: const Icon(Icons.bug_report),
          tooltip: 'Show token (debug)',
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final api = ref.read(apiServiceProvider);
            final token = await api.getToken();
            if (!mounted) return;
            try {
              final masked = token == null || token.isEmpty ? '<no-token>' : '${token.substring(0, token.length>8?8:token.length)}...';
              debugPrint('Saved token: $masked');
              messenger.showSnackBar(SnackBar(content: Text('Token: $masked')));
            } catch (_) {
              messenger.showSnackBar(SnackBar(content: Text('Token length: ${token?.length ?? 0}')));
            }
          },
        )
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 12),
                  TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'Books', child: Text('Books')),
                      DropdownMenuItem(value: 'Lab Equipment', child: Text('Lab Equipment')),
                      DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                      DropdownMenuItem(value: 'Stationery', child: Text('Stationery')),
                      DropdownMenuItem(value: 'Miscellaneous', child: Text('Miscellaneous')),
                    ],
                    onChanged: (v) => setState(() => _category = v ?? 'Miscellaneous'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    items: const [
                      DropdownMenuItem(value: 'Share', child: Text('Share')),
                      DropdownMenuItem(value: 'Donate', child: Text('Donate')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'Share'),
                  ),
                  const SizedBox(height: 12),
                  if (_image != null) Image.file(_image!, height: 150, fit: BoxFit.cover),
                  const SizedBox(height: 8),
                  Row(children: [TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text('Pick image'))]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
