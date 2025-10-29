import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../utils/error_util.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final Map<int, bool> _loading = {};

  void _setLoading(int id, bool v) => setState(() => _loading[id] = v);

  Future<bool?> _confirm(BuildContext context, String title, String body) async {
    return showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text(title), content: Text(body), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm'))]));
  }

  @override
  Widget build(BuildContext context) {
    final borrowed = ref.watch(borrowedRecordsProvider);
    final lent = ref.watch(lentRecordsProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('Transactions'), bottom: const TabBar(tabs: [Tab(text: 'Borrowed'), Tab(text: 'Lent')])),
        body: TabBarView(children: [
          borrowed.when(
            data: (list) => list.isEmpty ? const Center(child: Text('No borrowed records')) : ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final t = list[i];
                final status = t.transactionStatus.toLowerCase();
                final active = status == 'active' || status == 'in_progress' || status == 'ongoing';
                final loading = _loading[t.id] == true;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.resource.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Lender: ${t.lender.name}'),
                        Text('Status: ${t.transactionStatus}'),
                        if (active) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: loading ? null : () async {
                                final ok = await _confirm(context, 'Mark as returned', 'Mark this item as returned to the lender?');
                                if (ok != true) return;
                                _setLoading(t.id, true);
                                final api = ref.read(apiServiceProvider);
                                try {
                                  await api.markAsReturn(t.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as returned')));
                                  ref.invalidate(borrowedRecordsProvider);
                                  ref.invalidate(lentRecordsProvider);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  final msg = userFriendlyError(e);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
                                } finally {
                                  if (mounted) _setLoading(t.id, false);
                                }
                              },
                              icon: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.keyboard_return),
                              label: Text(loading ? 'Processing...' : 'Mark as Returned'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
          lent.when(
            data: (list) => list.isEmpty ? const Center(child: Text('No lent records')) : ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final t = list[i];
                final status = t.transactionStatus.toLowerCase();
                final returning = status == 'returning' || status == 'awaiting_return' || status == 'pending_return';
                final loading = _loading[t.id] == true;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.resource.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Borrower: ${t.borrower.name}'),
                        Text('Status: ${t.transactionStatus}'),
                        if (returning) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: loading ? null : () async {
                                    final ok = await _confirm(context, 'Confirm return', 'Confirm that ${t.borrower.name} has returned the item?');
                                    if (ok != true) return;
                                    _setLoading(t.id, true);
                                    final api = ref.read(apiServiceProvider);
                                    try {
                                      await api.confirmReturn(t.id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return confirmed')));
                                      ref.invalidate(lentRecordsProvider);
                                      ref.invalidate(borrowedRecordsProvider);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      final msg = userFriendlyError(e);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
                                    } finally {
                                      if (mounted) _setLoading(t.id, false);
                                    }
                                  },
                                  icon: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle),
                                  label: Text(loading ? 'Processing...' : 'Confirm'),
                                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: loading ? null : () async {
                                    final ok = await _confirm(context, 'Decline return', 'Decline return and open dispute?');
                                    if (ok != true) return;
                                    _setLoading(t.id, true);
                                    final api = ref.read(apiServiceProvider);
                                    try {
                                      await api.declineReturn(t.id, disputeType: 'owner_decline', disputeDetails: 'Declined by owner');
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return declined')));
                                      ref.invalidate(lentRecordsProvider);
                                      ref.invalidate(borrowedRecordsProvider);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      final msg = userFriendlyError(e);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
                                    } finally {
                                      if (mounted) _setLoading(t.id, false);
                                    }
                                  },
                                  icon: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cancel),
                                  label: Text(loading ? 'Processing...' : 'Decline'),
                                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          )
        ]),
      ),
    );
  }
}
