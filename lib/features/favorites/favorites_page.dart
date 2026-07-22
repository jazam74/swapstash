import 'package:flutter/material.dart';
import 'package:swapstash/core/models/favorite_item.dart';
import 'package:swapstash/core/services/favorite_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearch(String value) {
    setState(() {
      _searchQuery = value.trim().toLowerCase();
    });
  }

  Future<void> _removeFavorite(FavoriteItem item) async {
    try {
      await _favoriteService.toggleFavorite(favorite: item);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item.name.trim().isEmpty
                ? 'Odstranjeno iz priljubljenih.'
                : '${item.name} je odstranjen iz priljubljenih.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Napaka pri odstranjevanju: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<FavoriteItem> _filterFavorites(List<FavoriteItem> favorites) {
    if (_searchQuery.isEmpty) {
      return favorites;
    }

    return favorites
        .where((item) {
          return item.name.toLowerCase().contains(_searchQuery) ||
              item.number.toLowerCase().contains(_searchQuery) ||
              item.collectionId.toLowerCase().contains(_searchQuery);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moji favoriti')),
      body: StreamBuilder<List<FavoriteItem>>(
        stream: _favoriteService.watchFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error);
          }

          final favorites = snapshot.data ?? const <FavoriteItem>[];
          final filteredFavorites = _filterFavorites(favorites);

          if (favorites.isEmpty) {
            return const _EmptyFavoritesView();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _updateSearch,
                  decoration: InputDecoration(
                    hintText: 'Išči med favoriti',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Počisti',
                            onPressed: () {
                              _searchController.clear();
                              _updateSearch('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredFavorites.isEmpty
                    ? _NoResultsView(query: _searchController.text.trim())
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        itemCount: filteredFavorites.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = filteredFavorites[index];

                          return _FavoriteCard(
                            item: item,
                            onRemove: () => _removeFavorite(item),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onRemove;

  const _FavoriteCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _FavoriteImage(imageUrl: item.imageUrl, label: item.name),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.number.trim().isNotEmpty)
                    Text(
                      item.number,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 3),
                  Text(
                    item.name.trim().isEmpty ? 'Brez imena' : item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.collectionId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Odstrani iz favoritov',
              onPressed: onRemove,
              icon: const Icon(Icons.favorite_rounded),
              color: colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteImage extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _FavoriteImage({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 76,
        height: 96,
        color: colorScheme.surfaceContainerHighest,
        child: imageUrl.trim().isEmpty
            ? Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                semanticLabel: label,
                errorBuilder: (_, _, _) => Icon(
                  Icons.broken_image_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  const _EmptyFavoritesView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 72,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Še nimaš favoritov',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'Na podrobnostih kartice pritisni srček in kartica se bo pojavila tukaj.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  final String query;

  const _NoResultsView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          query.isEmpty
              ? 'Ni zadetkov.'
              : 'Za »$query« ni bilo najdenih favoritov.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object? error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64),
            const SizedBox(height: 16),
            Text(
              'Favoritov ni bilo mogoče naložiti.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
