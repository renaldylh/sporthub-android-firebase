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
  
  // ImgBB API key
  static const String _imgbbApiKey = '7c39eba7c90b99b20651dded97f0ba4c';

  /// Pick image from gallery
  Future<XFile?> pickImage() async {
    debugPrint('[UploadService] pickImage() called');
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        debugPrint('[UploadService] Image picked: ${file.name}, path: ${file.path}');
      } else {
        debugPrint('[UploadService] No image selected');
      }
      return file;
    } catch (e, stack) {
      debugPrint('[UploadService] ERROR picking image: $e');
      debugPrint('[UploadService] Stack: $stack');
      rethrow;
    }
  }

  /// Pick image from camera
  Future<XFile?> takePhoto() async {
    debugPrint('[UploadService] takePhoto() called');
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        debugPrint('[UploadService] Photo taken: ${file.name}');
      } else {
        debugPrint('[UploadService] No photo taken');
      }
      return file;
    } catch (e, stack) {
      debugPrint('[UploadService] ERROR taking photo: $e');
      debugPrint('[UploadService] Stack: $stack');
      rethrow;
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

  /// Upload image - uses direct ImgBB upload (most reliable for Flutter Web)
  Future<String> uploadImage(XFile file) async {
    debugPrint('[UploadService] ===== UPLOAD STARTED =====');
    debugPrint('[UploadService] File name: ${file.name}');
    debugPrint('[UploadService] File path: ${file.path}');
    
    try {
      // Read file bytes
      final bytes = await file.readAsBytes();
      debugPrint('[UploadService] File size: ${bytes.length} bytes');
      
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      // Convert to base64
      final base64Image = base64Encode(bytes);
      debugPrint('[UploadService] Base64 encoded, length: ${base64Image.length}');

      // Upload directly to ImgBB (most reliable method)
      debugPrint('[UploadService] Uploading to ImgBB...');
      
      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {
          'key': _imgbbApiKey,
          'image': base64Image,
          'name': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout after 60 seconds');
        },
      );

      debugPrint('[UploadService] ImgBB response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('[UploadService] ImgBB response success: ${data['success']}');
        
        if (data['success'] == true && data['data'] != null) {
          final imageUrl = data['data']['url'] as String;
          debugPrint('[UploadService] ===== UPLOAD SUCCESS =====');
          debugPrint('[UploadService] Image URL: $imageUrl');
          return imageUrl;
        } else {
          final errorMsg = data['error']?['message'] ?? 'Unknown ImgBB error';
          throw Exception('ImgBB error: $errorMsg');
        }
      } else {
        debugPrint('[UploadService] ImgBB error body: ${response.body}');
        throw Exception('ImgBB HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stack) {
      debugPrint('[UploadService] ===== UPLOAD FAILED =====');
      debugPrint('[UploadService] Error: $e');
      debugPrint('[UploadService] Stack: $stack');
      throw Exception('Upload gagal: $e');
    }
  }
}
