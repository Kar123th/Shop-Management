import 'package:flutter/material.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock Items')),
      body: const Center(child: Text('Low Stock Screen')),
    );
  }
}
