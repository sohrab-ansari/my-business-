import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double costPrice;
  final double sellingPrice;
  final double profitPerUnit;
  final int stock;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.sellingPrice,
    required this.profitPerUnit,
    required this.stock,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'costPrice': costPrice,
    'sellingPrice': sellingPrice,
    'profitPerUnit': profitPerUnit,
    'stock': stock,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
      profitPerUnit: (data['profitPerUnit'] ?? 0).toDouble(),
      stock: (data['stock'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}