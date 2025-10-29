import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/providers.dart';
import '../utils/error_util.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  final Map<int, bool> _loadingMap = {};

  Future<bool?> _confirm(BuildContext context, String title, String body) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _setLoading(int id, bool v) => setState(() => _loadingMap[id] = v);

  @override
  Widget build(BuildContext context) {
    final received = ref.watch(receivedRequestsProvider);
    final sent = ref.watch(sentRequestsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received', icon: Icon(Icons.inbox)),
              Tab(text: 'Sent', icon: Icon(Icons.send)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Received Requests Tab
            _buildReceivedTab(received),
            // Sent Requests Tab
            _buildSentTab(sent),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedTab(AsyncValue receivedAsync) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(receivedRequestsProvider),
      child: receivedAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No received requests',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When someone requests your items,\nthey will appear here',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final r = list[i];
              final loading = _loadingMap[r.id] == true;
              final isPending = r.status.toUpperCase() == 'PENDING';

              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Request header with image
                    InkWell(
                      onTap: () => context.push('/item/${r.resourceDto.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Resource image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: r.resourceDto.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: r.resourceDto.imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.resourceDto.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'From: ${r.borrower.name}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (r.returnDate != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Return: ${r.returnDate}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPending ? Colors.orange : Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      r.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
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

                    // Action buttons (only for pending requests)
                    if (isPending && !loading)
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () async {
                                  final ok = await _confirm(
                                    context,
                                    'Approve Request',
                                    'Approve request from ${r.borrower.name}?',
                                  );
                                  if (ok != true) return;
                                  _setLoading(r.id, true);
                                  final api = ref.read(apiServiceProvider);
                                  try {
                                    await api.approveRequest(
                                      r.id,
                                      DateTime.now().add(const Duration(days: 7)),
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Request approved'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    ref.invalidate(receivedRequestsProvider);
                                    ref.invalidate(lentRecordsProvider);
                                    ref.invalidate(borrowedRecordsProvider);
                                    ref.invalidate(resourcesProvider);
                                    ref.invalidate(myResourcesProvider);
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    final msg = userFriendlyError(e);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $msg')),
                                    );
                                  } finally {
                                    if (mounted) _setLoading(r.id, false);
                                  }
                                },
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Approve'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () async {
                                  final ok = await _confirm(
                                    context,
                                    'Decline Request',
                                    'Decline request from ${r.borrower.name}?',
                                  );
                                  if (ok != true) return;
                                  _setLoading(r.id, true);
                                  final api = ref.read(apiServiceProvider);
                                  try {
                                    await api.declineRequest(r.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Request declined'),
                                      ),
                                    );
                                    ref.invalidate(receivedRequestsProvider);
                                    ref.invalidate(lentRecordsProvider);
                                    ref.invalidate(borrowedRecordsProvider);
                                    ref.invalidate(resourcesProvider);
                                    ref.invalidate(myResourcesProvider);
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    final msg = userFriendlyError(e);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $msg')),
                                    );
                                  } finally {
                                    if (mounted) _setLoading(r.id, false);
                                  }
                                },
                                icon: const Icon(Icons.cancel),
                                label: const Text('Decline'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (loading)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load requests'),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(receivedRequestsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentTab(AsyncValue sentAsync) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(sentRequestsProvider),
      child: sentAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sent requests',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse resources and send\nrequests to borrow items',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final r = list[i];
              final status = r.status.toUpperCase();
              final isPending = status == 'PENDING';
              final isApproved = status == 'ACCEPTED' || status == 'APPROVED';
              final isDeclined = status == 'DECLINED' || status == 'REJECTED';

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/item/${r.resourceDto.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Resource image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: r.resourceDto.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: r.resourceDto.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.resourceDto.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Lender: ${r.lender.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (r.returnDate != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Return: ${r.returnDate}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? Colors.orange
                                      : isApproved
                                          ? Colors.green
                                          : isDeclined
                                              ? Colors.red
                                              : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPending
                                          ? Icons.pending
                                          : isApproved
                                              ? Icons.check_circle
                                              : isDeclined
                                                  ? Icons.cancel
                                                  : Icons.info,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      r.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
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
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load requests'),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(sentRequestsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

