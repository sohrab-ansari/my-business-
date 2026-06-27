import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../utils/utils_helper.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpController = TextEditingController();
  final _spController = TextEditingController();

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final vm = Provider.of<ProductViewModel>(context, listen: false);
      try {
        await vm.addProduct(
          name: _nameController.text.trim(),
          cp: double.parse(_cpController.text.trim()),
          sp: double.parse(_spController.text.trim()),
        );
        if (context.mounted) {
          UiHelpers.showSnackBar(context, 'Product saved');
          Navigator.pop(context);
        }
      } catch (e) {
        UiHelpers.showSnackBar(context, vm.errorMessage ?? 'Error', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 20),
              TextFormField(controller: _cpController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost Price'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 20),
              TextFormField(controller: _spController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling Price'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: _save, child: const Text('Save Product')),
            ],
          ),
        ),
      ),
    );
  }
}