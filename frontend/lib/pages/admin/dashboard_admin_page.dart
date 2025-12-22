import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/dashboard_service.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  final DashboardService _dashboardService = DashboardService.instance;
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _dashboardService.fetchStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatGrid(isMobile),
                        const SizedBox(height: 20),
                        _buildRecentOrdersCard(),
                        const SizedBox(height: 20),
                        _buildLowStockCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatGrid(bool isMobile) {
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: "Total Pengguna",
          value: "${_stats?.totalUsers ?? 0}",
          icon: Icons.person_outline,
          iconColor: const Color(0xFF2563EB),
        ),
        _buildStatCard(
          title: "Total Pendapatan",
          value: _formatCurrency(_stats?.totalRevenue ?? 0),
          icon: Icons.trending_up,
          iconColor: const Color(0xFF059669),
        ),
        _buildStatCard(
          title: "Total Pesanan",
          value: "${_stats?.totalOrders ?? 0}",
          icon: Icons.shopping_cart_outlined,
          iconColor: const Color(0xFFF59E0B),
        ),
        _buildStatCard(
          title: "Total Produk",
          value: "${_stats?.totalProducts ?? 0}",
          icon: Icons.inventory_2_outlined,
          iconColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    final recentOrders = _stats?.recentOrders ?? [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pesanan Terbaru",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (recentOrders.isEmpty)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEFF2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Belum ada pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFFBFC6D2),
                  ),
                ),
              ),
            )
          else
            ...recentOrders.take(5).map((order) {
              // Parse totalAmount safely
              final totalAmount = order['totalAmount'];
              double amount = 0;
              if (totalAmount is num) {
                amount = totalAmount.toDouble();
              } else if (totalAmount is String) {
                amount = double.tryParse(totalAmount) ?? 0;
              }
              
              return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['userName'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Rp ${amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(order['status'] ?? 'pending'),
                    ],
                  ),
                );
            }),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'processing':
        color = Colors.blue;
        label = 'Proses';
        break;
      case 'shipped':
        color = Colors.indigo;
        label = 'Dikirim';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'Selesai';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Batal';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLowStockCard() {
    final lowStock = _stats?.lowStockProducts ?? [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stok Produk Rendah",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (lowStock.isEmpty)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEFF2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Semua produk stok aman',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFFBFC6D2),
                  ),
                ),
              ),
            )
          else
            ...lowStock.take(5).map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          product['name'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Stok: ${product['stock']}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
