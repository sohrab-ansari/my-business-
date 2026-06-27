import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addProduct(String userId, Map<String, dynamic> data) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("products")
        .add(data);
  }

  Stream<QuerySnapshot> getProducts(String userId) {
    return _db
        .collection("users")
        .doc(userId)
        .collection("products")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> updateStock(String userId, String productId, int newStock) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("products")
        .doc(productId)
        .update({
      "stock": newStock,
    });
  }

  Future<void> createSale({
    required String userId,
    required Map<String, dynamic> saleData,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("sales")
        .add(saleData);
  }

  Future<void> updateStockAfterSale({
    required String userId,
    required String productId,
    required int newStock,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("products")
        .doc(productId)
        .update({
      "stock": newStock,
    });
  }

  Future<void> addCustomer(String userId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("customers")
        .add(data);
  }

  Future<void> decrementStock(String userId, String productId, int qty) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("products")
        .doc(productId)
        .update({"stock": FieldValue.increment(-qty)});
  }

  Stream getCustomers(String userId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("customers")
        .snapshots();
  }


}