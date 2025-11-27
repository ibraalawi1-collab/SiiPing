import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class MediaService {
  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  /// Pick an image from gallery
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Upload image to Supabase Storage and return public URL
  Future<String?> uploadImage(XFile imageFile, String bucket) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}_${_supabase.auth.currentUser!.id}.$fileExt';
      final filePath = fileName; // Simple path

      await _supabase.storage.from(bucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'), // Defaulting to jpeg for simplicity or detect
          );

      final imageUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
