import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/venue_service.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import '../../models/product.dart';
import 'lapangan_page.dart';
import 'event_page.dart';
import 'artikel_page.dart';
import 'komunitas_page.dart';
import 'marketplace/marketplace_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  List<VenueModel> _venues = [];
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final venues = await VenueService.instance.fetchVenues();
      final products = await ProductService.instance.fetchProducts();
      setState(() {
        _venues = venues.take(4).toList();
        _products = products.take(4).toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.instance.currentUser?.name ?? 'Atlet Banyumas';

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Banyumas SportHub",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                "Selamat datang, $userName!",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Temukan aktivitas olahraga favoritmu di sekitar Banyumas.",
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 20),

              // Search
              TextField(
                decoration: InputDecoration(
                  hintText: "Cari lapangan, produk, atau event...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Main Categories
              const Text(
                "Menu Utama",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryIcon(Icons.sports_soccer, "Lapangan", context, const LapanganPage()),
                  _buildCategoryIcon(Icons.shopping_bag, "Toko", context, const MarketplacePage()),
                  _buildCategoryIcon(Icons.groups, "Komunitas", context, const KomunitasPage()),
                  _buildCategoryIcon(Icons.event, "Event", context, const EventPage()),
                ],
              ),
              const SizedBox(height: 30),

              // Featured Venues
              _buildSectionHeader("Lapangan Populer", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LapanganPage()));
              }),
              const SizedBox(height: 15),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_venues.isEmpty)
                const Center(child: Text("Belum ada lapangan"))
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _venues.length,
                    itemBuilder: (ctx, index) => _buildVenueCard(_venues[index]),
                  ),
                ),
              const SizedBox(height: 30),

              // Featured Products
              _buildSectionHeader("Produk Terbaru", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplacePage()));
              }),
              const SizedBox(height: 15),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_products.isEmpty)
                const Center(child: Text("Belum ada produk"))
              else
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _products.length,
                    itemBuilder: (ctx, index) => _buildProductCard(_products[index]),
                  ),
                ),
              const SizedBox(height: 30),

              // Articles Section
              const Text(
                "Artikel Olahraga Populer",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 15),
              _buildArticleCard(context, "Tips Menjaga Kebugaran Tubuh", "Baca berbagai cara agar tetap bugar setiap hari."),
              _buildArticleCard(context, "5 Lapangan Futsal Terbaik di Banyumas", "Rekomendasi tempat bermain futsal favorit!"),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text("Lihat Semua →"),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, BuildContext context, Widget page) {
    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildVenueCard(VenueModel venue) {
    return Container(
      width: 180,
      height: 190,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: venue.imageUrl != null
                  ? DecorationImage(image: NetworkImage(venue.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: venue.imageUrl == null
                ? const Center(child: Icon(Icons.sports_soccer, size: 36, color: Colors.grey))
                : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(venue.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(venue.type, maxLines: 1, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text("Rp ${venue.pricePerHour.toStringAsFixed(0)}/jam",
                      style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      width: 140,
      height: 210,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: product.imageUrl != null
                  ? DecorationImage(image: NetworkImage(product.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: product.imageUrl == null
                ? const Center(child: Icon(Icons.shopping_bag, size: 36, color: Colors.grey))
                : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("Rp ${product.price.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                  Text("Stok: ${product.stock}", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 5)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryColor, size: 18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtikelPage())),
      ),
    );
  }
}
