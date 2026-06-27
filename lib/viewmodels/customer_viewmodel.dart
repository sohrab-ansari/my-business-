import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer.dart';
import '../models/bill.dart';
import '../models/sale.dart';
import '../repositories/firebase_repository.dart';

class CustomerViewModel extends ChangeNotifier {
  final FirestoreRepository _repository = FirestoreRepository();
  bool isLoading = false;
  String? errorMessage;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> addCustomer(String name) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.addCustomer(userId, name);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Customer>> getCustomers() {
    return _repository.getCustomersStream(userId);
  }

  Stream<List<Bill>> getBillsForCustomer(String customerName) {
    return _repository.getBillsForCustomer(userId, customerName);
  }

  Stream<List<Sale>> getSalesForCustomer(String customerName) {
    return _repository.getSalesForCustomer(userId, customerName);
  }

  // NEW: Record payment for a bill
  Future<void> recordPayment(String customerName, String billId, double amount) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.recordPayment(
        userId: userId,
        customerName: customerName,
        billId: billId,
        amount: amount,
      );
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}