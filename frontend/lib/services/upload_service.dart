import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  final ImagePicker _picker = ImagePicker();
  
  // Freeimage.host API - completely free, no registration needed
  static const String _apiKey = '6d207e02198a847aa98d0a2a901485a5';
  static const String _uploadUrl = 'https://freeimage.host/api/1/upload';

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

  /// Upload image to Freeimage.host (free, no registration)
  Future<String> uploadImage(XFile file) async {
    debugPrint('[UploadService] ===== UPLOAD STARTED =====');
    debugPrint('[UploadService] File: ${file.name}');
    
    try {
      final bytes = await file.readAsBytes();
      debugPrint('[UploadService] File size: ${bytes.length} bytes');
      
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      // Convert to base64
      final base64Image = base64Encode(bytes);
      debugPrint('[UploadService] Base64 length: ${base64Image.length}');

      // Upload to Freeimage.host
      debugPrint('[UploadService] Uploading to Freeimage.host...');
      
      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: {
          'key': _apiKey,
          'action': 'upload',
          'source': base64Image,
          'format': 'json',
        },
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout');
        },
      );

      debugPrint('[UploadService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('[UploadService] Response success: ${data['status_code']}');
        
        if (data['status_code'] == 200 && data['image'] != null) {
          final imageUrl = data['image']['url'] as String;
          debugPrint('[UploadService] ===== SUCCESS =====');
          debugPrint('[UploadService] URL: $imageUrl');
          return imageUrl;
        } else {
          final error = data['error']?['message'] ?? data['status_txt'] ?? 'Unknown error';
          throw Exception('Freeimage error: $error');
        }
      } else {
        debugPrint('[UploadService] Error body: ${response.body}');
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[UploadService] ===== FAILED =====');
      debugPrint('[UploadService] Error: $e');
      throw Exception('Upload gagal: $e');
    }
  }
}
