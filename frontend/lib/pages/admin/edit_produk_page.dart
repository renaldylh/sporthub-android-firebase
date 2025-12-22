import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/product_service.dart';
import '../../services/upload_service.dart';

class EditProdukPage extends StatefulWidget {
  final String produkId;
  final String namaProduk;
  final String harga;
  final String stok;
  final String deskripsi;
  final String? imageUrl;

  const EditProdukPage({
    super.key,
    required this.produkId,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    this.imageUrl,
  });

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
  late TextEditingController _deskripsiController;
  final ProductService _productService = ProductService.instance;
  final UploadService _uploadService = UploadService.instance;
  
  String? _imageUrl;
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaProduk);
    _hargaController = TextEditingController(text: widget.harga);
    _stokController = TextEditingController(text: widget.stok);
    _deskripsiController = TextEditingController(text: widget.deskripsi);
    _imageUrl = widget.imageUrl;
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final file = await _uploadService.pickImage();
      if (file == null) return;

      setState(() => _isUploading = true);

      final url = await _uploadService.uploadImage(file);
      setState(() {
        _imageUrl = url;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gambar berhasil diupload!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateProduct() async {
    final nama = _namaController.text.trim();
    final harga = double.tryParse(_hargaController.text.trim()) ?? 0;
    final stok = int.tryParse(_stokController.text.trim()) ?? 0;
    final deskripsi = _deskripsiController.text.trim();

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama produk harus diisi!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (harga <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harga harus lebih dari 0!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _productService.updateProduct(
        widget.produkId,
        {
          'name': nama,
          'price': harga,
          'stock': stok,
          'description': deskripsi.isNotEmpty ? deskripsi : null,
          'imageUrl': _imageUrl,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil diperbarui!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text("Edit Produk"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              _buildLabel("Gambar Produk"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                    image: _imageUrl != null
                        ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : _imageUrl == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Tap untuk upload gambar", style: TextStyle(color: Colors.grey)),
                              ],
                            )
                          : Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(),
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel("Nama Produk"),
              _buildInputField(_namaController, "Masukkan nama produk"),
              const SizedBox(height: 16),
              _buildLabel("Harga"),
              _buildInputField(_hargaController, "Masukkan harga produk",
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildLabel("Stok"),
              _buildInputField(_stokController, "Masukkan jumlah stok",
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildLabel("Deskripsi"),
              _buildInputField(_deskripsiController, "Masukkan deskripsi produk", maxLines: 4),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateProduct,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_isLoading ? "Menyimpan..." : "Simpan Perubahan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 15),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
}
