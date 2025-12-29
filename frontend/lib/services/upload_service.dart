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
  
  // ImgBB API key (fallback for direct upload)
  static const String _imgbbApiKey = '7c39eba7c90b99b20651dded97f0ba4c';

  /// Pick image from gallery
  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('[UploadService] Pick image error: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<XFile?> takePhoto() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('[UploadService] Take photo error: $e');
      return null;
    }
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
        return MediaType('image', 'jpeg');
    }
  }

  /// Upload image - tries backend first, falls back to direct ImgBB
  Future<String> uploadImage(XFile file) async {
    debugPrint('[UploadService] Starting upload for: ${file.name}');
    
    try {
      // Try backend upload first
      final result = await _uploadViaBackend(file);
      debugPrint('[UploadService] Backend upload success: $result');
      return result;
    } catch (backendError) {
      debugPrint('[UploadService] Backend upload failed: $backendError');
      debugPrint('[UploadService] Trying direct ImgBB upload...');
      
      try {
        // Fallback to direct ImgBB upload
        final result = await _uploadDirectToImgBB(file);
        debugPrint('[UploadService] Direct ImgBB upload success: $result');
        return result;
      } catch (imgbbError) {
        debugPrint('[UploadService] Direct ImgBB upload also failed: $imgbbError');
        throw Exception('Upload gagal: $imgbbError');
      }
    }
  }

  /// Upload via backend
  Future<String> _uploadViaBackend(XFile file) async {
    final baseUrl = ApiClient.instance.baseUrl.replaceAll('/api', '');
    final uri = Uri.parse('$baseUrl/api/upload');
    
    debugPrint('[UploadService] Backend URL: $uri');

    final request = http.MultipartRequest('POST', uri);
    
    final token = ApiClient.instance.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final mimeType = _getMimeType(file.name);
    final bytes = await file.readAsBytes();
    
    debugPrint('[UploadService] File size: ${bytes.length} bytes');
    
    String filename = file.name;
    if (!filename.contains('.')) {
      filename = '$filename.jpg';
    }

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: filename,
      contentType: mimeType,
    ));

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Upload timeout');
      },
    );
    
    final response = await http.Response.fromStream(streamedResponse);
    
    debugPrint('[UploadService] Backend response: ${response.statusCode}');
    debugPrint('[UploadService] Backend body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['imageUrl'] as String;
    } else {
      throw Exception('Backend error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Upload directly to ImgBB (fallback)
  Future<String> _uploadDirectToImgBB(XFile file) async {
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    debugPrint('[UploadService] Direct ImgBB upload, base64 length: ${base64Image.length}');

    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload'),
      body: {
        'key': _imgbbApiKey,
        'image': base64Image,
        'name': file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
      },
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('ImgBB timeout');
      },
    );

    debugPrint('[UploadService] ImgBB response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data']['url'] as String;
      } else {
        throw Exception('ImgBB error: ${data['error']?['message'] ?? 'Unknown'}');
      }
    } else {
      throw Exception('ImgBB HTTP error: ${response.statusCode}');
    }
  }
}

