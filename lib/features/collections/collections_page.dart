import 'package:flutter/material.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje zbirke'),
      ),
      body: const Center(
        child: Text(
          'Še nimaš nobene zbirke.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // naslednji korak
        },
        icon: const Icon(Icons.add),
        label: const Text('Dodaj zbirko'),
      ),
    );
  }
}