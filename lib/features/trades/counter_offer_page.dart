import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_item.dart';
import 'package:swapstash/core/services/inventory_compare_service.dart';
import 'package:swapstash/core/services/trade_service.dart';

class CounterOfferPage extends StatefulWidget {
  final Trade trade;

  const CounterOfferPage({super.key, required this.trade});

  @override
  State<CounterOfferPage> createState() => _CounterOfferPageState();
}

class _CounterOfferPageState extends State<CounterOfferPage> {
  final InventoryCompareService _compareService = InventoryCompareService();
  final TradeService _tradeService = TradeService();

  late Future<void> _future;
  List<CatalogItem> _senderCanOffer = [];
  List<CatalogItem> _receiverCanOffer = [];
  final Set<String> _selectedOfferedIds = {};
  final Set<String> _selectedRequestedIds = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _load() async {
    final collectionId = _collectionId;

    final comparison = await _compareService.compare(
      collectionId: collectionId,
      currentUserId: widget.trade.senderId,
      otherUserId: widget.trade.receiverId,
    );

    final offeredById = <String, CatalogItem>{
      for (final item in comparison.canOffer) item.id: item,
    };
    final requestedById = <String, CatalogItem>{
      for (final item in comparison.needs) item.id: item,
    };

    for (final tradeItem in widget.trade.offeredItems) {
      if (tradeItem.hasItemId) {
        _selectedOfferedIds.add(tradeItem.itemId);
      }
    }

    for (final tradeItem in widget.trade.requestedItems) {
      if (tradeItem.hasItemId) {
        _selectedRequestedIds.add(tradeItem.itemId);
      }
    }

    _senderCanOffer = offeredById.values.toList();
    _receiverCanOffer = requestedById.values.toList();
  }

  String get _collectionId {
    final all = [...widget.trade.offeredItems, ...widget.trade.requestedItems];

    if (all.isEmpty) {
      throw Exception('Menjava nima določene zbirke.');
    }

    return all.first.collectionId;
  }

  bool get _currentUserIsSender =>
      FirebaseAuth.instance.currentUser?.uid == widget.trade.senderId;

  Future<void> _sendCounterOffer() async {
    if (_selectedOfferedIds.isEmpty || _selectedRequestedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Protiponudba mora vsebovati vsaj en predmet na obeh straneh.',
          ),
        ),
      );
      return;
    }

    final offered = _senderCanOffer
        .where((item) => _selectedOfferedIds.contains(item.id))
        .map(
          (item) => TradeItem(
            collectionId: _collectionId,
            itemId: item.id,
            itemNumber: item.number,
            quantity: 1,
          ),
        )
        .toList();

    final requested = _receiverCanOffer
        .where((item) => _selectedRequestedIds.contains(item.id))
        .map(
          (item) => TradeItem(
            collectionId: _collectionId,
            itemId: item.id,
            itemNumber: item.number,
            quantity: 1,
          ),
        )
        .toList();

    if (offered.isEmpty || requested.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Izbrane kartice niso več razpoložljive za protiponudbo.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _tradeService.counterTrade(
        tradeId: widget.trade.id,
        offeredItems: offered,
        requestedItems: requested,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Protiponudbe ni bilo mogoče poslati: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstTitle = _currentUserIsSender ? 'Ti oddaš' : 'Ti prejmeš';
    final secondTitle = _currentUserIsSender ? 'Ti prejmeš' : 'Ti oddaš';

    return Scaffold(
      appBar: AppBar(title: const Text('Protiponudba')),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Kartic ni bilo mogoče naložiti:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                'Spremeni ponudbo. Razmerje ni omejeno, zato lahko '
                'na primer predlog 3 za 3 spremeniš v 5 za 3.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _SelectionSection(
                title: firstTitle,
                items: _senderCanOffer,
                selectedIds: _selectedOfferedIds,
                onChanged: (itemId, selected) {
                  setState(() {
                    if (selected) {
                      _selectedOfferedIds.add(itemId);
                    } else {
                      _selectedOfferedIds.remove(itemId);
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              _SelectionSection(
                title: secondTitle,
                items: _receiverCanOffer,
                selectedIds: _selectedRequestedIds,
                onChanged: (itemId, selected) {
                  setState(() {
                    if (selected) {
                      _selectedRequestedIds.add(itemId);
                    } else {
                      _selectedRequestedIds.remove(itemId);
                    }
                  });
                },
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _saving ? null : _sendCounterOffer,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.swap_horiz),
                label: Text(_saving ? 'Pošiljam...' : 'Pošlji protiponudbo'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectionSection extends StatelessWidget {
  final String title;
  final List<CatalogItem> items;
  final Set<String> selectedIds;
  final void Function(String itemId, bool selected) onChanged;

  const _SelectionSection({
    required this.title,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (${selectedIds.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              const Text('Ni razpoložljivih predmetov.')
            else
              ...items.map(
                (item) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: selectedIds.contains(item.id),
                  onChanged: (value) {
                    onChanged(item.id, value ?? false);
                  },
                  title: Text(
                    item.name.trim().isEmpty
                        ? item.number
                        : '${item.number} · ${item.name}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
