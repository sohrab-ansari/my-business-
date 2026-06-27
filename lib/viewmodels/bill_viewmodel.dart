import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/firebase_repository.dart';
import '../utils/utils_helper.dart';

class BillViewModel extends ChangeNotifier {
  final FirestoreRepository _repository = FirestoreRepository();
  bool isLoading = false;
  String? errorMessage;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> createBill({
    required String customerName,
    required List<Map<String, dynamic>> cart,
    required double paidAmount,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.createBillTransaction(
        userId: userId,
        customerName: customerName,
        cart: cart,
        paidAmount: paidAmount,
      );
    } catch (e) {
      errorMessage = UiHelpers.getErrorMessage(e);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}