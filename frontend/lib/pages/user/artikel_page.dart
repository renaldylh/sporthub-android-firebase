import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import 'user_main_page.dart';

class ArtikelPage extends StatelessWidget {
  const ArtikelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> articles = [
      {
        "title": "5 Tips Latihan Fisik untuk Pemula",
        "author": "Admin SportHub",
        "image": "assets/images/workout_tips.png",
        "date": "20 Oktober 2025",
        "desc":
            "Mulailah perjalanan olahraga kamu dengan cara yang benar. Berikut 5 tips penting agar latihanmu lebih efektif dan aman!",
      },
      {
        "title": "Kenali Manfaat Futsal untuk Kesehatan Tubuh",
        "author": "Tim Redaksi Banyumas SportHub",
        "image": "assets/images/futsal_article.png",
        "date": "18 Oktober 2025",
        "desc":
            "Olahraga futsal tak hanya seru, tapi juga meningkatkan kebugaran jantung, kelincahan, dan kerja sama tim. Yuk simak penjelasannya!",
      },
      {
        "title": "Event Lari Banyumas Fun Run 2025 Segera Dimulai!",
        "author": "Official Banyumas SportHub",
        "image": "assets/images/run_event.png",
        "date": "15 Oktober 2025",
        "desc":
            "Event olahraga terbesar di Banyumas akan segera hadir! Catat tanggalnya dan daftar sekarang sebelum kehabisan slot!",
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserMainPage()),
            );
          },
        ),
        title: const Text("Artikel & Berita"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final item = articles[index];
          return _buildArticleCard(context, item);
        },
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        _showArticleDetail(context, item);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                item["image"],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          color: AppTheme.primaryColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        item["author"],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.calendar_today_outlined,
                          color: AppTheme.primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        item["date"],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item["desc"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showArticleDetail(context, item),
                    child: const Text(
                      "Baca Selengkapnya →",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArticleDetail(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  item["image"],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                item["title"],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${item["author"]}  •  ${item["date"]}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 25),
              Text(
                item["desc"],
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
