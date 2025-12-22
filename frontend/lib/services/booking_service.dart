import 'api_client.dart';

class BookingService {
  BookingService._();

  static final BookingService instance = BookingService._();
  final ApiClient _client = ApiClient.instance;

  /// Get all bookings (admin)
  Future<List<BookingModel>> fetchAllBookings() async {
    final response = await _client.get('/bookings');
    final bookings = response['bookings'] as List<dynamic>? ?? [];
    return bookings
        .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get user's bookings
  Future<List<BookingModel>> fetchMyBookings() async {
    final response = await _client.get('/bookings/me');
    final bookings = response['bookings'] as List<dynamic>? ?? [];
    return bookings
        .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create booking
  Future<BookingModel> createBooking(Map<String, dynamic> data) async {
    final response = await _client.post('/bookings', data);
    return BookingModel.fromJson(response['booking'] as Map<String, dynamic>);
  }

  /// Update booking status (admin)
  Future<BookingModel> updateStatus(String id, String status, {String? adminNotes}) async {
    final response = await _client.patch('/bookings/$id/status', {
      'status': status,
      if (adminNotes != null) 'adminNotes': adminNotes,
    });
    return BookingModel.fromJson(response['booking'] as Map<String, dynamic>);
  }

  /// Cancel booking (user)
  Future<BookingModel> cancelBooking(String id) async {
    final response = await _client.post('/bookings/$id/cancel', {});
    return BookingModel.fromJson(response['booking'] as Map<String, dynamic>);
  }
}

class BookingModel {
  final String id;
  final String venueId;
  final String userId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final double totalPrice;
  final String status;
  final String? notes;
  final String? adminNotes;
  final String? venueName;
  final String? venueType;
  final String? userName;
  final String? userEmail;
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.venueId,
    required this.userId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.notes,
    this.adminNotes,
    this.venueName,
    this.venueType,
    this.userName,
    this.userEmail,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      venueId: json['venueId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      venueName: json['venueName'] as String?,
      venueType: json['venueType'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
    );
  }
}
