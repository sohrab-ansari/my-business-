import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/utils_helper.dart';
import '../viewmodels/customer_viewmodel.dart';   // ← correct import

class AddCustomerScreen extends StatelessWidget {
  AddCustomerScreen({super.key});

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CustomerViewModel>(context, listen: false);  // ← correct ViewModel

    return Scaffold(
      appBar: AppBar(title: const Text("Add Customer")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Customer Name"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await vm.addCustomer(name);
                  if (context.mounted) {
                    UiHelpers.showSnackBar(context, 'Customer added');
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}