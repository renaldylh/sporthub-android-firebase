import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/venue_service.dart';
import '../../services/booking_service.dart';
import '../../services/auth_service.dart';

class LapanganPage extends StatefulWidget {
  const LapanganPage({super.key});

  @override
  State<LapanganPage> createState() => _LapanganPageState();
}

class _LapanganPageState extends State<LapanganPage> {
  final VenueService _venueService = VenueService.instance;
  final BookingService _bookingService = BookingService.instance;
  List<VenueModel> _venues = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final venues = await _venueService.fetchVenues();
      setState(() {
        _venues = venues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<VenueModel> get filteredVenues {
    if (_searchQuery.isEmpty) return _venues;
    return _venues.where((v) =>
        v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        v.type.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _showBookingDialog(VenueModel venue) {
    final dateController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    int durationHours = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Pesan ${venue.name}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Harga: Rp ${venue.pricePerHour.toStringAsFixed(0)} / jam",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: "Tanggal (YYYY-MM-DD)",
                    hintText: "2024-12-25",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      dateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    }
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startTimeController,
                        decoration: const InputDecoration(
                          labelText: "Mulai",
                          hintText: "08:00",
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 8, minute: 0),
                          );
                          if (time != null) {
                            startTimeController.text = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                          }
                        },
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endTimeController,
                        decoration: const InputDecoration(
                          labelText: "Selesai",
                          hintText: "10:00",
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 10, minute: 0),
                          );
                          if (time != null) {
                            endTimeController.text = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                          }
                        },
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Durasi: "),
                    IconButton(
                      onPressed: () {
                        if (durationHours > 1) {
                          setDialogState(() => durationHours--);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text("$durationHours jam", style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () {
                        setDialogState(() => durationHours++);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  "Total: Rp ${(venue.pricePerHour * durationHours).toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () async {
                if (dateController.text.isEmpty || startTimeController.text.isEmpty || endTimeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mohon lengkapi semua field"), backgroundColor: Colors.red),
                  );
                  return;
                }

                if (!AuthService.instance.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Silakan login terlebih dahulu"), backgroundColor: Colors.red),
                  );
                  Navigator.pop(ctx);
                  return;
                }

                Navigator.pop(ctx);
                
                try {
                  await _bookingService.createBooking({
                    'venueId': venue.id,
                    'bookingDate': dateController.text,
                    'startTime': startTimeController.text,
                    'endTime': endTimeController.text,
                    'totalPrice': venue.pricePerHour * durationHours,
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Booking berhasil! Menunggu persetujuan admin."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal booking: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text("Pesan Sekarang"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text("Daftar Lapangan"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadVenues,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadVenues,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVenues,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Temukan dan pesan lapangan olahraga favoritmu!",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 20),

                        // Search bar
                        TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: "Cari lapangan...",
                            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        if (filteredVenues.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.sports_soccer_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text("Belum ada lapangan tersedia"),
                              ],
                            ),
                          )
                        else
                          ...filteredVenues.map((venue) => _buildLapanganCard(venue)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLapanganCard(VenueModel venue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black26,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: venue.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(venue.imageUrl!),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: venue.imageUrl == null
                  ? const Icon(Icons.sports_soccer, size: 64, color: Colors.grey)
                  : null,
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(venue.type, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  if (venue.address != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blueGrey, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue.address!,
                            style: const TextStyle(color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rp ${venue.pricePerHour.toStringAsFixed(0)} / jam",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showBookingDialog(venue),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Pesan"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
