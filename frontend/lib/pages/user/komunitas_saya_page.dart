import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/community_membership_service.dart';

class KomunitasSayaPage extends StatefulWidget {
  const KomunitasSayaPage({super.key});

  @override
  State<KomunitasSayaPage> createState() => _KomunitasSayaPageState();
}

class _KomunitasSayaPageState extends State<KomunitasSayaPage> {
  final CommunityMembershipService _service = CommunityMembershipService.instance;
  List<CommunityMembershipModel> _memberships = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  Future<void> _loadMemberships() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final memberships = await _service.fetchMyCommunities();
      setState(() {
        _memberships = memberships.where((m) => m.status == 'active').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _leaveCommunity(CommunityMembershipModel membership) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Keluar Komunitas"),
        content: Text("Keluar dari ${membership.communityName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Tidak"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.leaveCommunity(membership.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil keluar dari komunitas"), backgroundColor: Colors.green),
      );
      _loadMemberships();
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
      appBar: AppBar(
        title: const Text("Komunitas Saya"),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
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
                        onPressed: _loadMemberships,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMemberships,
                  child: _memberships.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                            Column(
                              children: [
                                Icon(Icons.groups_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text(
                                  "Belum bergabung dengan komunitas",
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Cari dan gabung komunitas di halaman Komunitas",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _memberships.length,
                          itemBuilder: (context, index) {
                            final membership = _memberships[index];
                            return _buildMembershipCard(membership);
                          },
                        ),
                ),
    );
  }

  Widget _buildMembershipCard(CommunityMembershipModel membership) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          if (membership.communityImageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                membership.communityImageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.groups, size: 40, color: Colors.grey)),
                ),
              ),
            )
          else
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(Icons.groups, size: 40, color: AppTheme.primaryColor),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        membership.communityName ?? 'Komunitas',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: membership.role == 'admin'
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        membership.role == 'admin' ? 'Admin' : 'Member',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: membership.role == 'admin' ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                if (membership.communityCategory != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      membership.communityCategory!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
                if (membership.communityDescription != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    membership.communityDescription!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _leaveCommunity(membership),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text("Keluar Komunitas"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
