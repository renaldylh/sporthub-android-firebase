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
    debugPrint('[UploadService] pickImage() called');
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (file != null) {
        debugPrint('[UploadService] Image picked: ${file.name}');
      } else {
        debugPrint('[UploadService] No image selected');
      }
      return file;
    } catch (e) {
      debugPrint('[UploadService] ERROR picking image: $e');
      rethrow;
    }
  }

  /// Pick image from camera
  Future<XFile?> takePhoto() async {
    debugPrint('[UploadService] takePhoto() called');
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (file != null) {
        debugPrint('[UploadService] Photo taken: ${file.name}');
      }
      return file;
    } catch (e) {
      debugPrint('[UploadService] ERROR taking photo: $e');
      rethrow;
    }
  }

  /// Get MIME type from filename
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
        return MediaType('image', 'jpeg');
    }
  }

  /// Upload image via backend (avoids CORS issues)
  Future<String> uploadImage(XFile file) async {
    debugPrint('[UploadService] ===== UPLOAD STARTED =====');
    debugPrint('[UploadService] File: ${file.name}');
    
    try {
      // Get backend URL
      final baseUrl = ApiClient.instance.baseUrl.replaceAll('/api', '');
      final uploadUrl = '$baseUrl/api/upload';
      debugPrint('[UploadService] Backend URL: $uploadUrl');

      // Read file bytes
      final bytes = await file.readAsBytes();
      debugPrint('[UploadService] File size: ${bytes.length} bytes');
      
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Add auth header if available
      final token = ApiClient.instance.token;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Determine filename and content type
      String filename = file.name;
      if (!filename.contains('.')) {
        filename = '$filename.jpg';
      }
      final mimeType = _getMimeType(filename);

      // Add file to request
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
        contentType: mimeType,
      ));

      debugPrint('[UploadService] Sending to backend...');

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          throw Exception('Upload timeout');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('[UploadService] Response status: ${response.statusCode}');
      debugPrint('[UploadService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['imageUrl'] as String;
        debugPrint('[UploadService] ===== SUCCESS =====');
        debugPrint('[UploadService] URL: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Backend error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[UploadService] ===== FAILED =====');
      debugPrint('[UploadService] Error: $e');
      throw Exception('Upload gagal: $e');
    }
  }
}
