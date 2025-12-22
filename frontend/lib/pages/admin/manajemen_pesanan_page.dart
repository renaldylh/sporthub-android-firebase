import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class ManajemenPesananPage extends StatefulWidget {
  const ManajemenPesananPage({super.key});

  @override
  State<ManajemenPesananPage> createState() => _ManajemenPesananPageState();
}

class _ManajemenPesananPageState extends State<ManajemenPesananPage> {
  final OrderService _orderService = OrderService.instance;
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _orderService.fetchAllOrders();
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

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Sudah Bayar';
      case 'delivery':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Batal';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  void _updateStatus(OrderModel order) {
    final statuses = ['pending', 'paid', 'delivery', 'completed', 'cancelled'];
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ubah Status Pesanan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) => ListTile(
            leading: Icon(
              order.status == status ? Icons.radio_button_checked : Icons.radio_button_off,
              color: _getStatusColor(status),
            ),
            title: Text(_getStatusLabel(status)),
            onTap: () async {
              Navigator.pop(ctx);
              try {
                await _orderService.updateStatus(order.id, status);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Status berhasil diubah"),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadOrders();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                );
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _viewPaymentProof(OrderModel order) {
    if (order.paymentProof == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Belum ada bukti pembayaran")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Bukti Pembayaran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                order.paymentProof!,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 60),
              ),
            ),
            const SizedBox(height: 16),
            if (order.status == 'paid')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await _orderService.updateStatus(order.id, 'delivery');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Status diubah ke Delivery"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadOrders();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    icon: const Icon(Icons.local_shipping),
                    label: const Text("Kirim Pesanan"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await _orderService.updateStatus(order.id, 'cancelled');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Pesanan dibatalkan"), backgroundColor: Colors.orange),
                        );
                        _loadOrders();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text("Tolak"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  List<OrderModel> get _filteredOrders {
    if (_statusFilter == 'all') return _orders;
    return _orders.where((o) => o.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
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
                      ElevatedButton(onPressed: _loadOrders, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('all', 'Semua'),
                              _buildFilterChip('pending', 'Pending'),
                              _buildFilterChip('paid', 'Sudah Bayar'),
                              _buildFilterChip('delivery', 'Dikirim'),
                              _buildFilterChip('completed', 'Selesai'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total: ${_filteredOrders.length} pesanan",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            IconButton(onPressed: _loadOrders, icon: const Icon(Icons.refresh)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _filteredOrders.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      const Text('Tidak ada pesanan'),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = _filteredOrders[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: ExpansionTile(
                                        leading: CircleAvatar(
                                          backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                                          child: Icon(
                                            order.paymentProof != null ? Icons.receipt_long : Icons.shopping_bag,
                                            color: _getStatusColor(order.status),
                                          ),
                                        ),
                                        title: Text("Order #${order.id.substring(0, 8)}",
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Rp ${order.totalAmount.toStringAsFixed(0)}"),
                                            Container(
                                              margin: const EdgeInsets.only(top: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(order.status).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _getStatusLabel(order.status),
                                                style: TextStyle(
                                                  color: _getStatusColor(order.status),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Tanggal: ${_formatDate(order.createdAt)}"),
                                                if (order.shippingAddress != null)
                                                  Text("Alamat: ${order.shippingAddress}"),
                                                const SizedBox(height: 12),
                                                const Text("Items:", style: TextStyle(fontWeight: FontWeight.w600)),
                                                ...order.items.map((item) => Text("  • ${item.name} x${item.quantity}")),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    if (order.paymentProof != null)
                                                      ElevatedButton.icon(
                                                        onPressed: () => _viewPaymentProof(order),
                                                        icon: const Icon(Icons.image, size: 18),
                                                        label: const Text("Lihat Bukti"),
                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                                      ),
                                                    ElevatedButton.icon(
                                                      onPressed: () => _updateStatus(order),
                                                      icon: const Icon(Icons.edit, size: 18),
                                                      label: const Text("Ubah Status"),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _statusFilter = value),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
