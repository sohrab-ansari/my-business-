import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/sales_viewmodel.dart';

class SoldProductsScreen extends StatelessWidget {
  const SoldProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SalesViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sold Products Summary')),
      body: StreamBuilder<Map<String, int>>(
        stream: vm.getSoldProductsSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final summary = snapshot.data ?? {};
          if (summary.isEmpty) {
            return const Center(child: Text('No products sold yet'));
          }
          final entries = summary.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final entry = entries[i];
              return ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text(entry.key),
                trailing: Text('${entry.value} sold', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          );
        },
      ),
    );
  }
}