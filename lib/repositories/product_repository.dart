import 'firebase_repository.dart';

class ProductRepository {
  final FirestoreRepository _repository = FirestoreRepository();

  Future<void> addProduct(String userId, Map<String, dynamic> data) {
    return _repository.addProduct(userId, data['name'], data['costPrice'], data['sellingPrice']);
  }

  getProducts(String userId) {
    return _repository.getProductsStream(userId);
  }

  Future<void> updateStock(String userId, String productId, int newStock) {
    return _repository.updateStock(userId, productId, newStock);
  }

  Future<void> createSale(String userId, Map<String, dynamic> data) {
    // This method is not used directly anymore; use createBillTransaction
    throw UnimplementedError('Use createBillTransaction instead');
  }

  Future<void> updateStockAfterSale(String userId, String productId, int newStock) {
    return _repository.updateStock(userId, productId, newStock);
  }

  Future<void> addCustomer(String userId, Map<String, dynamic> data) {
    return _repository.addCustomer(userId, data['name']);
  }

  getCustomers(String userId) {
    return _repository.getCustomersStream(userId);
  }

  Future<void> decrementStock(String userId, String productId, int qty) {
    return _repository.updateStock(userId, productId, -qty);
  }
}