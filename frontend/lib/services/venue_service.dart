import 'api_client.dart';

class VenueService {
  VenueService._();

  static final VenueService instance = VenueService._();
  final ApiClient _client = ApiClient.instance;

  Future<List<VenueModel>> fetchVenues() async {
    final response = await _client.get('/venues');
    final venues = response['venues'] as List<dynamic>? ?? [];
    return venues
        .map((json) => VenueModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<VenueModel> getVenue(String id) async {
    final response = await _client.get('/venues/$id');
    return VenueModel.fromJson(response['venue'] as Map<String, dynamic>);
  }

  Future<VenueModel> createVenue(Map<String, dynamic> data) async {
    final response = await _client.post('/venues', data);
    return VenueModel.fromJson(response['venue'] as Map<String, dynamic>);
  }

  Future<VenueModel> updateVenue(String id, Map<String, dynamic> data) async {
    final response = await _client.put('/venues/$id', data);
    return VenueModel.fromJson(response['venue'] as Map<String, dynamic>);
  }

  Future<void> deleteVenue(String id) async {
    await _client.delete('/venues/$id');
  }
}

class VenueModel {
  final String id;
  final String name;
  final String type;
  final double pricePerHour;
  final String? address;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;

  VenueModel({
    required this.id,
    required this.name,
    required this.type,
    required this.pricePerHour,
    this.address,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      pricePerHour: _parseDouble(json['pricePerHour']),
      address: json['address'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] == true || json['isAvailable'] == 1,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'pricePerHour': pricePerHour,
    'address': address,
    'description': description,
    'imageUrl': imageUrl,
    'isAvailable': isAvailable,
  };
}
