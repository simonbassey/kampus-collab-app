import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';

class ProfileImageUploadService {
  final SupabaseClient _client = SupabaseService.client;

  /// Upload profile photo to Supabase storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      print('ProfileImageUploadService: Starting profile photo upload');

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
      final fileName = 'profile_${timestamp}_$randomId$fileExtension';

      // Store in MediaContents/profiles folder
      final storagePath = 'MediaContents/profiles/$fileName';

      print('ProfileImageUploadService: Uploading as $storagePath');

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

      print('ProfileImageUploadService: Upload successful - $uploadPath');

      // Get public URL
      final publicUrl = _client.storage
          .from(SupabaseConfig.postImagesBucket)
          .getPublicUrl(storagePath);

      print('ProfileImageUploadService: Public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('ProfileImageUploadService: Upload error: $e');
      rethrow;
    }
  }

  /// Upload identity card to Supabase storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadIdCard(File imageFile) async {
    try {
      print('ProfileImageUploadService: Starting ID card upload');

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
      final fileName = 'idcard_${timestamp}_$randomId$fileExtension';

      // Store in MediaContents/id-cards folder
      final storagePath = 'MediaContents/id-cards/$fileName';

      print('ProfileImageUploadService: Uploading as $storagePath');

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

      print('ProfileImageUploadService: Upload successful - $uploadPath');

      // Get public URL
      final publicUrl = _client.storage
          .from(SupabaseConfig.postImagesBucket)
          .getPublicUrl(storagePath);

      print('ProfileImageUploadService: Public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('ProfileImageUploadService: Upload error: $e');
      rethrow;
    }
  }

  /// Delete an image from Supabase storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract the full path from URL
      final uri = Uri.parse(imageUrl);
      // Get the path after 'object/public/bucket-name/'
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('public') + 1;

      // Reconstruct the storage path (includes MediaContents folder)
      final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');

      print('ProfileImageUploadService: Deleting $storagePath');

      await _client.storage.from(SupabaseConfig.postImagesBucket).remove([
        storagePath,
      ]);

      print('ProfileImageUploadService: Delete successful');
    } catch (e) {
      print('ProfileImageUploadService: Delete error: $e');
      rethrow;
    }
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
}
