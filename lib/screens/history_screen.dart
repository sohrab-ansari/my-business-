import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sale.dart';
import '../../viewmodels/sales_viewmodel.dart';
import 'customer_detail_screen.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SalesViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: StreamBuilder<List<Sale>>(
        stream: vm.getAllSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final sales = snapshot.data ?? [];
          if (sales.isEmpty) {
            return const Center(child: Text('No transactions'));
          }
          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (_, i) {
              final s = sales[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerName: s.customerName)),
                  ),
                  leading: const Icon(Icons.receipt),
                  title: Text('${s.productName} x${s.qty}'),
                  subtitle: Text('Customer: ${s.customerName} | Bill: ${s.billId.length > 6 ? s.billId.substring(s.billId.length - 6) : s.billId}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('₹${s.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Profit: ₹${s.profit.toStringAsFixed(2)}', style: TextStyle(color: s.profit >= 0 ? Colors.green : Colors.red)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}