import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/features/users/public_user_profile_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<UserProfile> _results = [];
  Timer? _searchDebounce;
  bool _isLoading = false;
  bool _hasSearched = false;
  int _searchRequestId = 0;
  String? _errorDetails;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String value) async {
    final query = value.trim();
    final requestId = ++_searchRequestId;

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _errorDetails = null;
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorDetails = null;
    });

    try {
      final results = await _firestoreService.searchUsers(query);

      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      setState(() {
        _results = results;
        _hasSearched = true;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      setState(() {
        _results = [];
        _errorDetails = error.toString();
        _hasSearched = true;
      });
    } finally {
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();

    setState(() {
      if (value.trim().isEmpty) {
        _results = [];
        _errorDetails = null;
        _isLoading = false;
        _hasSearched = false;
        _searchRequestId++;
      } else {
        _isLoading = true;
        _hasSearched = false;
      }
    });

    if (value.trim().isEmpty) {
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _searchUsers(value),
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _searchRequestId++;

    setState(() {
      _results = [];
      _errorDetails = null;
      _isLoading = false;
      _hasSearched = false;
    });
  }

  void _openUserProfile(UserProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PublicUserProfilePage(userId: profile.uid, initialProfile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.collectors)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const maxContentWidth = 1280.0;
          const maxSearchWidth = 760.0;

          final horizontalPadding = constraints.maxWidth >= 900 ? 24.0 : 16.0;
          final availableWidth =
              constraints.maxWidth - (horizontalPadding * 2);
          final contentWidth = availableWidth > maxContentWidth
              ? maxContentWidth
              : availableWidth;
          final searchWidth = contentWidth > maxSearchWidth
              ? maxSearchWidth
              : contentWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      constraints.maxWidth >= 900 ? 24 : 16,
                      0,
                      16,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: searchWidth,
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            labelText: localizations.collectorsSearchLabel,
                            hintText: localizations.collectorsSearchHint,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: hasQuery
                                ? IconButton(
                                    tooltip: localizations.clearSearch,
                                    onPressed: _clearSearch,
                                    icon: const Icon(Icons.clear),
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: _scheduleSearch,
                          onSubmitted: (value) {
                            _searchDebounce?.cancel();
                            _searchUsers(value);
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading) const LinearProgressIndicator(),
                  Expanded(child: _buildContent(localizations)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(AppLocalizations localizations) {
    final query = _searchController.text.trim();

    if (_errorDetails != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            localizations.collectorsSearchError(_errorDetails!),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (query.isEmpty) {
      return const _EmptySearchView();
    }

    if ((_isLoading || !_hasSearched) && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            localizations.collectorsNoResults,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final int columnCount;

        if (constraints.maxWidth >= 1080) {
          columnCount = 3;
        } else if (constraints.maxWidth >= 700) {
          columnCount = 2;
        } else {
          columnCount = 1;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
          itemCount: _results.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 104,
          ),
          itemBuilder: (context, index) {
            final profile = _results[index];

            return _UserCard(
              profile: profile,
              onTap: () => _openUserProfile(profile),
            );
          },
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
    final localizations = AppLocalizations.of(context)!;
    final displayName = profile.displayName.trim().isEmpty
        ? localizations.unnamedUser
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
                  ? localizations.collectorsInternationalAllowed
                  : localizations.collectorsLocalOnly,
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
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              localizations.collectorsSearchDescription,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
