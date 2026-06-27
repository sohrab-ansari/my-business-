import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../repositories/firebase_repository.dart';

class ProductViewModel extends ChangeNotifier {
  final FirestoreRepository _repository = FirestoreRepository();
  bool isLoading = false;
  String? errorMessage;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> addProduct({required String name, required double cp, required double sp}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.addProduct(userId, name, cp, sp);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Product>> getProducts() {
    return _repository.getProductsStream(userId);
  }

  Future<void> addStock(String productId, int currentStock, int addedStock) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.updateStock(userId, productId, addedStock);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}