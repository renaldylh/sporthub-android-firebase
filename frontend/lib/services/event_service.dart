import 'api_client.dart';

class EventService {
  EventService._();

  static final EventService instance = EventService._();
  final ApiClient _client = ApiClient.instance;

  Future<List<EventModel>> fetchEvents() async {
    final response = await _client.get('/events');
    final events = response['events'] as List<dynamic>? ?? [];
    return events
        .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<EventModel> getEvent(String id) async {
    final response = await _client.get('/events/$id');
    return EventModel.fromJson(response['event'] as Map<String, dynamic>);
  }

  Future<EventModel> createEvent(Map<String, dynamic> data) async {
    final response = await _client.post('/events', data);
    return EventModel.fromJson(response['event'] as Map<String, dynamic>);
  }

  Future<EventModel> updateEvent(String id, Map<String, dynamic> data) async {
    final response = await _client.put('/events/$id', data);
    return EventModel.fromJson(response['event'] as Map<String, dynamic>);
  }

  Future<void> deleteEvent(String id) async {
    await _client.delete('/events/$id');
  }
}

class EventModel {
  final String id;
  final String title;
  final String? description;
  final String eventDate;
  final String? location;
  final String? imageUrl;
  final bool isActive;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.location,
    this.imageUrl,
    this.isActive = true,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      eventDate: json['eventDate'] as String? ?? '',
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] == true || json['isActive'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'eventDate': eventDate,
    'location': location,
    'imageUrl': imageUrl,
    'isActive': isActive,
  };
}
