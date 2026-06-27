import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/bill.dart';
import '../models/payment.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---- Products ----
  Future<void> addProduct(
    String userId,
    String name,
    double cp,
    double sp,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .add({
          'name': name,
          'costPrice': cp,
          'sellingPrice': sp,
          'profitPerUnit': sp - cp,
          'stock': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<Product>> getProductsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateStock(String userId, String productId, int delta) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .doc(productId)
        .update({'stock': FieldValue.increment(delta)});
  }

  // ---- Customers ----
  Future<DocumentReference> addCustomer(String userId, String name) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('customers')
        .doc();
    await docRef.set({
      'name': name,
      'pendingBalance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef;
  }

  Stream<List<Customer>> getCustomersStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList(),
        );
  }

  Future<DocumentReference?> getCustomerRefByName(
    String userId,
    String customerName,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('customers')
        .where('name', isEqualTo: customerName)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.reference;
  }

  // ---- Bill Creation with Transaction (stores items inside bill, sales under customer) ----
  // Future<void> createBillTransaction({
  //   required String userId,
  //   required String customerName,
  //   required List<Map<String, dynamic>> cart,
  //   required double paidAmount,
  // }) async {
  //   final String billId = DateTime.now().millisecondsSinceEpoch.toString();
  //   final DateTime now = DateTime.now();

  //   double totalAmount = 0;
  //   for (var item in cart) {
  //     totalAmount += item['price'] * item['qty'];
  //   }
  //   final pendingAmount = totalAmount - paidAmount;

  //   DocumentReference? customerRef = await getCustomerRefByName(userId, customerName);
  //   if (customerRef == null) {
  //     customerRef = await addCustomer(userId, customerName);
  //   }

  //   await _firestore.runTransaction((transaction) async {
  //     final List<Map<String, dynamic>> saleDocs = [];
  //     final List<Map<String, dynamic>> billItems = [];

  //     for (var item in cart) {
  //       final productRef = _firestore
  //           .collection('users')
  //           .doc(userId)
  //           .collection('products')
  //           .doc(item['productId']);
  //       final productSnap = await transaction.get(productRef);
  //       if (!productSnap.exists) {
  //         throw Exception('Product ${item['name']} not found');
  //       }
  //       final currentStock = (productSnap.data()?['stock'] ?? 0) as int;
  //       if (currentStock < item['qty']) {
  //         throw Exception('Insufficient stock for ${item['name']} (available: $currentStock)');
  //       }
  //       transaction.update(productRef, {'stock': FieldValue.increment(-item['qty'])});

  //       final costPriceAtSale = (productSnap.data()?['costPrice'] ?? 0).toDouble();
  //       final total = item['price'] * item['qty'];
  //       final profit = total - (costPriceAtSale * item['qty']);

  //       saleDocs.add({
  //         'billId': billId,
  //         'customerName': customerName,
  //         'productId': item['productId'],
  //         'productName': item['name'],
  //         'qty': item['qty'],
  //         'price': item['price'],
  //         'costPriceAtSale': costPriceAtSale,
  //         'totalAmount': total,
  //         'paidAmount': paidAmount,
  //         'pendingAmount': pendingAmount,
  //         'profit': profit,
  //         'createdAt': Timestamp.fromDate(now),
  //       });

  //       billItems.add({
  //         'name': item['name'],
  //         'qty': item['qty'],
  //         'price': item['price'],
  //       });
  //     }

  //     // Update customer pending balance
  //     final customerSnap = await transaction.get(customerRef!);
  //     final customerData = customerSnap.data() as Map<String, dynamic>?;
  //     final currentBalance = (customerData?['pendingBalance'] as num?)?.toDouble() ?? 0.0;
  //     transaction.update(customerRef, {'pendingBalance': currentBalance + pendingAmount});

  //     // Save each sale under customer's sales subcollection
  //     for (var sale in saleDocs) {
  //       final saleRef = customerRef.collection('sales').doc();
  //       transaction.set(saleRef, sale);
  //     }

  //     // Create bill summary with items under customer's bills subcollection
  //     final billRef = customerRef.collection('bills').doc(billId);
  //     transaction.set(billRef, {
  //       'billId': billId,
  //       'totalAmount': totalAmount,
  //       'paidAmount': paidAmount,
  //       'pendingAmount': pendingAmount,
  //       'createdAt': Timestamp.fromDate(now),
  //       'items': billItems,
  //     });

  //     // Optional: Also save to global sales collection for overall reporting
  //     for (var sale in saleDocs) {
  //       final globalSaleRef = _firestore
  //           .collection('users')
  //           .doc(userId)
  //           .collection('sales')
  //           .doc();
  //       transaction.set(globalSaleRef, sale);
  //     }
  //   });
  // }

  Future<void> createBillTransaction({
    required String userId,
    required String customerName,
    required List<Map<String, dynamic>> cart,
    required double paidAmount,
  }) async {
    final String billId = DateTime.now().millisecondsSinceEpoch.toString();

    final DateTime now = DateTime.now();

    double totalAmount = 0;

    for (var item in cart) {
      totalAmount += item['price'] * item['qty'];
    }

    final double pendingAmount = totalAmount - paidAmount;

    DocumentReference? customerRef = await getCustomerRefByName(
      userId,
      customerName,
    );

    if (customerRef == null) {
      customerRef = await addCustomer(userId, customerName);
    }

    await _firestore.runTransaction((transaction) async {
      // ==========================
      // 1. READ ALL DOCUMENTS FIRST
      // ==========================

      List<DocumentSnapshot> productSnapshots = [];

      for (var item in cart) {
        final productRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('products')
            .doc(item['productId']);

        final snap = await transaction.get(productRef);

        if (!snap.exists) {
          throw Exception("Product not found ${item['name']}");
        }

        productSnapshots.add(snap);
      }

      final customerSnap = await transaction.get(customerRef!);

      // ==========================
      // NOW ALL READS FINISHED
      // ==========================

      List<Map<String, dynamic>> sales = [];
      List<Map<String, dynamic>> billItems = [];

      double newPending = pendingAmount;

      for (int i = 0; i < cart.length; i++) {
        final item = cart[i];

        final productSnap = productSnapshots[i];

        final stock = productSnap['stock'] ?? 0;

        if (stock < item['qty']) {
          throw Exception("Not enough stock ${item['name']}");
        }

        final costPrice = (productSnap['costPrice'] ?? 0).toDouble();

        final total = item['price'] * item['qty'];

        final profit = total - (costPrice * item['qty']);

        final productRef = productSnap.reference;

        // WRITE
        transaction.update(productRef, {
          'stock': FieldValue.increment(-item['qty']),
        });

        sales.add({
          'billId': billId,

          'customerName': customerName,

          'productId': item['productId'],

          'productName': item['name'],

          'qty': item['qty'],

          'price': item['price'],

          'costPriceAtSale': costPrice,

          'totalAmount': total,

          'paidAmount': paidAmount,

          'pendingAmount': pendingAmount,

          'profit': profit,

          'createdAt': Timestamp.fromDate(now),
        });

        billItems.add({
          'name': item['name'],

          'qty': item['qty'],

          'price': item['price'],
        });
      }

      // customer balance

      final oldBalance =
          (customerSnap.data() as Map<String, dynamic>?)?['pendingBalance'] ??
          0;

      transaction.update(customerRef, {
        'pendingBalance': oldBalance + pendingAmount,
      });

      // SAVE BILL

      final billRef = customerRef.collection('bills').doc(billId);

      transaction.set(billRef, {
        'billId': billId,

        'totalAmount': totalAmount,

        'paidAmount': paidAmount,

        'pendingAmount': pendingAmount,

        'items': billItems,

        'createdAt': Timestamp.fromDate(now),
      });

      // SAVE SALES

      for (var sale in sales) {
        final saleRef = customerRef.collection('sales').doc();

        transaction.set(saleRef, sale);

        final globalSale = _firestore
            .collection('users')
            .doc(userId)
            .collection('sales')
            .doc();

        transaction.set(globalSale, sale);
      }
    });
  }

  // ---- Record Payment (Post-bill deduction) ----
  Future<void> recordPayment({
    required String userId,
    required String customerName,
    required String billId,
    required double amount,
  }) async {
    final customerRef = await getCustomerRefByName(userId, customerName);
    if (customerRef == null) throw Exception('Customer not found');

    await _firestore.runTransaction((transaction) async {
      final billRef = customerRef.collection('bills').doc(billId);
      final billSnap = await transaction.get(billRef);
      if (!billSnap.exists) throw Exception('Bill not found');
      final billData = billSnap.data() as Map<String, dynamic>;
      final currentPending = (billData['pendingAmount'] ?? 0).toDouble();

      if (amount > currentPending) {
        throw Exception('Amount exceeds pending balance');
      }

      final newPaid = (billData['paidAmount'] ?? 0).toDouble() + amount;
      final newPending = currentPending - amount;

      transaction.update(billRef, {
        'paidAmount': newPaid,
        'pendingAmount': newPending,
      });

      final customerSnap = await transaction.get(customerRef);
      final customerData = customerSnap.data() as Map<String, dynamic>?;
      final oldBalance = (customerData?['pendingBalance'] ?? 0).toDouble();
      transaction.update(customerRef, {'pendingBalance': oldBalance - amount});

      final paymentRef = billRef.collection('payments').doc();
      final payment = Payment(
        id: paymentRef.id,
        amount: amount,
        date: DateTime.now(),
        billId: billId,
      );
      transaction.set(paymentRef, payment.toMap());
    });
  }

  // ---- Sales for Reports (global, uses only createdAt order) ----
  Stream<List<Sale>> getSalesStream(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var query =
        _firestore
                .collection('users')
                .doc(userId)
                .collection('sales')
                .orderBy('createdAt', descending: true)
            as Query;
    if (startDate != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'createdAt',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList(),
    );
  }

  // ---- Bills for Customer (subcollection) ----
  Stream<List<Bill>> getBillsForCustomer(String userId, String customerName) {
    return Stream.fromFuture(
      getCustomerRefByName(userId, customerName),
    ).asyncExpand((customerRef) {
      if (customerRef == null) return Stream.value([]);
      return customerRef
          .collection('bills')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList(),
          );
    });
  }

  // ---- Sales for Customer (from customer subcollection, no composite index) ----
  Stream<List<Sale>> getSalesForCustomer(
    String userId,
    String customerName,
  ) async* {
    final customerRef = await getCustomerRefByName(userId, customerName);
    if (customerRef == null) {
      yield [];
      return;
    }
    yield* customerRef
        .collection('sales')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList(),
        );
  }
}
