import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SeedTestCatalogPage extends StatefulWidget {
  const SeedTestCatalogPage({super.key});

  @override
  State<SeedTestCatalogPage> createState() => _SeedTestCatalogPageState();
}

class _SeedTestCatalogPageState extends State<SeedTestCatalogPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isRunning = false;
  String _status = 'Demo podatki še niso dodani.';

  static const List<_DemoCollection> _demoCollections = [
    _DemoCollection(
      id: 'demo-panini-world-cup-2026',
      name: 'Panini World Cup 2026 — demo',
      publisher: 'Panini',
      category: 'Športne kartice',
      year: 2026,
      items: [
        _DemoItem(name: 'Tournament Emblem', rarity: 'Rare'),
        _DemoItem(name: 'Official Match Ball', rarity: 'Rare'),
        _DemoItem(name: 'Golden Trophy', rarity: 'Limited Edition'),
        _DemoItem(name: 'Leo Marin', rarity: 'Common'),
        _DemoItem(name: 'Luka Novak', rarity: 'Common'),
        _DemoItem(name: 'Mateo Rossi', rarity: 'Common'),
        _DemoItem(name: 'Noah Williams', rarity: 'Common'),
        _DemoItem(name: 'Elias Berg', rarity: 'Common'),
        _DemoItem(name: 'Kenji Sato', rarity: 'Common'),
        _DemoItem(name: 'Thiago Costa', rarity: 'Rare'),
        _DemoItem(name: 'Adam Kowalski', rarity: 'Common'),
        _DemoItem(name: 'Niko Horvat', rarity: 'Rare'),
        _DemoItem(name: 'Amir Rahman', rarity: 'Common'),
        _DemoItem(name: 'Samuel Okoro', rarity: 'Rare'),
        _DemoItem(name: 'Daniel Silva', rarity: 'Common'),
        _DemoItem(name: 'Martin Keller', rarity: 'Common'),
        _DemoItem(name: 'Hugo Laurent', rarity: 'Rare'),
        _DemoItem(name: 'Erik Jensen', rarity: 'Common'),
        _DemoItem(name: 'Alex Petrov', rarity: 'Gold'),
        _DemoItem(name: 'Final Stadium', rarity: 'Limited Edition'),
      ],
    ),
    _DemoCollection(
      id: 'demo-pokemon-tcg',
      name: 'Pokémon TCG — demo',
      publisher: 'The Pokémon Company',
      category: 'Igralne kartice',
      year: 2026,
      items: [
        _DemoItem(name: 'Pikachu', rarity: 'Common'),
        _DemoItem(name: 'Bulbasaur', rarity: 'Common'),
        _DemoItem(name: 'Charmander', rarity: 'Common'),
        _DemoItem(name: 'Squirtle', rarity: 'Common'),
        _DemoItem(name: 'Eevee', rarity: 'Common'),
        _DemoItem(name: 'Snorlax', rarity: 'Rare'),
        _DemoItem(name: 'Gengar', rarity: 'Rare'),
        _DemoItem(name: 'Lucario', rarity: 'Rare'),
        _DemoItem(name: 'Greninja', rarity: 'Rare'),
        _DemoItem(name: 'Dragonite', rarity: 'Rare'),
        _DemoItem(name: 'Mew', rarity: 'Ultra Rare'),
        _DemoItem(name: 'Mewtwo', rarity: 'Ultra Rare'),
        _DemoItem(name: 'Charizard ex', rarity: 'Ultra Rare'),
        _DemoItem(name: 'Gardevoir ex', rarity: 'Ultra Rare'),
        _DemoItem(name: 'Umbreon', rarity: 'Rare'),
        _DemoItem(name: 'Sylveon', rarity: 'Rare'),
        _DemoItem(name: 'Rayquaza', rarity: 'Ultra Rare'),
        _DemoItem(name: 'Lugia', rarity: 'Ultra Rare'),
        _DemoItem(name: 'Zacian', rarity: 'Rare'),
        _DemoItem(name: 'Trainer Trophy', rarity: 'Secret Rare'),
      ],
    ),
    _DemoCollection(
      id: 'demo-lego-minifigures',
      name: 'LEGO Minifigures — demo',
      publisher: 'LEGO',
      category: 'Figurice',
      year: 2026,
      items: [
        _DemoItem(name: 'Space Explorer', rarity: 'Common'),
        _DemoItem(name: 'Forest Archer', rarity: 'Common'),
        _DemoItem(name: 'Castle Knight', rarity: 'Common'),
        _DemoItem(name: 'Robot Mechanic', rarity: 'Common'),
        _DemoItem(name: 'Jungle Researcher', rarity: 'Common'),
        _DemoItem(name: 'Retro Gamer', rarity: 'Rare'),
        _DemoItem(name: 'Ice Queen', rarity: 'Rare'),
        _DemoItem(name: 'Dragon Warrior', rarity: 'Rare'),
        _DemoItem(name: 'Deep Sea Diver', rarity: 'Common'),
        _DemoItem(name: 'Volcano Scientist', rarity: 'Common'),
        _DemoItem(name: 'Moon Commander', rarity: 'Rare'),
        _DemoItem(name: 'Desert Nomad', rarity: 'Common'),
        _DemoItem(name: 'Cyber Ninja', rarity: 'Ultra Rare'),
        _DemoItem(name: 'Haunted Butler', rarity: 'Rare'),
        _DemoItem(name: 'Mountain Rescuer', rarity: 'Common'),
        _DemoItem(name: 'Golden Pharaoh', rarity: 'Ultra Rare'),
        _DemoItem(name: 'Street Magician', rarity: 'Rare'),
        _DemoItem(name: 'Steampunk Pilot', rarity: 'Rare'),
        _DemoItem(name: 'Crystal Guardian', rarity: 'Ultra Rare'),
        _DemoItem(name: 'Mystery Minifigure', rarity: 'Limited Edition'),
      ],
    ),
  ];

  Future<void> _seedDemoData() async {
    if (_isRunning) {
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _status = 'Za dodajanje demo podatkov mora biti uporabnik prijavljen.';
      });
      return;
    }

    setState(() {
      _isRunning = true;
      _status = 'Dodajam demo zbirke in predmete ...';
    });

    try {
      final batch = _db.batch();
      var collectionWrites = 0;
      var catalogItemWrites = 0;
      var userItemWrites = 0;

      for (
        var collectionIndex = 0;
        collectionIndex < _demoCollections.length;
        collectionIndex++
      ) {
        final demo = _demoCollections[collectionIndex];

        final catalogCollectionRef = _db
            .collection('catalogCollections')
            .doc(demo.id);

        batch.set(catalogCollectionRef, {
          'name': demo.name,
          'publisher': demo.publisher,
          'category': demo.category,
          'year': demo.year,
          'totalItems': demo.totalItems,
          'coverImageUrl': '',
          'isActive': true,
          'isDemo': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        collectionWrites++;

        final userCollectionRef = _db
            .collection('users')
            .doc(user.uid)
            .collection('collections')
            .doc(demo.id);

        batch.set(userCollectionRef, {
          'catalogCollectionId': demo.id,
          'createdAt': FieldValue.serverTimestamp(),
          'isDemo': true,
        }, SetOptions(merge: true));

        for (var itemIndex = 0; itemIndex < demo.items.length; itemIndex++) {
          final itemNumber = itemIndex + 1;
          final item = demo.items[itemIndex];
          final itemId = itemNumber.toString().padLeft(4, '0');
          final number = itemNumber.toString().padLeft(3, '0');

          final catalogItemRef = catalogCollectionRef
              .collection('items')
              .doc(itemId);

          batch.set(catalogItemRef, {
            'collectionId': demo.id,
            'number': number,
            'name': item.name,
            'rarity': item.rarity,
            'imageUrl': '',
            'isDemo': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          catalogItemWrites++;

          final quantity = _demoQuantity(
            collectionIndex: collectionIndex,
            itemIndex: itemNumber,
          );

          if (quantity <= 0) {
            continue;
          }

          final userItemRef = userCollectionRef.collection('items').doc(itemId);

          batch.set(userItemRef, {
            'itemId': itemId,
            'quantity': quantity,
            'isDemo': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          userItemWrites++;
        }
      }

      await batch.commit();

      if (!mounted) {
        return;
      }

      setState(() {
        _status =
            'Končano: $collectionWrites demo zbirk, '
            '$catalogItemWrites kataloških predmetov in '
            '$userItemWrites uporabniških vnosov.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo podatki so bili uspešno osveženi.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Dodajanje ni uspelo: $error';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Dodajanje ni uspelo: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  Future<void> _deleteDemoData() async {
    if (_isRunning) {
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _status = 'Za brisanje demo podatkov mora biti uporabnik prijavljen.';
      });
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Izbriši demo podatke?'),
          content: const Text(
            'Izbrisane bodo samo zbirke z vnaprej določenimi demo ID-ji '
            'in njihovi demo predmeti.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Prekliči'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Izbriši'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isRunning = true;
      _status = 'Brišem demo podatke ...';
    });

    try {
      final batch = _db.batch();
      var deletedDocuments = 0;

      for (final demo in _demoCollections) {
        final catalogCollectionRef = _db
            .collection('catalogCollections')
            .doc(demo.id);

        final userCollectionRef = _db
            .collection('users')
            .doc(user.uid)
            .collection('collections')
            .doc(demo.id);

        for (var itemIndex = 0; itemIndex < demo.items.length; itemIndex++) {
          final itemId = (itemIndex + 1).toString().padLeft(4, '0');

          batch.delete(catalogCollectionRef.collection('items').doc(itemId));
          batch.delete(userCollectionRef.collection('items').doc(itemId));
          deletedDocuments += 2;
        }

        batch.delete(userCollectionRef);
        batch.delete(catalogCollectionRef);
        deletedDocuments += 2;
      }

      await batch.commit();

      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Demo podatki so izbrisani ($deletedDocuments dokumentov).';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo podatki so bili izbrisani.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Brisanje ni uspelo: $error';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Brisanje ni uspelo: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  int _demoQuantity({required int collectionIndex, required int itemIndex}) {
    switch (collectionIndex) {
      case 0:
        if (itemIndex <= 9) return 1;
        if (itemIndex <= 12) return 2;
        if (itemIndex == 13) return 3;
        return 0;
      case 1:
        if (itemIndex <= 7) return 1;
        if (itemIndex <= 9) return 2;
        if (itemIndex == 10) return 4;
        return 0;
      case 2:
        if (itemIndex <= 12) return 1;
        if (itemIndex <= 15) return 2;
        return 0;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo podatki')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Ta razvojni zaslon doda tri testne zbirke z realističnimi '
            'imeni predmetov in podatkom o redkosti.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const _DemoInfoCard(
            title: 'Panini World Cup 2026 — demo',
            description: '20 kartic z igralci, simboli in posebnimi izdajami.',
          ),
          const _DemoInfoCard(
            title: 'Pokémon TCG — demo',
            description: '20 kartic od običajnih do Secret Rare.',
          ),
          const _DemoInfoCard(
            title: 'LEGO Minifigures — demo',
            description: '20 poimenovanih figuric različnih redkosti.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _isRunning ? null : _seedDemoData,
            icon: _isRunning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.science_outlined),
            label: Text(
              _isRunning ? 'Obdelujem ...' : 'Dodaj ali osveži demo podatke',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isRunning ? null : _deleteDemoData,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Izbriši demo podatke'),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_status),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoInfoCard extends StatelessWidget {
  final String title;
  final String description;

  const _DemoInfoCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.collections_bookmark_outlined),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}

class _DemoCollection {
  final String id;
  final String name;
  final String publisher;
  final String category;
  final int year;
  final List<_DemoItem> items;

  const _DemoCollection({
    required this.id,
    required this.name,
    required this.publisher,
    required this.category,
    required this.year,
    required this.items,
  });

  int get totalItems => items.length;
}

class _DemoItem {
  final String name;
  final String rarity;

  const _DemoItem({required this.name, required this.rarity});
}
