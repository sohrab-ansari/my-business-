import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../theme/theme.dart';
import 'add_products_screens.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: vm.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data!;
          final filtered = _searchQuery.isEmpty ? products : products.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
          if (filtered.isEmpty) {
            return const Center(child: Text('No products found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final p = filtered[index];
              final isLowStock = p.stock < 5;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _showAddStockDialog(context, p.id, p.stock),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.inventory, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('₹${p.sellingPrice} | CP: ₹${p.costPrice}', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: isLowStock ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                          child: Text('${p.stock} left', style: TextStyle(color: isLowStock ? Colors.red : Colors.green, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          onPressed: () => _showAddStockDialog(context, p.id, p.stock),
                          tooltip: 'Add Stock',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAddStockDialog(BuildContext context, String productId, int currentStock) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Stock'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity to add', hintText: 'Enter positive number'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final qty = int.tryParse(v);
              if (qty == null || qty <= 0) return 'Enter valid quantity';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final added = int.parse(controller.text);
                final vm = Provider.of<ProductViewModel>(context, listen: false);
                await vm.addStock(productId, currentStock, added);
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock updated')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}