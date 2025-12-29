import 'api_client.dart';

class EventRegistrationService {
  EventRegistrationService._();
  static final EventRegistrationService instance = EventRegistrationService._();
  final ApiClient _client = ApiClient.instance;

  /// Register for event
  Future<EventRegistrationModel> register(String eventId) async {
    final response = await _client.post('/event-registrations/$eventId/register', {});
    return EventRegistrationModel.fromJson(response['registration'] as Map<String, dynamic>);
  }

  /// Get user's registrations
  Future<List<EventRegistrationModel>> fetchMyRegistrations() async {
    final response = await _client.get('/event-registrations/my-registrations');
    final registrations = response['registrations'] as List<dynamic>? ?? [];
    return registrations
        .map((json) => EventRegistrationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Check if registered for event
  Future<bool> checkRegistration(String eventId) async {
    final response = await _client.get('/event-registrations/$eventId/check');
    return response['isRegistered'] as bool? ?? false;
  }

  /// Cancel registration
  Future<void> cancelRegistration(String registrationId) async {
    await _client.post('/event-registrations/$registrationId/cancel', {});
  }

  /// Get all registrations (admin)
  Future<List<EventRegistrationModel>> fetchAllRegistrations() async {
    final response = await _client.get('/event-registrations');
    final registrations = response['registrations'] as List<dynamic>? ?? [];
    return registrations
        .map((json) => EventRegistrationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get registrations by event (admin)
  Future<List<EventRegistrationModel>> fetchByEvent(String eventId) async {
    final response = await _client.get('/event-registrations/event/$eventId');
    final registrations = response['registrations'] as List<dynamic>? ?? [];
    return registrations
        .map((json) => EventRegistrationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Update registration status (admin)
  Future<void> updateStatus(String id, String status) async {
    await _client.patch('/event-registrations/$id/status', {'status': status});
  }

  /// Delete registration (admin)
  Future<void> deleteRegistration(String id) async {
    await _client.delete('/event-registrations/$id');
  }

  /// Get registration count for event
  Future<int> getCount(String eventId) async {
    final response = await _client.get('/event-registrations/$eventId/count');
    return response['count'] as int? ?? 0;
  }
}

class EventRegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final String status;
  final String? eventTitle;
  final String? eventDate;
  final String? eventLocation;
  final String? eventImageUrl;
  final String? userName;
  final String? userEmail;
  final DateTime? registeredAt;

  EventRegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    this.eventTitle,
    this.eventDate,
    this.eventLocation,
    this.eventImageUrl,
    this.userName,
    this.userEmail,
    this.registeredAt,
  });

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json) {
    return EventRegistrationModel(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      status: json['status'] as String? ?? 'registered',
      eventTitle: json['eventTitle'] as String?,
      eventDate: json['eventDate'] as String?,
      eventLocation: json['eventLocation'] as String?,
      eventImageUrl: json['eventImageUrl'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      registeredAt: json['registeredAt'] != null 
          ? DateTime.tryParse(json['registeredAt'].toString()) 
          : null,
    );
  }
}
