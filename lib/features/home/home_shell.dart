import 'package:flutter/material.dart';
import 'package:swapstash/core/services/chat_service.dart';
import 'package:swapstash/core/services/trade_service.dart';
import 'package:swapstash/features/collections/my_collections_v2_page.dart';
import 'package:swapstash/features/dashboard/dashboard_page.dart';
import 'package:swapstash/features/messages/messages_page.dart';
import 'package:swapstash/features/profile/profile_page.dart';
import 'package:swapstash/features/trades/trades_page.dart';
import 'package:swapstash/features/users/users_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final ChatService _chatService = ChatService();
  final TradeService _tradeService = TradeService();

  late final Stream<int> _activeTradeCountStream;

  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    MyCollectionsV2Page(),
    UsersPage(),
    TradesPage(),
    MessagesPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _activeTradeCountStream = _tradeService.watchActiveTradeCount();
  }

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
    final localizations = AppLocalizations.of(context)!;

    return StreamBuilder<int>(
      stream: _activeTradeCountStream,
      initialData: 0,
      builder: (context, tradeSnapshot) {
        final activeTradeCount = tradeSnapshot.data ?? 0;

        return StreamBuilder<int>(
          stream: _chatService.watchTotalUnreadCount(),
          initialData: 0,
          builder: (context, messageSnapshot) {
            final unreadCount = messageSnapshot.data ?? 0;

            return Scaffold(
              body: IndexedStack(index: _selectedIndex, children: _pages),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home),
                    label: localizations.home,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.collections_bookmark_outlined),
                    selectedIcon: const Icon(Icons.collections_bookmark),
                    label: localizations.collections,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.people_outline),
                    selectedIcon: const Icon(Icons.people),
                    label: localizations.collectorsNavigation,
                  ),
                  NavigationDestination(
                    icon: _TradesNavigationIcon(
                      icon: Icons.swap_horiz_outlined,
                      activeTradeCount: activeTradeCount,
                    ),
                    selectedIcon: _TradesNavigationIcon(
                      icon: Icons.swap_horiz,
                      activeTradeCount: activeTradeCount,
                    ),
                    label: localizations.trades,
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
                    label: localizations.messages,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: localizations.profile,
                  ),
                ],
                onDestinationSelected: _selectDestination,
              ),
            );
          },
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

class _TradesNavigationIcon extends StatelessWidget {
  final IconData icon;
  final int activeTradeCount;

  const _TradesNavigationIcon({
    required this.icon,
    required this.activeTradeCount,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedCount = activeTradeCount < 0 ? 0 : activeTradeCount;
    final badgeLabel = normalizedCount > 99
        ? '99+'
        : normalizedCount.toString();

    return Badge(
      isLabelVisible: normalizedCount > 0,
      label: Text(badgeLabel),
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      child: Icon(icon),
    );
  }
}
