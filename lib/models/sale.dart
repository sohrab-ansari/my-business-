import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String billId;
  final String customerName;
  final String productId;
  final String productName;
  final int qty;
  final double price;
  final double costPriceAtSale;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final double profit;
  final DateTime createdAt;

  Sale({
    required this.id,
    required this.billId,
    required this.customerName,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.price,
    required this.costPriceAtSale,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.profit,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'billId': billId,
    'customerName': customerName,
    'productId': productId,
    'productName': productName,
    'qty': qty,
    'price': price,
    'costPriceAtSale': costPriceAtSale,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'pendingAmount': pendingAmount,
    'profit': profit,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;  // ← critical cast
    return Sale(
      id: doc.id,
      billId: data['billId'] ?? '',
      customerName: data['customerName'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      qty: (data['qty'] ?? 0).toInt(),
      price: (data['price'] ?? 0).toDouble(),
      costPriceAtSale: (data['costPriceAtSale'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paidAmount: (data['paidAmount'] ?? 0).toDouble(),
      pendingAmount: (data['pendingAmount'] ?? 0).toDouble(),
      profit: (data['profit'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}