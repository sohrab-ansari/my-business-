import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/customer_viewmodel.dart';
import '../../viewmodels/bill_viewmodel.dart';
import '../../models/product.dart';
import '../../theme/theme.dart';

class CreateBillScreen extends StatefulWidget {
  const CreateBillScreen({super.key});

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  String? selectedCustomer;
  final List<Map<String, dynamic>> cart = []; // productId, name, price, qty
  double total = 0;
  final paidController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere((item) => item['productId'] == product.id);
      if (index != -1) {
        cart[index]['qty']++;
      } else {
        cart.add({
          'productId': product.id,
          'name': product.name,
          'price': product.sellingPrice,
          'qty': 1,
        });
      }
      _recalcTotal();
    });
  }

  void _recalcTotal() {
    total = cart.fold(0, (sum, item) => sum + (item['price'] * item['qty']));
  }

  void updateQty(int index, int qty) {
    if (qty <= 0) {
      cart.removeAt(index);
    } else {
      cart[index]['qty'] = qty;
    }
    _recalcTotal();
    setState(() {});
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select customer')));
      return;
    }
    final paid = double.tryParse(paidController.text);
    if (paid == null || paid < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid paid amount')));
      return;
    }
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    final billVM = Provider.of<BillViewModel>(context, listen: false);
    try {
      await billVM.createBill(
        customerName: selectedCustomer!,
        cart: cart,
        paidAmount: paid,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill created!')));
        Navigator.pop(context);
      }
    } catch (e, stack) {
       print("======== BILL ERROR ========");
  print(e);
  print(stack);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(billVM.errorMessage ?? 'Error'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productVM = Provider.of<ProductViewModel>(context);
    final customerVM = Provider.of<CustomerViewModel>(context);
    final billVM = Provider.of<BillViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Bill')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Customer dropdown
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: StreamBuilder(
                          stream: customerVM.getCustomers(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                            final customers = snapshot.data!;
                            return DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Customer'),
                              value: selectedCustomer,
                              items: customers.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                              onChanged: (v) => setState(() => selectedCustomer = v),
                              validator: (v) => v == null ? 'Select customer' : null,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Products list
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Products', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
                              child: StreamBuilder(
                                stream: productVM.getProducts(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                  final products = snapshot.data!;
                                  final inStock = products.where((p) => p.stock > 0).toList();
                                  if (inStock.isEmpty) return const Center(child: Text('No stock'));
                                  return ListView.builder(
                                    itemCount: inStock.length,
                                    itemBuilder: (_, i) => ListTile(
                                      title: Text(inStock[i].name),
                                      subtitle: Text('₹${inStock[i].sellingPrice} | Stock: ${inStock[i].stock}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.add_circle, color: AppColors.primary),
                                        onPressed: () => addToCart(inStock[i]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Cart
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text('Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                if (cart.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () => setState(() => cart.clear()),
                                    icon: const Icon(Icons.delete_sweep),
                                    label: const Text('Clear'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (cart.isEmpty)
                              const Padding(padding: EdgeInsets.all(20), child: Text('No items')),
                            ...cart.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(item['name'])),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                        onPressed: () => updateQty(idx, item['qty'] - 1),
                                      ),
                                      Text('${item['qty']}'),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => updateQty(idx, item['qty'] + 1),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('₹${(item['price'] * item['qty']).toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Payment
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:'), Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: paidController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Paid Amount'),
                              validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: billVM.isLoading ? null : _saveBill,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: billVM.isLoading ? const CircularProgressIndicator() : const Text('Save Bill'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}