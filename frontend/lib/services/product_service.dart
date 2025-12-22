import 'package:banyumas_sport_hub/models/product.dart';

import 'api_client.dart';

class ProductService {
  ProductService._();

  static final ProductService instance = ProductService._();
  final ApiClient _client = ApiClient.instance;

  Future<List<ProductModel>> fetchProducts() async {
    final response = await _client.get('/products');
    final products = response['products'] as List<dynamic>? ?? [];
    return products
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> fetchProduct(String productId) async {
    final response = await _client.get('/products/$productId');
    return ProductModel.fromJson(response['product'] as Map<String, dynamic>);
  }

  Future<ProductModel> createProduct(ProductModel payload) async {
    final response = await _client.post('/products', payload.toJson());
    return ProductModel.fromJson(response['product'] as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct(String productId, Map<String, dynamic> data) async {
    final response = await _client.put('/products/$productId', data);
    return ProductModel.fromJson(response['product'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String productId) async {
    await _client.delete('/products/$productId');
  }
}
