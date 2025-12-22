import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'api_client.dart';

class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  /// Pick image from camera
  Future<XFile?> takePhoto() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  /// Get proper MIME type from file extension
  MediaType _getMimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg'); // Default to jpeg
    }
  }

  /// Upload image to server and return URL
  Future<String> uploadImage(XFile file) async {
    final baseUrl = ApiClient.instance.baseUrl.replaceAll('/api', '');
    final uri = Uri.parse('$baseUrl/api/upload');

    final request = http.MultipartRequest('POST', uri);
    
    // Add authorization header if logged in
    final token = ApiClient.instance.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Determine content type from extension
    final mimeType = _getMimeType(file.name);

    // Read bytes (works for both web and mobile)
    final bytes = await file.readAsBytes();
    
    // Use a proper filename with extension
    String filename = file.name;
    if (!filename.contains('.')) {
      filename = '$filename.jpg'; // Default extension
    }

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: filename,
      contentType: mimeType,
    ));

    if (kDebugMode) {
      print('[UploadService] Uploading: $filename with type: $mimeType');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return '$baseUrl${data['imageUrl']}';
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }
}
