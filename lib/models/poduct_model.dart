class Product {
  final String id;
  final String name;
  final double costPrice;
  final double sellingPrice;
  final double profitPerUnit;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.sellingPrice,
    required this.profitPerUnit,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "costPrice": costPrice,
      "sellingPrice": sellingPrice,
      "profitPerUnit": profitPerUnit,
      "stock": stock,
      "createdAt": DateTime.now(),
    };
  }
}