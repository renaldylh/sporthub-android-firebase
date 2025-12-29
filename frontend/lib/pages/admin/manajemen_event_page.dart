import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/event_service.dart';
import '../../services/upload_service.dart';
import '../../services/event_registration_service.dart';

class ManajemenEventPage extends StatefulWidget {
  const ManajemenEventPage({super.key});

  @override
  State<ManajemenEventPage> createState() => _ManajemenEventPageState();
}

class _ManajemenEventPageState extends State<ManajemenEventPage> {
  final EventService _eventService = EventService.instance;
  final UploadService _uploadService = UploadService.instance;
  final EventRegistrationService _registrationService = EventRegistrationService.instance;
  List<EventModel> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _eventService.fetchEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddEditDialog({EventModel? event}) {
    final isEdit = event != null;
    final titleController = TextEditingController(text: event?.title ?? '');
    final descController = TextEditingController(text: event?.description ?? '');
    final dateController = TextEditingController(text: event?.eventDate.split('T').first ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    String? imageUrl = event?.imageUrl;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? "Edit Event" : "Tambah Event"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image preview & picker
                GestureDetector(
                  onTap: () async {
                    final file = await _uploadService.pickImage();
                    if (file != null) {
                      setDialogState(() => imageUrl = 'uploading...');
                      try {
                        final url = await _uploadService.uploadImage(file);
                        setDialogState(() => imageUrl = url);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Upload gagal: $e"), backgroundColor: Colors.red),
                        );
                        setDialogState(() => imageUrl = event?.imageUrl);
                      }
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: imageUrl != null && !imageUrl!.contains('uploading')
                          ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: imageUrl == null || imageUrl!.contains('uploading')
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(imageUrl?.contains('uploading') == true
                                  ? Icons.hourglass_empty
                                  : Icons.add_photo_alternate,
                                  size: 40, color: Colors.grey),
                              const SizedBox(height: 4),
                              Text(imageUrl?.contains('uploading') == true
                                  ? 'Uploading...'
                                  : 'Tap untuk upload gambar',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Judul Event *",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: "Tanggal Event (YYYY-MM-DD) *",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      dateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    }
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: "Lokasi",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(),
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
              onPressed: () async {
                if (titleController.text.isEmpty || dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Judul dan tanggal harus diisi"), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(ctx);

                try {
                  final data = {
                    'title': titleController.text,
                    'eventDate': dateController.text,
                    'location': locationController.text.isNotEmpty ? locationController.text : null,
                    'description': descController.text.isNotEmpty ? descController.text : null,
                    'imageUrl': imageUrl,
                  };

                  if (isEdit) {
                    await _eventService.updateEvent(event!.id, data);
                  } else {
                    await _eventService.createEvent(data);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? "Event berhasil diupdate" : "Event berhasil ditambahkan"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadEvents();
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

  void _deleteEvent(EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Event"),
        content: Text("Hapus ${event.title}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _eventService.deleteEvent(event.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Event berhasil dihapus"), backgroundColor: Colors.green),
                );
                _loadEvents();
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
                      ElevatedButton(onPressed: _loadEvents, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total: ${_events.length} event",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            IconButton(onPressed: _loadEvents, icon: const Icon(Icons.refresh)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _events.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.event_outlined, size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      const Text('Belum ada event'),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _events.length,
                                  itemBuilder: (context, index) {
                                    final event = _events[index];
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
                                            image: event.imageUrl != null
                                                ? DecorationImage(
                                                    image: NetworkImage(event.imageUrl!),
                                                    fit: BoxFit.cover)
                                                : null,
                                          ),
                                          child: event.imageUrl == null
                                              ? const Icon(Icons.event, color: Colors.grey)
                                              : null,
                                        ),
                                        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(event.eventDate.split('T').first),
                                            if (event.location != null) Text(event.location!, style: const TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                        isThreeLine: true,
                                        trailing: PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') _showAddEditDialog(event: event);
                                            if (value == 'delete') _deleteEvent(event);
                                            if (value == 'registrations') _showRegistrations(event);
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(value: 'registrations', child: Text('Lihat Pendaftar')),
                                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Hapus', style: TextStyle(color: Colors.red)),
                                            ),
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

  void _showRegistrations(EventModel event) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Pendaftar: ${event.title}"),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<EventRegistrationModel>>(
            future: _registrationService.fetchByEvent(event.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              final registrations = snapshot.data ?? [];
              if (registrations.isEmpty) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: Text("Belum ada pendaftar")),
                );
              }
              return SizedBox(
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: registrations.length,
                  itemBuilder: (context, index) {
                    final reg = registrations[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: Text(
                          (reg.userName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                      title: Text(reg.userName ?? 'Unknown'),
                      subtitle: Text(reg.userEmail ?? ''),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: reg.status == 'registered'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reg.status == 'registered' ? 'Terdaftar' : reg.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: reg.status == 'registered' ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
