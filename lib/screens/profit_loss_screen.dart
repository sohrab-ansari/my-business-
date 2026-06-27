// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/sales_viewmodel.dart';
import '../../models/sale.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  DateTimeRange? _dateRange;
  List<Sale> _sales = [];
  double totalSales = 0, totalCost = 0, totalProfit = 0;
  Map<String, double> productSales = {}, productCost = {}, productProfit = {};

  @override
  void initState() {
    super.initState();
    _dateRange = DateTimeRange(
      start: DateTime(DateTime.now().year, DateTime.now().month, 1),
      end: DateTime.now(),
    );
  }

  void _fetchData(SalesViewModel vm) async {
    final sales = await vm
        .getAllSales(startDate: _dateRange!.start, endDate: _dateRange!.end)
        .first;
    setState(() {
      _sales = sales;
      totalSales = _sales.fold(0, (sum, s) => sum + s.totalAmount);
      totalCost = _sales.fold(0, (sum, s) => sum + (s.costPriceAtSale * s.qty));
      totalProfit = _sales.fold(0, (sum, s) => sum + s.profit);
      // product-wise aggregation
      productSales.clear();
      productCost.clear();
      productProfit.clear();
      for (var s in _sales) {
        productSales[s.productName] =
            (productSales[s.productName] ?? 0) + s.totalAmount;
        productCost[s.productName] =
            (productCost[s.productName] ?? 0) + (s.costPriceAtSale * s.qty);
        productProfit[s.productName] =
            (productProfit[s.productName] ?? 0) + s.profit;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SalesViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profit & Loss')),

      // body: Column(
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.all(16),
      //       child: InkWell(
      //         onTap: () async {
      //           final picked = await showDateRangePicker(
      //             context: context,
      //             firstDate: DateTime(2020),
      //             lastDate: DateTime.now(),
      //             initialDateRange: _dateRange,
      //           );
      //           if (picked != null) {
      //             setState(() => _dateRange = picked);
      //             _fetchData(vm);
      //           }
      //         },
      //         child: Container(
      //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      //           decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
      //           child: Row(children: [
      //             const Icon(Icons.calendar_today),
      //             const SizedBox(width: 8),
      //             Text('${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}'),
      //           ]),
      //         ),
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(16),
      //       child: GridView.count(
      //         shrinkWrap: true,
      //         physics: const NeverScrollableScrollPhysics(),
      //         crossAxisCount: 2,
      //         crossAxisSpacing: 16,
      //         mainAxisSpacing: 16,
      //         children: [
      //           _SummaryCard(title: 'Total Sales', amount: totalSales, color: Colors.blue, icon: Icons.shopping_cart),
      //           _SummaryCard(title: 'Total Cost', amount: totalCost, color: Colors.red, icon: Icons.money_off),
      //           _SummaryCard(title: 'Total Profit', amount: totalProfit, color: Colors.green, icon: Icons.trending_up),
      //           _SummaryCard(title: 'Margin', amount: totalSales > 0 ? (totalProfit / totalSales) * 100 : 0, color: Colors.purple, icon: Icons.percent, isPercentage: true),
      //         ],
      //       ),
      //     ),
      //     const Divider(),
      //     const Padding(padding: EdgeInsets.all(16), child: Text('Product-wise Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      //     Expanded(
      //       child: ListView.builder(
      //         itemCount: productSales.keys.length,
      //         itemBuilder: (context, i) {
      //           final name = productSales.keys.elementAt(i);
      //           return Card(
      //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      //             child: ListTile(
      //               title: Text(name),
      //               subtitle: Text('Qty: ${(_sales.where((s) => s.productName == name).fold(0, (sum, s) => sum + s.qty)).toInt()}'),
      //               trailing: Column(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 crossAxisAlignment: CrossAxisAlignment.end,
      //                 children: [
      //                   Text('Sales: ₹${productSales[name]!.toStringAsFixed(2)}'),
      //                   Text('Profit: ₹${productProfit[name]!.toStringAsFixed(2)}', style: TextStyle(color: productProfit[name]! >= 0 ? Colors.green : Colors.red)),
      //                 ],
      //               ),
      //             ),
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );

                if (picked != null) {
                  setState(() => _dateRange = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - '
                      '${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Sale>>(
              stream: Provider.of<SalesViewModel>(context).getAllSales(
                startDate: _dateRange!.start,
                endDate: _dateRange!.end,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sales = snapshot.data!;

                print("TOTAL SALES DOCUMENTS: ${sales.length}");

                for (var sale in sales) {
                  print("Product: ${sale.productName}");
                  print("Amount: ${sale.totalAmount}");
                  print("Cost: ${sale.costPriceAtSale}");
                  print("Profit: ${sale.profit}");
                  print("Paid: ${sale.paidAmount}");
                  print("Pending: ${sale.pendingAmount}");
                }

                // ---- CALCULATIONS ----
                double totalSales = 0;
                double totalCost = 0;
                double totalProfit = 0;

                final Map<String, double> productSales = {};
                final Map<String, double> productProfit = {};

                for (var s in sales) {
                  totalSales += s.totalAmount;
                  totalCost += s.costPriceAtSale * s.qty;
                  totalProfit += s.profit;

                  productSales[s.productName] =
                      (productSales[s.productName] ?? 0) + s.totalAmount;

                  productProfit[s.productName] =
                      (productProfit[s.productName] ?? 0) + s.profit;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _SummaryCard(
                            title: 'Total Sales',
                            amount: totalSales,
                            color: Colors.blue,
                            icon: Icons.shopping_cart,
                          ),
                          _SummaryCard(
                            title: 'Total Cost',
                            amount: totalCost,
                            color: Colors.red,
                            icon: Icons.money_off,
                          ),
                          _SummaryCard(
                            title: 'Total Profit',
                            amount: totalProfit,
                            color: Colors.green,
                            icon: Icons.trending_up,
                          ),
                          _SummaryCard(
                            title: 'Margin',
                            amount: totalSales > 0
                                ? (totalProfit / totalSales) * 100
                                : 0,
                            color: Colors.purple,
                            icon: Icons.percent,
                            isPercentage: true,
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Product-wise Breakdown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: productSales.keys.length,
                        itemBuilder: (context, i) {
                          final name = productSales.keys.elementAt(i);

                          final qty = sales
                              .where((s) => s.productName == name)
                              .fold(0, (sum, s) => sum + s.qty);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(name),
                              subtitle: Text('Qty: $qty'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Sales: ₹${productSales[name]!.toStringAsFixed(2)}',
                                  ),
                                  Text(
                                    'Profit: ₹${productProfit[name]!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: productProfit[name]! >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isPercentage;
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.isPercentage = false,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 4),
            Text(
              isPercentage
                  ? '${amount.toStringAsFixed(1)}%'
                  : '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
