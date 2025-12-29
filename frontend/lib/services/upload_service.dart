import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  final ImagePicker _picker = ImagePicker();
  
  // Cloudinary configuration - using demo account for unsigned uploads
  static const String _cloudName = 'demo';
  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/demo/image/upload';

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

  /// Upload image to Cloudinary (free tier, reliable)
  Future<String> uploadImage(XFile file) async {
    debugPrint('[UploadService] ===== UPLOAD STARTED =====');
    debugPrint('[UploadService] File: ${file.name}');
    
    try {
      final bytes = await file.readAsBytes();
      debugPrint('[UploadService] File size: ${bytes.length} bytes');
      
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      // Create base64 data URI for Cloudinary
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      debugPrint('[UploadService] Base64 created, uploading to Cloudinary...');

      // Upload to Cloudinary using unsigned upload
      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: {
          'file': base64Image,
          'upload_preset': 'ml_default',
          'folder': 'sporthub',
        },
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout');
        },
      );

      debugPrint('[UploadService] Cloudinary status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['secure_url'] != null) {
          final imageUrl = data['secure_url'] as String;
          debugPrint('[UploadService] ===== SUCCESS =====');
          debugPrint('[UploadService] URL: $imageUrl');
          return imageUrl;
        }
        throw Exception('No URL in response');
      } else {
        debugPrint('[UploadService] Error: ${response.body}');
        throw Exception('Cloudinary error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[UploadService] ===== FAILED =====');
      debugPrint('[UploadService] Error: $e');
      throw Exception('Upload gagal: $e');
    }
  }
}
