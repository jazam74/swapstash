import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/trade_candidate.dart';
import 'package:swapstash/core/models/trade_item.dart';
import 'package:swapstash/core/services/chat_service.dart';
import 'package:swapstash/core/services/trade_service.dart';
import 'package:swapstash/features/messages/chat_page.dart';

class TradeDetailPage extends StatefulWidget {
  final CatalogCollection collection;
  final TradeCandidate candidate;

  const TradeDetailPage({
    super.key,
    required this.collection,
    required this.candidate,
  });

  @override
  State<TradeDetailPage> createState() => _TradeDetailPageState();
}

class _TradeDetailPageState extends State<TradeDetailPage> {
  final ChatService _chatService = ChatService();
  final TradeService _tradeService = TradeService();

  bool _openingChat = false;
  bool _creatingTrade = false;

  Future<void> _openChat() async {
    if (_openingChat) {
      return;
    }

    setState(() {
      _openingChat = true;
    });

    try {
      final member = widget.candidate.member;

      final conversation = await _chatService.getOrCreateConversation(
        collectionId: widget.collection.id,
        collectionName: widget.collection.name,
        otherUserId: member.uid,
        otherUserName: member.displayName,
        otherUserPhotoUrl: member.photoUrl,
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatPage(conversation: conversation)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pogovora ni bilo mogoče odpreti:\n$error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingChat = false;
        });
      }
    }
  }

  Future<void> _createAutomaticTradeProposal() async {
    if (_creatingTrade) {
      return;
    }

    final comparison = widget.candidate.comparison;
    final tradeCount = comparison.possibleTrades;

    if (tradeCount <= 0) {
      return;
    }

    // InventoryCompareService already sorts both lists so that items
    // with the largest number of duplicates come first.
    final offeredCatalogItems = comparison.canOffer.take(tradeCount).toList();
    final requestedCatalogItems = comparison.needs.take(tradeCount).toList();

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Samodejni predlog menjave'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SwapStash predlaga uravnoteženo menjavo '
                    '$tradeCount za $tradeCount.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ti ponudiš:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...offeredCatalogItems.map(
                    (item) => Text(
                      '• ${item.number}'
                      '${item.name.trim().isEmpty ? '' : ' · ${item.name}'}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.candidate.member.displayName} ponudi:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...requestedCatalogItems.map(
                    (item) => Text(
                      '• ${item.number}'
                      '${item.name.trim().isEmpty ? '' : ' · ${item.name}'}',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Prekliči'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.send),
              label: const Text('Pošlji predlog'),
            ),
          ],
        );
      },
    );

    if (shouldCreate != true || !mounted) {
      return;
    }

    setState(() {
      _creatingTrade = true;
    });

    try {
      final offeredItems = offeredCatalogItems
          .map(
            (item) => TradeItem(
              collectionId: widget.collection.id,
              itemId: item.id,
              itemNumber: item.number,
              quantity: 1,
            ),
          )
          .toList();

      final requestedItems = requestedCatalogItems
          .map(
            (item) => TradeItem(
              collectionId: widget.collection.id,
              itemId: item.id,
              itemNumber: item.number,
              quantity: 1,
            ),
          )
          .toList();

      await _tradeService.createTrade(
        receiverId: widget.candidate.member.uid,
        offeredItems: offeredItems,
        requestedItems: requestedItems,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Predlog menjave je bil uspešno poslan.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Predloga menjave ni bilo mogoče poslati:\n$error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _creatingTrade = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    final member = candidate.member;
    final comparison = candidate.comparison;

    return Scaffold(
      appBar: AppBar(title: const Text('Primerjava menjave')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MemberHeader(candidate: candidate),
          const SizedBox(height: 20),
          _SummaryCard(candidate: candidate),
          const SizedBox(height: 20),
          _ItemsSection(
            title: 'Ti lahko ponudiš',
            description: 'Tvoji viški, ki jih ta uporabnik še nima.',
            icon: Icons.upload_rounded,
            items: comparison.canOffer,
            emptyMessage:
                '${member.displayName} trenutno ne potrebuje nobenega tvojega viška.',
          ),
          const SizedBox(height: 20),
          _ItemsSection(
            title: '${member.displayName} lahko ponudi',
            description: 'Njegovi viški, ki jih ti še nimaš.',
            icon: Icons.download_rounded,
            items: comparison.needs,
            emptyMessage:
                '${member.displayName} trenutno nima viškov, ki bi jih potreboval.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed:
                comparison.hasPossibleTrade && !_openingChat && !_creatingTrade
                ? _createAutomaticTradeProposal
                : null,
            icon: _creatingTrade
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              _creatingTrade
                  ? 'Pošiljam predlog...'
                  : 'Samodejno predlagaj menjavo',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed:
                comparison.hasPossibleTrade && !_openingChat && !_creatingTrade
                ? _openChat
                : null,
            icon: _openingChat
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chat_bubble_outline),
            label: Text(
              _openingChat
                  ? 'Odpiram pogovor...'
                  : 'Pošlji sporočilo uporabniku ${member.displayName}',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openingChat
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Nazaj na rezultate'),
          ),
        ],
      ),
    );
  }
}

class _MemberHeader extends StatelessWidget {
  final TradeCandidate candidate;

  const _MemberHeader({required this.candidate});

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: member.photoUrl.trim().isNotEmpty
              ? NetworkImage(member.photoUrl)
              : null,
          child: member.photoUrl.trim().isEmpty
              ? Text(initial, style: Theme.of(context).textTheme.headlineSmall)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName.isEmpty ? 'Neimenovan uporabnik' : displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (locationParts.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 4),
                    Expanded(child: Text(locationParts.join(', '))),
                  ],
                ),
              ],
              if (member.allowInternationalTrades) ...[
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.public, size: 18),
                    SizedBox(width: 4),
                    Expanded(child: Text('Dovoljuje mednarodne menjave')),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TradeCandidate candidate;

  const _SummaryCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final comparison = candidate.comparison;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${candidate.possibleTrades} možnih menjav',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryValue(
                    icon: Icons.upload_rounded,
                    value: comparison.canOffer.length,
                    label: 'Lahko ponudiš',
                  ),
                ),
                Expanded(
                  child: _SummaryValue(
                    icon: Icons.download_rounded,
                    value: comparison.needs.length,
                    label: 'Lahko dobiš',
                  ),
                ),
                Expanded(
                  child: _SummaryValue(
                    icon: Icons.inventory_2_outlined,
                    value: candidate.duplicateCount,
                    label: 'Njegovi viški',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _SummaryValue({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 6),
        Text('$value', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<CatalogItem> items;
  final String emptyMessage;

  const _ItemsSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.items,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('${items.length}'),
              ],
            ),
            const SizedBox(height: 6),
            Text(description, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Text(emptyMessage)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) {
                  return Chip(
                    avatar: const Icon(
                      Icons.collections_bookmark_outlined,
                      size: 18,
                    ),
                    label: Text(
                      item.name.trim().isEmpty
                          ? item.number
                          : '${item.number} · ${item.name}',
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
