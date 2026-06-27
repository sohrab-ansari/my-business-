import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/customer_viewmodel.dart';
import '../../models/bill.dart';
import '../services/pdf_services.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String customerName;
  const CustomerDetailScreen({super.key, required this.customerName});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CustomerViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text(customerName)),
      body: StreamBuilder<List<Bill>>(
        stream: vm.getBillsForCustomer(customerName),
        builder: (context, billSnapshot) {
          if (billSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bills = billSnapshot.data ?? [];
          double totalPending = bills.fold(0, (sum, b) => sum + b.pendingAmount);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Total Outstanding', style: TextStyle(fontSize: 16)),
                        Text('₹${totalPending.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final bill = bills[i];
                    return ExpansionTile(
                      title: Text('Bill #${bill.billId.substring(bill.billId.length > 6 ? bill.billId.length - 6 : 0)}'),
                      subtitle: Text('Date: ${_formatDate(bill.createdAt)} | Pending: ₹${bill.pendingAmount.toStringAsFixed(2)}'),
                      children: [
                        // Bill items
                        ...bill.items.map((item) => ListTile(
                          title: Text(item['name']),
                          trailing: Text('${item['qty']} x ₹${item['price']} = ₹${(item['qty'] * item['price']).toStringAsFixed(2)}'),
                        )),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total: ₹${bill.totalAmount.toStringAsFixed(2)} | Paid: ₹${bill.paidAmount.toStringAsFixed(2)}'),
                              if (bill.pendingAmount > 0)
                                ElevatedButton(
                                  onPressed: () => _showPaymentDialog(context, bill.billId, bill.pendingAmount),
                                  child: const Text('Record Payment'),
                                ),
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                onPressed: () => PdfService.generateBill(
                                  billNumber: bill.billId,
                                  customerName: customerName,
                                  date: bill.createdAt,
                                  items: bill.items,
                                  total: bill.totalAmount,
                                  paid: bill.paidAmount,
                                  pending: bill.pendingAmount,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: bills.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _showPaymentDialog(BuildContext context, String billId, double maxAmount) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Payment'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount (max ₹$maxAmount)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount <= maxAmount && amount > 0) {
                final vm = Provider.of<CustomerViewModel>(context, listen: false);
                await vm.recordPayment(customerName, billId, amount);
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount')));
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }
}