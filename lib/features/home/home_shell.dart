import 'package:flutter/material.dart';
import 'package:swapstash/core/services/chat_service.dart';
import 'package:swapstash/features/collections/collections_page.dart';
import 'package:swapstash/features/dashboard/dashboard_page.dart';
import 'package:swapstash/features/messages/messages_page.dart';
import 'package:swapstash/features/profile/profile_page.dart';
import 'package:swapstash/features/trades/trades_page.dart';
import 'package:swapstash/features/users/users_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final ChatService _chatService = ChatService();

  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CollectionsPage(),
    UsersPage(),
    TradesPage(),
    MessagesPage(),
    ProfilePage(),
  ];

  void _selectDestination(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _chatService.watchTotalUnreadCount(),
      initialData: 0,
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Domov',
              ),
              const NavigationDestination(
                icon: Icon(Icons.collections_bookmark_outlined),
                selectedIcon: Icon(Icons.collections_bookmark),
                label: 'Zbirke',
              ),
              const NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Zbiratelji',
              ),
              const NavigationDestination(
                icon: Icon(Icons.swap_horiz_outlined),
                selectedIcon: Icon(Icons.swap_horiz),
                label: 'Menjave',
              ),
              NavigationDestination(
                icon: _MessagesNavigationIcon(
                  icon: Icons.chat_bubble_outline,
                  unreadCount: unreadCount,
                ),
                selectedIcon: _MessagesNavigationIcon(
                  icon: Icons.chat_bubble,
                  unreadCount: unreadCount,
                ),
                label: 'Sporočila',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            onDestinationSelected: _selectDestination,
          ),
        );
      },
    );
  }
}

class _MessagesNavigationIcon extends StatelessWidget {
  final IconData icon;
  final int unreadCount;

  const _MessagesNavigationIcon({
    required this.icon,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedCount = unreadCount < 0 ? 0 : unreadCount;
    final badgeLabel = normalizedCount > 99
        ? '99+'
        : normalizedCount.toString();

    return Badge(
      isLabelVisible: normalizedCount > 0,
      label: Text(badgeLabel),
      child: Icon(icon),
    );
  }
}
