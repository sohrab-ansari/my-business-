import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sale.dart';
import '../repositories/firebase_repository.dart';

class SalesViewModel extends ChangeNotifier {
  final FirestoreRepository _repository = FirestoreRepository();
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  Stream<List<Sale>> getAllSales({DateTime? startDate, DateTime? endDate}) {
    return _repository.getSalesStream(userId, startDate: startDate, endDate: endDate);
  }

  Stream<Map<String, int>> getSoldProductsSummary() {
    return getAllSales().map((sales) {
      final map = <String, int>{};
      for (var sale in sales) {
        map[sale.productName] = (map[sale.productName] ?? 0) + sale.qty;
      }
      return map;
    });
  }
}