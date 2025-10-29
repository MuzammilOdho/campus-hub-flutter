import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../utils/error_util.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final int resourceId;
  const ItemDetailScreen({required this.resourceId, super.key});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  bool _loading = true;
  dynamic _resource;
  String? _error;
  bool _sendingRequest = false;
  DateTime? _selectedReturnDate;

  @override
  void initState() {
    super.initState();
    _load();
    // Default return date is 7 days from now
    _selectedReturnDate = DateTime.now().add(const Duration(days: 7));
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(resourceRepositoryProvider);
    try {
      final r = await repo.getResourceById(widget.resourceId);
      setState(() {
        _resource = r;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _selectReturnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedReturnDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select expected return date',
    );
    if (picked != null) {
      setState(() => _selectedReturnDate = picked);
    }
  }

  Future<void> _requestItem() async {
    if (_sendingRequest) return;

    // Show confirmation dialog with return date
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Resource'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are requesting: ${_resource.name}'),
            const SizedBox(height: 16),
            Text(
              'Expected return date:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _selectReturnDate();
                _requestItem(); // Reopen dialog with new date
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedReturnDate != null
                    ? DateFormat('MMM dd, yyyy').format(_selectedReturnDate!)
                    : 'Select date',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm Request'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _sendingRequest = true);
    final repo = ref.read(requestRepositoryProvider);
    try {
      await repo.createRequest(
        _resource.id as int,
        _selectedReturnDate ?? DateTime.now().add(const Duration(days: 7)),
      );
      if (!mounted) return;
      // Refresh relevant providers so UI updates for both requester and owner
      ref.invalidate(sentRequestsProvider);
      ref.invalidate(receivedRequestsProvider);
      ref.invalidate(resourcesProvider);
      ref.invalidate(myResourcesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Return to previous screen
    } catch (e) {
      final msg = userFriendlyError(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $msg')),
      );
    } finally {
      if (mounted) {
        setState(() => _sendingRequest = false);
        _load(); // Reload detail to reflect any status changes
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final currentUser = ref.watch(authNotifierProvider);
    final sentAsync = ref.watch(sentRequestsProvider);
    bool hasSentActive = false;
    if (sentAsync is AsyncData) {
      final list = sentAsync.value as List;
      hasSentActive = list.any((r) {
        try {
          final status = ((r as dynamic).status ?? '').toString().toUpperCase();
          final rid = (r as dynamic).resourceDto.id;
          return rid == (_resource.id as dynamic) && (status == 'PENDING' || status == 'ACCEPTED');
        } catch (_) {
          return false;
        }
      });
    }

    final isOwner = currentUser != null && currentUser.id == (_resource.userId ?? _resource.userId);
    final resourceStatus = (_resource.status ?? '').toString().toUpperCase();
    final isAvailable = resourceStatus == 'AVAILABLE';

    return Scaffold(
      appBar: AppBar(
        title: Text(_resource.name ?? 'Resource'),
        actions: [
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Resource'),
                      content: const Text('Are you sure you want to delete this resource?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    final api = ref.read(apiServiceProvider);
                    try {
                      await api.deleteResource(_resource.id);
                      if (!mounted) return;
                      ref.invalidate(resourcesProvider);
                      ref.invalidate(myResourcesProvider);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Resource deleted')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${userFriendlyError(e)}')),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            if (_resource.imageUrl != null)
              Hero(
                tag: 'resource-${_resource.id}',
                child: CachedNetworkImage(
                  imageUrl: _resource.imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 80),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 80),
              ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _resource.name ?? '',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : _resource.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Metadata cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: _resource.resourceType.toLowerCase().contains('donate')
                              ? Icons.volunteer_activism
                              : Icons.handshake,
                          label: 'Type',
                          value: _resource.resourceType,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value: _resource.category,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _resource.description ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Date added
                  if (_resource.dateAdded != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Added: ${_resource.dateAdded}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action button
                  if (!isOwner)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _sendingRequest || hasSentActive || !isAvailable ? null : _requestItem,
                        icon: _sendingRequest
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                hasSentActive ? Icons.pending : Icons.send,
                              ),
                        label: Text(
                          _sendingRequest
                              ? 'Sending...'
                              : !isAvailable
                                  ? 'Currently Unavailable'
                                  : hasSentActive
                                      ? 'Request Pending'
                                      : 'Request to Borrow',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This is your resource',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

