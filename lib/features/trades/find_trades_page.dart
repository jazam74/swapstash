import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/trade_candidate.dart';
import 'package:swapstash/core/services/trade_finder_service.dart';
import 'package:swapstash/features/trades/trade_detail_page.dart';

class FindTradesPage extends StatefulWidget {
  final CatalogCollection collection;

  const FindTradesPage({super.key, required this.collection});

  @override
  State<FindTradesPage> createState() => _FindTradesPageState();
}

class _FindTradesPageState extends State<FindTradesPage> {
  final TradeFinderService _service = TradeFinderService();

  late Future<List<TradeCandidate>> _future;

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  void _loadTrades() {
    _future = _service.findTrades(collectionId: widget.collection.id);
  }

  Future<void> _refreshTrades() async {
    setState(_loadTrades);
    await _future;
  }

  void _openCandidate(TradeCandidate candidate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TradeDetailPage(
          collection: widget.collection,
          candidate: candidate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Najdi menjave')),
      body: FutureBuilder<List<TradeCandidate>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(
              error: snapshot.error,
              onRetry: () {
                setState(_loadTrades);
              },
            );
          }

          final candidates = snapshot.data ?? <TradeCandidate>[];

          if (candidates.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshTrades,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(Icons.handshake_outlined, size: 64),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Trenutno ni najdenih možnih menjav.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Preveri, ali imaš označene viške in ali drugi uporabniki uporabljajo isto zbirko.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshTrades,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final candidate = candidates[index];

                return _TradeCandidateCard(
                  rank: index + 1,
                  candidate: candidate,
                  onTap: () => _openCandidate(candidate),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TradeCandidateCard extends StatelessWidget {
  final int rank;
  final TradeCandidate candidate;
  final VoidCallback onTap;

  const _TradeCandidateCard({
    required this.rank,
    required this.candidate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final member = candidate.member;
    final displayName = member.displayName.trim();
    final initial = displayName.isEmpty
        ? '?'
        : displayName.substring(0, 1).toUpperCase();

    final locationParts = <String>[
      if (member.city.trim().isNotEmpty) member.city.trim(),
      if (member.country.trim().isNotEmpty) member.country.trim(),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: member.photoUrl.trim().isNotEmpty
                        ? NetworkImage(member.photoUrl)
                        : null,
                    child: member.photoUrl.trim().isEmpty
                        ? Text(initial)
                        : null,
                  ),
                  Positioned(
                    right: -6,
                    top: -6,
                    child: CircleAvatar(
                      radius: 11,
                      child: Text(
                        '$rank',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isEmpty
                          ? 'Neimenovan uporabnik'
                          : displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (locationParts.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        locationParts.join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.handshake_outlined,
                          label: '${candidate.possibleTrades} menjav',
                        ),
                        _InfoChip(
                          icon: Icons.upload_rounded,
                          label:
                              '${candidate.comparison.canOffer.length} ponudiš',
                        ),
                        _InfoChip(
                          icon: Icons.download_rounded,
                          label: '${candidate.comparison.needs.length} dobiš',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Menjav ni bilo mogoče naložiti.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Poskusi znova'),
            ),
          ],
        ),
      ),
    );
  }
}
