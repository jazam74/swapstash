import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';

class CreateTradePage extends StatefulWidget {
  const CreateTradePage({super.key});

  @override
  State<CreateTradePage> createState() =>
      _CreateTradePageState();
}

class _CreateTradePageState extends State<CreateTradePage> {
  final FirestoreService _firestoreService =
      FirestoreService();

  final TextEditingController _searchController =
      TextEditingController();

  Timer? _searchDebounce;

  List<UserProfile> _searchResults = [];
  UserProfile? _selectedUser;

  bool _isSearching = false;
  String? _searchError;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchUsers(query),
    );
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final users =
          await _firestoreService.searchUsers(query);

      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid;

      final filteredUsers = users.where((user) {
        return user.uid != currentUserId;
      }).toList();

      if (!mounted) return;

      setState(() {
        _searchResults = filteredUsers;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _searchError =
            'Uporabnikov ni bilo mogoče poiskati:\n$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _selectUser(UserProfile user) {
    setState(() {
      _selectedUser = user;
      _searchResults = [];
      _searchError = null;
      _searchController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  void _clearSelectedUser() {
    setState(() {
      _selectedUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova menjava'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Prejemnik',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          if (_selectedUser == null) ...[
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Išči uporabnika po imenu...',
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Počisti iskanje',
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchResults = [];
                            _searchError = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value);
              },
            ),
            const SizedBox(height: 10),

            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_searchError != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _searchError!,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_searchController.text.trim().isNotEmpty &&
                _searchResults.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Ni uporabnikov, ki ustrezajo iskanju.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ..._searchResults.map(
                (user) => Card(
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        _initials(user.displayName),
                      ),
                    ),
                    title: Text(
                      user.displayName.isEmpty
                          ? 'Neimenovan uporabnik'
                          : user.displayName,
                    ),
                    subtitle: Text(user.email),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () => _selectUser(user),
                  ),
                ),
              ),
          ] else
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    _initials(
                      _selectedUser!.displayName,
                    ),
                  ),
                ),
                title: Text(
                  _selectedUser!.displayName.isEmpty
                      ? 'Neimenovan uporabnik'
                      : _selectedUser!.displayName,
                ),
                subtitle: Text(
                  _selectedUser!.email,
                ),
                trailing: IconButton(
                  tooltip: 'Odstrani prejemnika',
                  onPressed: _clearSelectedUser,
                  icon: const Icon(Icons.close),
                ),
              ),
            ),

          const SizedBox(height: 24),

          Text(
            'Ponujam',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Seznam predmetov pride v naslednjem koraku.',
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Želim',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Seznam želenih predmetov pride v naslednjem koraku.',
              ),
            ),
          ),

          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: _selectedUser == null
                ? null
                : () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Izbira predmetov pride v naslednjem koraku.',
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Nadaljuj'),
          ),
        ],
      ),
    );
  }

  static String _initials(String displayName) {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}'
            '${parts.last.characters.first}'
        .toUpperCase();
  }
}