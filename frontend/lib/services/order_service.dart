import '../models/order.dart';
import 'api_client.dart';

class OrderService {
  OrderService._();

  static final OrderService instance = OrderService._();
  final ApiClient _client = ApiClient.instance;

  Future<OrderModel> createOrder({
    required String userId,
    required List<OrderItemModel> items,
    required double totalAmount,
    String? shippingAddress,
    String? paymentMethod,
  }) async {
    final response = await _client.post('/orders', {
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
    });
    return OrderModel.fromJson(response['order'] as Map<String, dynamic>);
  }

  Future<List<OrderModel>> fetchMyOrders() async {
    final response = await _client.get('/orders/me');
    final data = response['orders'] as List<dynamic>? ?? [];
    return data
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderModel>> fetchAllOrders() async {
    final response = await _client.get('/orders');
    final data = response['orders'] as List<dynamic>? ?? [];
    return data
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> fetchOrder(String orderId) async {
    final response = await _client.get('/orders/$orderId');
    return OrderModel.fromJson(response['order'] as Map<String, dynamic>);
  }

  Future<OrderModel> updateStatus(String orderId, String status) async {
    final response = await _client.patch('/orders/$orderId/status', {'status': status});
    return OrderModel.fromJson(response['order'] as Map<String, dynamic>);
  }
}
