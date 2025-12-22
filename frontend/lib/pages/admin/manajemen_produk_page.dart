import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import 'edit_produk_page.dart';
import 'tambah_produk_page.dart';

class ManajemenProdukPage extends StatefulWidget {
  const ManajemenProdukPage({super.key});

  @override
  State<ManajemenProdukPage> createState() => _ManajemenProdukPageState();
}

class _ManajemenProdukPageState extends State<ManajemenProdukPage> {
  final ProductService _productService = ProductService.instance;
  List<ProductModel> _produkList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productService.fetchProducts();
      setState(() {
        _produkList = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _tambahProduk() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const TambahProdukPage()),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  void _editProduk(ProductModel produk) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProdukPage(
          produkId: produk.id,
          namaProduk: produk.name,
          harga: produk.price.toString(),
          stok: produk.stock.toString(),
          deskripsi: produk.description ?? '',
          imageUrl: produk.imageUrl,
        ),
      ),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  void _hapusProduk(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus produk ini?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _productService.deleteProduct(id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Produk berhasil dihapus!"),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                _loadProducts();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Gagal menghapus: $e"),
                    backgroundColor: Colors.red,
                  ),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Manajemen Produk",
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _loadProducts,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: isMobile ? 40 : 48,
                        width: isMobile ? 120 : 160,
                        child: ElevatedButton.icon(
                          onPressed: _tambahProduk,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            isMobile ? "Tambah" : "Tambah Produk",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B7BA6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // TABLE SECTION
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildContent(isMobile, isTablet),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isMobile, bool isTablet) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_produkList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Belum ada produk'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _tambahProduk,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Produk Pertama'),
            ),
          ],
        ),
      );
    }

    return isMobile
        ? _buildMobileList()
        : (isTablet ? _buildTabletTable() : _buildDesktopTable());
  }

  // MOBILE VIEW - Card List
  Widget _buildMobileList() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        itemCount: _produkList.length,
        itemBuilder: (context, index) {
          final produk = _produkList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        produk.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      "ID: ${produk.id.substring(0, 8)}...",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Harga: Rp ${produk.price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Stok: ${produk.stock}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF1B7BA6),
                            size: 20,
                          ),
                          onPressed: () => _editProduk(produk),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _hapusProduk(produk.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // TABLET VIEW
  Widget _buildTabletTable() {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          const Color(0xFF1B7BA6).withOpacity(0.15),
        ),
        headingRowHeight: 56,
        dataRowMinHeight: 60,
        dataRowMaxHeight: 60,
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text("ID")),
          DataColumn(label: Text("Nama")),
          DataColumn(label: Text("Harga")),
          DataColumn(label: Text("Stok")),
          DataColumn(label: Text("Aksi")),
        ],
        rows: _produkList.map((produk) {
          return DataRow(
            cells: [
              DataCell(Text(produk.id.substring(0, 8))),
              DataCell(
                SizedBox(
                  width: 120,
                  child: Text(
                    produk.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text("Rp ${produk.price.toStringAsFixed(0)}")),
              DataCell(Text(produk.stock.toString())),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color(0xFF1B7BA6),
                        size: 18,
                      ),
                      onPressed: () => _editProduk(produk),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 18,
                      ),
                      onPressed: () => _hapusProduk(produk.id),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // DESKTOP VIEW
  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          const Color(0xFF1B7BA6).withOpacity(0.1),
        ),
        headingRowHeight: 56,
        dataRowMinHeight: 80,
        dataRowMaxHeight: 80,
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text("ID")),
          DataColumn(label: Text("Gambar")),
          DataColumn(label: Text("Nama Produk")),
          DataColumn(label: Text("Harga")),
          DataColumn(label: Text("Stok")),
          DataColumn(label: Text("Deskripsi")),
          DataColumn(label: Text("Aksi")),
        ],
        rows: _produkList.map((produk) {
          return DataRow(
            cells: [
              DataCell(Text(produk.id.substring(0, 8))),
              DataCell(
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                    image: produk.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(produk.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: produk.imageUrl == null
                      ? const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 24,
                        )
                      : null,
                ),
              ),
              DataCell(Text(produk.name)),
              DataCell(Text("Rp ${produk.price.toStringAsFixed(0)}")),
              DataCell(Text(produk.stock.toString())),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    produk.description ?? '-',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => _editProduk(produk),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete, size: 16),
                      label:
                          const Text("Delete", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => _hapusProduk(produk.id),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
