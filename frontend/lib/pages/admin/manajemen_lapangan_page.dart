import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/venue_service.dart';
import '../../services/upload_service.dart';

class ManajemenLapanganPage extends StatefulWidget {
  const ManajemenLapanganPage({super.key});

  @override
  State<ManajemenLapanganPage> createState() => _ManajemenLapanganPageState();
}

class _ManajemenLapanganPageState extends State<ManajemenLapanganPage> {
  final VenueService _venueService = VenueService.instance;
  final UploadService _uploadService = UploadService.instance;
  List<VenueModel> _venues = [];
  bool _isLoading = true;
  String? _error;

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

  void _showAddEditDialog({VenueModel? venue}) {
    final isEdit = venue != null;
    final nameController = TextEditingController(text: venue?.name ?? '');
    final typeController = TextEditingController(text: venue?.type ?? '');
    final priceController = TextEditingController(text: venue?.pricePerHour.toStringAsFixed(0) ?? '');
    final addressController = TextEditingController(text: venue?.address ?? '');
    final descController = TextEditingController(text: venue?.description ?? '');
    String? imageUrl = venue?.imageUrl;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? "Edit Lapangan" : "Tambah Lapangan"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Picker
                GestureDetector(
                  onTap: isUploading ? null : () async {
                    try {
                      final file = await _uploadService.pickImage();
                      if (file == null) return;
                      setDialogState(() => isUploading = true);
                      final url = await _uploadService.uploadImage(file);
                      setDialogState(() {
                        imageUrl = url;
                        isUploading = false;
                      });
                    } catch (e) {
                      setDialogState(() => isUploading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal upload: $e"), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                      image: imageUrl != null
                          ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : imageUrl == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                  Text("Tap untuk upload gambar", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              )
                            : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nama Lapangan *", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: "Jenis (Futsal, Basket, dll) *", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Harga per Jam (Rp) *", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || typeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nama dan jenis harus diisi"), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(ctx);

                try {
                  final data = {
                    'name': nameController.text,
                    'type': typeController.text,
                    'pricePerHour': double.tryParse(priceController.text) ?? 0,
                    'address': addressController.text.isNotEmpty ? addressController.text : null,
                    'description': descController.text.isNotEmpty ? descController.text : null,
                    'imageUrl': imageUrl,
                  };

                  if (isEdit) {
                    await _venueService.updateVenue(venue!.id, data);
                  } else {
                    await _venueService.createVenue(data);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? "Lapangan berhasil diupdate" : "Lapangan berhasil ditambahkan"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadVenues();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text(isEdit ? "Simpan" : "Tambah"),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteVenue(VenueModel venue) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Lapangan"),
        content: Text("Hapus ${venue.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _venueService.deleteVenue(venue.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lapangan berhasil dihapus"), backgroundColor: Colors.green),
                );
                _loadVenues();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
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
                      ElevatedButton(onPressed: _loadVenues, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVenues,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total: ${_venues.length} lapangan",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            IconButton(onPressed: _loadVenues, icon: const Icon(Icons.refresh)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _venues.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.sports_soccer_outlined, size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      const Text('Belum ada lapangan'),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _venues.length,
                                  itemBuilder: (context, index) {
                                    final venue = _venues[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: ListTile(
                                        leading: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8),
                                            image: venue.imageUrl != null
                                                ? DecorationImage(image: NetworkImage(venue.imageUrl!), fit: BoxFit.cover)
                                                : null,
                                          ),
                                          child: venue.imageUrl == null
                                              ? const Icon(Icons.sports_soccer, color: Colors.grey)
                                              : null,
                                        ),
                                        title: Text(venue.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(venue.type),
                                            Text("Rp ${venue.pricePerHour.toStringAsFixed(0)}/jam",
                                                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                        isThreeLine: true,
                                        trailing: PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') _showAddEditDialog(venue: venue);
                                            if (value == 'delete') _deleteVenue(venue);
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                            const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                                          ],
                                        ),
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
}
