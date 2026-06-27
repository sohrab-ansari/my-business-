import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final double pendingBalance;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.pendingBalance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'pendingBalance': pendingBalance,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      pendingBalance: (data['pendingBalance'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}