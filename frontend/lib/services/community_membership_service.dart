import 'api_client.dart';

class CommunityMembershipService {
  CommunityMembershipService._();
  static final CommunityMembershipService instance = CommunityMembershipService._();
  final ApiClient _client = ApiClient.instance;

  /// Join community
  Future<CommunityMembershipModel> join(String communityId) async {
    final response = await _client.post('/community-memberships/$communityId/join', {});
    return CommunityMembershipModel.fromJson(response['membership'] as Map<String, dynamic>);
  }

  /// Get user's communities
  Future<List<CommunityMembershipModel>> fetchMyCommunities() async {
    final response = await _client.get('/community-memberships/my-communities');
    final memberships = response['memberships'] as List<dynamic>? ?? [];
    return memberships
        .map((json) => CommunityMembershipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Check if member of community
  Future<bool> checkMembership(String communityId) async {
    final response = await _client.get('/community-memberships/$communityId/check');
    return response['isMember'] as bool? ?? false;
  }

  /// Leave community
  Future<void> leaveCommunity(String membershipId) async {
    await _client.post('/community-memberships/$membershipId/leave', {});
  }

  /// Get all memberships (admin)
  Future<List<CommunityMembershipModel>> fetchAllMemberships() async {
    final response = await _client.get('/community-memberships');
    final memberships = response['memberships'] as List<dynamic>? ?? [];
    return memberships
        .map((json) => CommunityMembershipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get members by community (admin)
  Future<List<CommunityMembershipModel>> fetchByCommunity(String communityId) async {
    final response = await _client.get('/community-memberships/community/$communityId');
    final memberships = response['memberships'] as List<dynamic>? ?? [];
    return memberships
        .map((json) => CommunityMembershipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Update membership role (admin)
  Future<void> updateRole(String id, String role) async {
    await _client.patch('/community-memberships/$id/role', {'role': role});
  }

  /// Delete membership (admin)
  Future<void> deleteMembership(String id) async {
    await _client.delete('/community-memberships/$id');
  }

  /// Get member count for community
  Future<int> getCount(String communityId) async {
    final response = await _client.get('/community-memberships/$communityId/count');
    return response['count'] as int? ?? 0;
  }
}

class CommunityMembershipModel {
  final String id;
  final String communityId;
  final String userId;
  final String status;
  final String role;
  final String? communityName;
  final String? communityCategory;
  final String? communityDescription;
  final String? communityImageUrl;
  final String? userName;
  final String? userEmail;
  final DateTime? joinedAt;

  CommunityMembershipModel({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.status,
    required this.role,
    this.communityName,
    this.communityCategory,
    this.communityDescription,
    this.communityImageUrl,
    this.userName,
    this.userEmail,
    this.joinedAt,
  });

  factory CommunityMembershipModel.fromJson(Map<String, dynamic> json) {
    return CommunityMembershipModel(
      id: json['id'] as String? ?? '',
      communityId: json['communityId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      role: json['role'] as String? ?? 'member',
      communityName: json['communityName'] as String?,
      communityCategory: json['communityCategory'] as String?,
      communityDescription: json['communityDescription'] as String?,
      communityImageUrl: json['communityImageUrl'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      joinedAt: json['joinedAt'] != null 
          ? DateTime.tryParse(json['joinedAt'].toString()) 
          : null,
    );
  }
}
