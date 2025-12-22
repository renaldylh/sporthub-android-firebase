import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../models/order.dart';
import '../../../services/order_service.dart';
import '../../../services/upload_service.dart';
import '../../../services/api_client.dart';

class PesananSayaPage extends StatefulWidget {
  const PesananSayaPage({super.key});

  @override
  State<PesananSayaPage> createState() => _PesananSayaPageState();
}

class _PesananSayaPageState extends State<PesananSayaPage> with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService.instance;
  final UploadService _uploadService = UploadService.instance;
  
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  final List<String> _statusTabs = ['Semua', 'Menunggu', 'Diproses', 'Dikirim', 'Selesai'];
  final Map<String, String> _statusMap = {
    'Semua': 'all',
    'Menunggu': 'pending',
    'Diproses': 'paid',
    'Dikirim': 'delivery',
    'Selesai': 'completed',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _orderService.fetchMyOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<OrderModel> _getFilteredOrders(String status) {
    if (status == 'all') return _orders;
    return _orders.where((o) => o.status == status).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'delivery':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'paid':
        return Icons.check_circle_outline;
      case 'delivery':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'expired':
        return Icons.timer_off;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Menunggu Verifikasi Admin';
      case 'delivery':
        return 'Sedang Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'expired':
        return 'Kadaluarsa';
      default:
        return status;
    }
  }

  Future<void> _uploadPaymentProof(OrderModel order) async {
    try {
      final file = await _uploadService.pickImage();
      if (file == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mengupload bukti transfer...")),
      );

      final imageUrl = await _uploadService.uploadImage(file);
      
      await ApiClient.instance.post('/orders/${order.id}/payment-proof', {
        'paymentProofUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bukti transfer berhasil diupload!"),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showOrderDetail(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                      child: Icon(_getStatusIcon(order.status), color: _getStatusColor(order.status)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Order #${order.id.substring(0, 8)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(_getStatusLabel(order.status),
                              style: TextStyle(color: _getStatusColor(order.status))),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),

                // Status Timeline
                _buildStatusTimeline(order),
                const Divider(height: 30),

                // Items
                const Text("Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text("${item.name} x${item.quantity}")),
                      Text("Rp ${(item.price * item.quantity).toStringAsFixed(0)}"),
                    ],
                  ),
                )),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Rp ${order.totalAmount.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                  ],
                ),
                const SizedBox(height: 20),

                // Shipping Address
                if (order.shippingAddress != null) ...[
                  const Text("Alamat Pengiriman", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(order.shippingAddress!),
                  const SizedBox(height: 20),
                ],

                // Payment Proof
                if (order.paymentProof != null) ...[
                  const Text("Bukti Transfer", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(order.paymentProof!, height: 150, fit: BoxFit.cover),
                  ),
                ],

                // Action Button
                if (order.status == 'pending') ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _uploadPaymentProof(order);
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload Bukti Transfer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Batas waktu: ${_formatExpiry(order.expiresAt)}",
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(OrderModel order) {
    final statuses = ['pending', 'paid', 'delivery', 'completed'];
    final currentIndex = statuses.indexOf(order.status);
    
    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isActive = index <= currentIndex && currentIndex >= 0;
        final isLast = index == statuses.length - 1;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isActive ? _getStatusColor(status) : Colors.grey[300],
                    child: Icon(
                      isActive ? Icons.check : Icons.circle,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getShortStatusLabel(status),
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? _getStatusColor(status) : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive && index < currentIndex ? _getStatusColor(status) : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getShortStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Bayar';
      case 'paid': return 'Proses';
      case 'delivery': return 'Kirim';
      case 'completed': return 'Selesai';
      default: return status;
    }
  }

  String _formatExpiry(DateTime? expiresAt) {
    if (expiresAt == null) return '-';
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    return '${remaining.inHours}j ${remaining.inMinutes % 60}m tersisa';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text("Pesanan Saya"),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _statusTabs.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadOrders, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: _statusTabs.map((tab) {
                    final status = _statusMap[tab]!;
                    final orders = _getFilteredOrders(status);
                    
                    if (orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Tidak ada pesanan $tab'.toLowerCase()),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () => _showOrderDetail(order),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Order #${order.id.substring(0, 8)}",
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(order.status).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(_getStatusIcon(order.status),
                                                  size: 14, color: _getStatusColor(order.status)),
                                              const SizedBox(width: 4),
                                              Text(
                                                _getStatusLabel(order.status),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _getStatusColor(order.status),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      order.items.map((i) => "${i.name} x${i.quantity}").join(", "),
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatDate(order.createdAt),
                                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        Text("Rp ${order.totalAmount.toStringAsFixed(0)}",
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                      ],
                                    ),
                                    if (order.status == 'pending') ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _uploadPaymentProof(order),
                                          icon: const Icon(Icons.upload, size: 18),
                                          label: const Text("Upload Bukti Transfer"),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
