import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/booking_service.dart';

class ManajemenSewaPage extends StatefulWidget {
  const ManajemenSewaPage({super.key});

  @override
  State<ManajemenSewaPage> createState() => _ManajemenSewaPageState();
}

class _ManajemenSewaPageState extends State<ManajemenSewaPage> {
  final BookingService _bookingService = BookingService.instance;
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await _bookingService.fetchAllBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<BookingModel> get filteredBookings {
    if (_filterStatus == 'all') return _bookings;
    return _bookings.where((b) => b.status == _filterStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  void _showApprovalDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Sewa"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lapangan: ${booking.venueName ?? 'Unknown'}"),
            Text("Pemohon: ${booking.userName ?? 'Unknown'}"),
            Text("Tanggal: ${booking.bookingDate}"),
            Text("Waktu: ${booking.startTime} - ${booking.endTime}"),
            Text("Total: Rp ${booking.totalPrice.toStringAsFixed(0)}"),
            const SizedBox(height: 16),
            const Text("Pilih aksi:"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              _updateStatus(booking.id, 'rejected');
            },
            child: const Text("Tolak", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx);
              _updateStatus(booking.id, 'approved');
            },
            child: const Text("Setujui", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await _bookingService.updateStatus(id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status berhasil diubah ke ${_getStatusLabel(status)}"),
          backgroundColor: Colors.green,
        ),
      );
      _loadBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    }
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
                      ElevatedButton(
                        onPressed: _loadBookings,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'Semua'),
                          const SizedBox(width: 8),
                          _buildFilterChip('pending', 'Menunggu'),
                          const SizedBox(width: 8),
                          _buildFilterChip('approved', 'Disetujui'),
                          const SizedBox(width: 8),
                          _buildFilterChip('rejected', 'Ditolak'),
                          const SizedBox(width: 8),
                          _buildFilterChip('completed', 'Selesai'),
                        ],
                      ),
                    ),
                    
                    // Stats row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ${filteredBookings.length} booking",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "Pending: ${_bookings.where((b) => b.status == 'pending').length}",
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Booking list
                    Expanded(
                      child: filteredBookings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today_outlined, 
                                       size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  const Text('Tidak ada booking'),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadBookings,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = filteredBookings[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      booking.venueName ?? 'Unknown Venue',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      booking.userName ?? 'Unknown User',
                                                      style: TextStyle(color: Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(booking.status)
                                                      .withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  _getStatusLabel(booking.status),
                                                  style: TextStyle(
                                                    color: _getStatusColor(booking.status),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, 
                                                   size: 16, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text(booking.bookingDate),
                                              const SizedBox(width: 16),
                                              Icon(Icons.access_time, 
                                                   size: 16, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text("${booking.startTime} - ${booking.endTime}"),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Rp ${booking.totalPrice.toStringAsFixed(0)}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                              if (booking.status == 'pending')
                                                Row(
                                                  children: [
                                                    TextButton(
                                                      onPressed: () => 
                                                          _updateStatus(booking.id, 'rejected'),
                                                      child: const Text("Tolak",
                                                          style: TextStyle(color: Colors.red)),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () => 
                                                          _updateStatus(booking.id, 'approved'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green,
                                                      ),
                                                      child: const Text("Setujui"),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
}
