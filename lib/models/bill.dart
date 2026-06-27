import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String id;
  final String billId;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items; // ✅ NEW: store items directly

  Bill({
    required this.id,
    required this.billId,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.createdAt,
    required this.items,
  });

  factory Bill.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Bill(
      id: doc.id,
      billId: data['billId'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paidAmount: (data['paidAmount'] ?? 0).toDouble(),
      pendingAmount: (data['pendingAmount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
    );
  }
}