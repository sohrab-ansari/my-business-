import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/PRODUCT_LIST_SCREEN.dart';
import '../../screens/add_products_screens.dart';
import '../../screens/create_bill_screen.dart';
import '../../screens/customer_list_screen.dart';
import '../../screens/history_screen.dart';
import '../../screens/pending.dart';
import '../../screens/profit_loss_screen.dart';
import '../../screens/sold_product_screen.dart';
import '../../theme/theme.dart';
import '../../viewmodels/auth_viewmidel.dart';
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final userEmail = authVM.currentUser?.email ?? 'Owner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authVM.logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => Future.delayed(const Duration(milliseconds: 500)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeCard(email: userEmail),
              const SizedBox(height: 28),
              const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _DashboardCard(
                    icon: Icons.add_shopping_cart,
                    title: 'Add Product',
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
                  ),
                  _DashboardCard(
                    icon: Icons.inventory,
                    title: 'View Products',
                    color: Colors.teal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())),
                  ),
                  _DashboardCard(
                    icon: Icons.assessment,
                    title: 'Profit & Loss',
                    color: Colors.deepPurple,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitLossScreen())),
                  ),
                  _DashboardCard(
                    icon: Icons.people,
                    title: 'Customers',
                    color: Colors.purple,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())),
                  ),
                  _DashboardCard(
                    icon: Icons.receipt,
                    title: 'Create Bill',
                    color: Colors.green,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateBillScreen())),
                  ),
                  _DashboardCard(
                    icon: Icons.history,
                    title: 'Transactions',
                    color: Colors.indigo,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryScreen())),
                  ),
                  _DashboardCard(
                    icon: Icons.pending_actions,
                    title: 'Pending Dues',
                    color: Colors.orange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerPendingScreen())),
                  ),
                  _DashboardCard(
                    icon: Icons.sell,
                    title: 'Sold Products',
                    color: Colors.brown,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoldProductsScreen())),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String email;
  const _WelcomeCard({required this.email});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.store, size: 36, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome Back!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}