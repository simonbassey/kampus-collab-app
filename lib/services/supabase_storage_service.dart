import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';

class SupabaseStorageService {
  final SupabaseClient _client = SupabaseService.client;

  /// Upload a single image to Supabase storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadPostImage(File imageFile) async {
    try {
      print('SupabaseStorageService: Starting upload for ${imageFile.path}');

      // Validate file size
      final fileSize = await imageFile.length();
      if (fileSize > SupabaseConfig.maxFileSizeBytes) {
        throw Exception(
          'File size exceeds maximum allowed size of ${SupabaseConfig.maxFileSizeBytes / (1024 * 1024)}MB',
        );
      }

      // Get file extension
      final fileExtension = path.extension(imageFile.path).toLowerCase();

      // Validate file type
      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception('File must be an image');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomId = _generateRandomId();
      final fileName = 'post_${timestamp}_$randomId$fileExtension';

      // Store in MediaContents folder
      final storagePath = 'MediaContents/$fileName';

      print('SupabaseStorageService: Uploading as $storagePath');

      // Read file bytes
      final fileBytes = await imageFile.readAsBytes();

      // Upload to Supabase storage
      final uploadPath = await _client.storage
          .from(SupabaseConfig.postImagesBucket)
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );

      print('SupabaseStorageService: Upload successful - $uploadPath');

      // Get public URL
      final publicUrl = _client.storage
          .from(SupabaseConfig.postImagesBucket)
          .getPublicUrl(storagePath);

      print('SupabaseStorageService: Public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('SupabaseStorageService: Upload error: $e');
      rethrow;
    }
  }

  /// Upload multiple images to Supabase storage
  /// Returns a list of public URLs
  Future<List<String>> uploadPostImages(List<File> imageFiles) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        print(
          'SupabaseStorageService: Uploading image ${i + 1}/${imageFiles.length}',
        );
        final url = await uploadPostImage(imageFiles[i]);
        uploadedUrls.add(url);
      } catch (e) {
        print('SupabaseStorageService: Failed to upload image ${i + 1}: $e');
        // Clean up previously uploaded images
        await _cleanupUploadedImages(uploadedUrls);
        rethrow;
      }
    }

    return uploadedUrls;
  }

  /// Delete an image from Supabase storage
  Future<void> deletePostImage(String imageUrl) async {
    try {
      // Extract the full path from URL
      final uri = Uri.parse(imageUrl);
      // Get the path after 'object/public/bucket-name/'
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('public') + 1;

      // Reconstruct the storage path (includes MediaContents folder)
      final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');

      print('SupabaseStorageService: Deleting $storagePath');

      await _client.storage.from(SupabaseConfig.postImagesBucket).remove([
        storagePath,
      ]);

      print('SupabaseStorageService: Delete successful');
    } catch (e) {
      print('SupabaseStorageService: Delete error: $e');
      rethrow;
    }
  }

  /// Delete multiple images from Supabase storage
  Future<void> deletePostImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await deletePostImage(url);
      } catch (e) {
        print('SupabaseStorageService: Failed to delete $url: $e');
        // Continue deleting other images even if one fails
      }
    }
  }

  /// Clean up uploaded images (used when upload fails midway)
  Future<void> _cleanupUploadedImages(List<String> uploadedUrls) async {
    if (uploadedUrls.isEmpty) return;

    print(
      'SupabaseStorageService: Cleaning up ${uploadedUrls.length} uploaded images',
    );
    await deletePostImages(uploadedUrls);
  }

  /// Generate a random ID for filename uniqueness
  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
      8,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }

  /// Check if storage bucket exists and is accessible
  Future<bool> checkBucketAccess() async {
    try {
      await _client.storage.from(SupabaseConfig.postImagesBucket).list();
      return true;
    } catch (e) {
      print('SupabaseStorageService: Bucket access check failed: $e');
      return false;
    }
  }
}
