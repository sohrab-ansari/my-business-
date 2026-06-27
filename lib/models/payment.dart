import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final double amount;
  final DateTime date;
  final String billId;

  Payment({
    required this.id,
    required this.amount,
    required this.date,
    required this.billId,
  });

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'billId': billId,
  };

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      billId: data['billId'] ?? '',
    );
  }
}