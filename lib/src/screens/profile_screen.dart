import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loggingOut = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider);
    final receivedRequestsAsync = ref.watch(receivedRequestsProvider);
    final sentRequestsAsync = ref.watch(sentRequestsProvider);
    final borrowedAsync = ref.watch(borrowedRecordsProvider);
    final lentAsync = ref.watch(lentRecordsProvider);
    final myResourcesAsync = ref.watch(myResourcesProvider);

    // Count stats
    int receivedCount = 0;
    int sentCount = 0;
    int borrowedCount = 0;
    int lentCount = 0;
    int myResourcesCount = 0;

    if (receivedRequestsAsync is AsyncData) {
      receivedCount = (receivedRequestsAsync.value as List).length;
    }
    if (sentRequestsAsync is AsyncData) {
      sentCount = (sentRequestsAsync.value as List).length;
    }
    if (borrowedAsync is AsyncData) {
      borrowedCount = (borrowedAsync.value as List).length;
    }
    if (lentAsync is AsyncData) {
      lentCount = (lentAsync.value as List).length;
    }
    if (myResourcesAsync is AsyncData) {
      myResourcesCount = (myResourcesAsync.value as List).length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistics section
                  Text(
                    'Activity Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.inventory_2,
                          label: 'My Items',
                          value: myResourcesCount.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.inbox,
                          label: 'Received',
                          value: receivedCount.toString(),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.send,
                          label: 'Sent',
                          value: sentCount.toString(),
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.handshake,
                          label: 'Borrowed',
                          value: borrowedCount.toString(),
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.share,
                          label: 'Lent',
                          value: lentCount.toString(),
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()), // Empty space for alignment
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action buttons
                  _buildMenuButton(
                    context,
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => context.push('/requests'),
                    trailing: receivedCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$receivedCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuButton(
                    context,
                    icon: Icons.swap_horiz,
                    label: 'Transactions',
                    onTap: () => context.push('/transactions'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuButton(
                    context,
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () => _showAboutDialog(context),
                  ),
                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _loggingOut
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text('Are you sure you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true) return;
                              setState(() => _loggingOut = true);
                              try {
                                await ref.read(authNotifierProvider.notifier).logout();
                                if (!mounted) return;
                                context.go('/login');
                              } finally {
                                if (mounted) setState(() => _loggingOut = false);
                              }
                            },
                      icon: _loggingOut
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout),
                      label: Text(_loggingOut ? 'Logging out...' : 'Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Campus Hub',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, size: 48),
      children: [
        const SizedBox(height: 16),
        const Text(
          'A resource-sharing platform for Mehran University (MUET) students.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Share books, lab equipment, electronics, and more with your fellow students.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

