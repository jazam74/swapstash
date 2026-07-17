import 'package:flutter/material.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<UserProfile> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _firestoreService.searchUsers(query);

      if (!mounted) return;

      setState(() {
        _results = results;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _results = [];
        _errorMessage = 'Uporabnikov ni bilo mogoče poiskati:\n$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _results = [];
      _errorMessage = null;
      _isLoading = false;
    });
  }

  void _openUserProfile(UserProfile profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Javni profil uporabnika '
          '${profile.displayName} bo dodan v naslednjem koraku.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Zbiratelji')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Išči zbiratelja',
                hintText: 'Vpiši prikazno ime',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: hasQuery
                    ? IconButton(
                        tooltip: 'Počisti iskanje',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: _searchUsers,
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final query = _searchController.text.trim();

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    if (query.isEmpty) {
      return const _EmptySearchView();
    }

    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Ni najdenih zbirateljev.', textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final profile = _results[index];

        return _UserCard(
          profile: profile,
          onTap: () => _openUserProfile(profile),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onTap;

  const _UserCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayName = profile.displayName.trim().isEmpty
        ? 'Neimenovan uporabnik'
        : profile.displayName.trim();

    final locationParts = [
      if (profile.city.trim().isNotEmpty) profile.city.trim(),
      if (profile.country.trim().isNotEmpty) profile.country.trim(),
    ];

    final location = locationParts.join(', ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: profile.photoUrl.trim().isEmpty
              ? null
              : NetworkImage(profile.photoUrl),
          child: profile.photoUrl.trim().isEmpty
              ? Text(displayName.characters.first.toUpperCase())
              : null,
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (location.isNotEmpty) Text(location),
            Text(
              profile.allowInternationalTrades
                  ? 'Mednarodne menjave dovoljene'
                  : 'Samo lokalne menjave',
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64),
            SizedBox(height: 16),
            Text(
              'Poišči druge zbiratelje po prikaznem imenu.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
