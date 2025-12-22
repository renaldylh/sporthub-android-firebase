class OrderItemModel {
  final String name;
  final int quantity;
  final double price;
  final String? productId;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    this.productId,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
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

    return OrderItemModel(
      productId: json['productId']?.toString(),
      name: json['name']?.toString() ?? '',
      price: parseDouble(json['price']),
      quantity: parseInt(json['quantity']),
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
      };
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? paymentProof;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.shippingAddress,
    this.paymentMethod,
    this.paymentProof,
    this.expiresAt,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] is num)
          ? (json['totalAmount'] as num).toDouble()
          : double.tryParse(json['totalAmount']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'pending',
      shippingAddress: json['shippingAddress']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      paymentProof: json['paymentProof']?.toString(),
      expiresAt: parseDate(json['expiresAt']),
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'status': status,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'paymentProof': paymentProof,
        'expiresAt': expiresAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };
}
