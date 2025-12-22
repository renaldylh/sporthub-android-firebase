import 'api_client.dart';

class CommunityService {
  CommunityService._();

  static final CommunityService instance = CommunityService._();
  final ApiClient _client = ApiClient.instance;

  Future<List<CommunityModel>> fetchCommunities() async {
    final response = await _client.get('/communities');
    final communities = response['communities'] as List<dynamic>? ?? [];
    return communities
        .map((json) => CommunityModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CommunityModel> createCommunity(Map<String, dynamic> data) async {
    final response = await _client.post('/communities', data);
    return CommunityModel.fromJson(response['community'] as Map<String, dynamic>);
  }

  Future<CommunityModel> updateCommunity(String id, Map<String, dynamic> data) async {
    final response = await _client.put('/communities/$id', data);
    return CommunityModel.fromJson(response['community'] as Map<String, dynamic>);
  }

  Future<void> deleteCommunity(String id) async {
    await _client.delete('/communities/$id');
  }
}

class CommunityModel {
  final String id;
  final String name;
  final String? description;
  final int memberCount;
  final String? imageUrl;
  final String? category;
  final bool isActive;

  CommunityModel({
    required this.id,
    required this.name,
    this.description,
    this.memberCount = 0,
    this.imageUrl,
    this.category,
    this.isActive = true,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      isActive: json['isActive'] == true || json['isActive'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'memberCount': memberCount,
    'imageUrl': imageUrl,
    'category': category,
    'isActive': isActive,
  };
}
