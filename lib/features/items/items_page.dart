import 'package:flutter/material.dart';

class ItemsPage extends StatelessWidget {
  final String collectionName;
  final int totalItems;

  const ItemsPage({
    super.key,
    required this.collectionName,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collectionName),
      ),
      body: Center(
        child: Text(
          '$totalItems predmetov',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}