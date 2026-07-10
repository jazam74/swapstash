import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'SwapStash',
    'Moje zbirke',
    'Menjave',
    'Sporočila',
    'Profil',
  ];

  static const List<Widget> _screens = [
    _HomeScreen(),
    _CollectionsScreen(),
    _TradesScreen(),
    _MessagesScreen(),
    _ProfileScreen(),
  ];

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectScreen,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Domov',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: 'Zbirke',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Menjave',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Sporočila',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Dobrodošel, Uroš!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Uredi svoje zbirke in poišči najboljše menjave.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),
        const _DashboardCard(
          icon: Icons.auto_awesome,
          title: 'Nova ujemanja',
          value: '5',
          description: 'Prednost imajo uporabniki iz tvoje države.',
        ),
        const SizedBox(height: 16),
        const _DashboardCard(
          icon: Icons.collections_bookmark,
          title: 'Aktivne zbirke',
          value: '2',
          description: 'Vse tvoje zbirke so na enem mestu.',
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dodajanje zbirke pride v naslednjem koraku.'),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Dodaj zbirko'),
        ),
      ],
    );
  }
}

class _CollectionsScreen extends StatelessWidget {
  const _CollectionsScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _CollectionCard(
          publisher: 'Panini Adrenalyn XL',
          title: 'FIFA World Cup 2026',
          collected: 218,
          total: 630,
        ),
        SizedBox(height: 16),
        _CollectionCard(
          publisher: 'Topps',
          title: 'UEFA Champions League',
          collected: 84,
          total: 250,
        ),
      ],
    );
  }
}

class _TradesScreen extends StatelessWidget {
  const _TradesScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _TradeCard(
          username: 'Marko',
          country: 'Slovenija',
          giveCount: 12,
          receiveCount: 15,
        ),
        SizedBox(height: 16),
        _TradeCard(
          username: 'Nina',
          country: 'Slovenija',
          giveCount: 7,
          receiveCount: 9,
        ),
        SizedBox(height: 16),
        _TradeCard(
          username: 'Luca',
          country: 'Italija',
          giveCount: 14,
          receiveCount: 18,
          international: true,
        ),
      ],
    );
  }
}

class _MessagesScreen extends StatelessWidget {
  const _MessagesScreen();

  @override
  Widget build(BuildContext context) {
    return const _EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'Ni sporočil',
      description: 'Pogovori o menjavah bodo prikazani tukaj.',
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        const CircleAvatar(
          radius: 50,
          child: Icon(
            Icons.person,
            size: 52,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Uroš',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text('Slovenija'),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Jezik'),
                trailing: Text('Slovenščina'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.public),
                title: Text('Mednarodne menjave'),
                trailing: Text('Dovoljene'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.swap_horiz),
                title: Text('Uspešne menjave'),
                trailing: Text('0'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              child: Icon(icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.publisher,
    required this.title,
    required this.collected,
    required this.total,
  });

  final String publisher;
  final String title;
  final int collected;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = collected / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              publisher,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 10),
            Text('$collected od $total predmetov'),
          ],
        ),
      ),
    );
  }
}

class _TradeCard extends StatelessWidget {
  const _TradeCard({
    required this.username,
    required this.country,
    required this.giveCount,
    required this.receiveCount,
    this.international = false,
  });

  final String username;
  final String country;
  final int giveCount;
  final int receiveCount;
  final bool international;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(country),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    international ? Icons.public : Icons.home_outlined,
                    size: 18,
                  ),
                  label: Text(
                    international ? 'Mednarodno' : 'Ista država',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TradeAmount(
                  label: 'Ti daš',
                  amount: giveCount,
                ),
                const Icon(Icons.swap_horiz, size: 34),
                _TradeAmount(
                  label: 'Ti dobiš',
                  amount: receiveCount,
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {},
              child: const Text('Preglej menjavo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradeAmount extends StatelessWidget {
  const _TradeAmount({
    required this.label,
    required this.amount,
  });

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$amount',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}