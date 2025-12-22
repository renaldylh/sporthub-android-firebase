class ProductModel {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? description;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: parseDouble(json['price']),
      stock: parseInt(json['stock']),
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'description': description,
        'imageUrl': imageUrl,
      };
}
