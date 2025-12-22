import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/community_service.dart';

class KomunitasPage extends StatefulWidget {
  const KomunitasPage({super.key});

  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  final CommunityService _communityService = CommunityService.instance;
  List<CommunityModel> _communities = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

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

  List<CommunityModel> get filteredCommunities {
    if (_searchQuery.isEmpty) return _communities;
    return _communities.where((c) =>
        c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (c.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text("Komunitas Olahraga"),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadCommunities,
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
                        onPressed: _loadCommunities,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCommunities,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bergabung dengan komunitas olahraga di Banyumas dan kembangkan semangat sportivitasmu!",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 20),

                        // Search bar
                        TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: "Cari komunitas...",
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

                        if (filteredCommunities.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.groups_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text("Belum ada komunitas"),
                              ],
                            ),
                          )
                        else
                          ...filteredCommunities.map((community) => _buildCommunityCard(community)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCommunityCard(CommunityModel community) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shadowColor: Colors.black12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 110,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: community.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(community.imageUrl!),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: community.imageUrl == null
                  ? const Icon(Icons.groups, size: 40, color: Colors.grey)
                  : null,
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (community.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              community.category!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          "${community.memberCount} anggota",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      community.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Bergabung dengan ${community.name}"),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Gabung", style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
