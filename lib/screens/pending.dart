import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/customer_viewmodel.dart';
import '../../models/customer.dart';
import 'customer_detail_screen.dart';

class CustomerPendingScreen extends StatelessWidget {
  const CustomerPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CustomerViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Balances')),
      body: StreamBuilder<List<Customer>>(
        stream: vm.getCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final customers = snapshot.data ?? [];
          final withPending = customers.where((c) => c.pendingBalance > 0).toList();
          if (withPending.isEmpty) {
            return const Center(child: Text('No pending dues'));
          }
          return ListView.builder(
            itemCount: withPending.length,
            itemBuilder: (_, i) {
              final c = withPending[i];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(c.name),
                subtitle: Text('Pending: ₹${c.pendingBalance.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerName: c.name))),
              );
            },
          );
        },
      ),
    );
  }
}