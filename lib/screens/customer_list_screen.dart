import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/customer_viewmodel.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CustomerViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: StreamBuilder(
        stream: vm.getCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final customers = snapshot.data!;
          if (customers.isEmpty) {
            return const Center(child: Text('No customers yet'));
          }
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (_, i) {
              final c = customers[i];
              return ListTile(
                title: Text(c.name),
                subtitle: Text('Pending: ₹${c.pendingBalance.toStringAsFixed(2)}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerName: c.name)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Add Customer',
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Customer'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Customer Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final vm = Provider.of<CustomerViewModel>(context, listen: false);
                await vm.addCustomer(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}