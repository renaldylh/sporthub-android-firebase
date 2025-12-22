import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/community_service.dart';
import '../../services/upload_service.dart';

class ManajemenKomunitasPage extends StatefulWidget {
  const ManajemenKomunitasPage({super.key});

  @override
  State<ManajemenKomunitasPage> createState() => _ManajemenKomunitasPageState();
}

class _ManajemenKomunitasPageState extends State<ManajemenKomunitasPage> {
  final CommunityService _communityService = CommunityService.instance;
  final UploadService _uploadService = UploadService.instance;
  List<CommunityModel> _communities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final communities = await _communityService.fetchCommunities();
      setState(() {
        _communities = communities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddEditDialog({CommunityModel? community}) {
    final isEdit = community != null;
    final nameController = TextEditingController(text: community?.name ?? '');
    final categoryController = TextEditingController(text: community?.category ?? '');
    final descController = TextEditingController(text: community?.description ?? '');
    final memberCountController = TextEditingController(text: community?.memberCount.toString() ?? '0');
    String? imageUrl = community?.imageUrl;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? "Edit Komunitas" : "Tambah Komunitas"),
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
                  decoration: const InputDecoration(labelText: "Nama Komunitas *", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: "Kategori (Futsal, Basket, Lari, dll)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: memberCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Jumlah Anggota", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nama harus diisi"), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(ctx);

                try {
                  final data = {
                    'name': nameController.text,
                    'category': categoryController.text.isNotEmpty ? categoryController.text : null,
                    'memberCount': int.tryParse(memberCountController.text) ?? 0,
                    'description': descController.text.isNotEmpty ? descController.text : null,
                    'imageUrl': imageUrl,
                  };

                  if (isEdit) {
                    await _communityService.updateCommunity(community!.id, data);
                  } else {
                    await _communityService.createCommunity(data);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? "Komunitas berhasil diupdate" : "Komunitas berhasil ditambahkan"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadCommunities();
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

  void _deleteCommunity(CommunityModel community) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Komunitas"),
        content: Text("Hapus ${community.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _communityService.deleteCommunity(community.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Komunitas berhasil dihapus"), backgroundColor: Colors.green),
                );
                _loadCommunities();
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
                      ElevatedButton(onPressed: _loadCommunities, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCommunities,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total: ${_communities.length} komunitas",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            IconButton(onPressed: _loadCommunities, icon: const Icon(Icons.refresh)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _communities.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.groups_outlined, size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      const Text('Belum ada komunitas'),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _communities.length,
                                  itemBuilder: (context, index) {
                                    final community = _communities[index];
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
                                            image: community.imageUrl != null
                                                ? DecorationImage(image: NetworkImage(community.imageUrl!), fit: BoxFit.cover)
                                                : null,
                                          ),
                                          child: community.imageUrl == null
                                              ? const Icon(Icons.groups, color: Colors.grey)
                                              : null,
                                        ),
                                        title: Text(community.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (community.category != null) Text(community.category!),
                                            Text("${community.memberCount} anggota",
                                                style: const TextStyle(color: AppTheme.primaryColor)),
                                          ],
                                        ),
                                        isThreeLine: true,
                                        trailing: PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') _showAddEditDialog(community: community);
                                            if (value == 'delete') _deleteCommunity(community);
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
