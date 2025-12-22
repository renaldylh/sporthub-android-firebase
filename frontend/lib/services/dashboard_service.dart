import 'api_client.dart';

class DashboardService {
  DashboardService._();

  static final DashboardService instance = DashboardService._();
  final ApiClient _client = ApiClient.instance;

  /// Get dashboard statistics (admin only)
  Future<DashboardStats> fetchStats() async {
    final response = await _client.get('/dashboard/stats');
    return DashboardStats.fromJson(response as Map<String, dynamic>);
  }
}

class DashboardStats {
  final int totalUsers;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final List<Map<String, dynamic>> recentOrders;
  final List<Map<String, dynamic>> lowStockProducts;
  final List<Map<String, dynamic>> ordersByStatus;
  final List<Map<String, dynamic>> monthlyRevenue;

  DashboardStats({
    required this.totalUsers,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.recentOrders,
    required this.lowStockProducts,
    required this.ordersByStatus,
    required this.monthlyRevenue,
  });

  /// Helper to parse number from either String or num
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: _parseInt(json['totalUsers']),
      totalProducts: _parseInt(json['totalProducts']),
      totalOrders: _parseInt(json['totalOrders']),
      totalRevenue: _parseDouble(json['totalRevenue']),
      recentOrders: (json['recentOrders'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      lowStockProducts: (json['lowStockProducts'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      ordersByStatus: (json['ordersByStatus'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      monthlyRevenue: (json['monthlyRevenue'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
    );
  }
}
