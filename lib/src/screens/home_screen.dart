import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'browse_screen.dart';
import 'my_items_screen.dart';
import '../providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    BrowseScreen(),
    MyItemsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final requestCount = ref.watch(receivedRequestsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Hub'),
        centerTitle: false,
        actions: [
          // Requests/Notifications button with badge
          IconButton(
            icon: badges.Badge(
              showBadge: requestCount > 0,
              badgeContent: Text(
                '$requestCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Requests',
            onPressed: () => context.push('/requests'),
          ),
          // Profile button
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
          // More menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'transactions') {
                context.push('/transactions');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'transactions',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz),
                    SizedBox(width: 8),
                    Text('Transactions'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            activeIcon: Icon(Icons.inventory),
            label: 'My Items',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/donate'),
        icon: const Icon(Icons.add),
        label: const Text('Upload'),
        tooltip: 'Upload Resource',
      ),
    );
  }
}
