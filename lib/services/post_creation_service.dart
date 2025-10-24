import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/api.dart';
import '../controllers/auth_controller.dart';

class PostCreationService {
  final AuthController _authController = Get.find<AuthController>();

  Future<Map<String, dynamic>> createPost(
    String content,
    String visibility, {
    List<String>? imagePaths, // Deprecated: use imageUrls instead
    List<String>? imageUrls, // Image URLs from Supabase storage
    String? parentId, // For thread creation
  }) async {
    // Check authentication
    if (!_authController.isAuthenticated.value) {
      throw Exception('User not authenticated. Please log in.');
    }

    final token = await _authController.getAuthToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    // Use imageUrls if provided, otherwise fall back to imagePaths for backward compatibility
    final mediaUrls = imageUrls ?? imagePaths ?? [];

    // Determine content type based on whether images are provided
    String contentType = 'Text';
    if (mediaUrls.isNotEmpty) {
      contentType = 'Image';
    }

    // Determine post type based on whether it's a thread reply
    String postType = parentId != null ? 'Reply' : 'Original';

    final response = await http.post(
      Uri.parse(ApiConstants.createPost),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'Content': content.isEmpty && mediaUrls.isNotEmpty ? ' ' : content, // Ensure Content is never empty when images exist
        'ContentType': contentType,
        'MediaUrls': mediaUrls,
        'Audience': _convertVisibilityToApiValue(visibility),
        'PostType': postType,
        if (parentId != null) 'ParentId': parentId,
      }),
    );

    print('REQUEST TYPE: POST - Creating a new post');
    print('POST create post status: ${response.statusCode}');
    print('POST create post response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to create post: ${response.body}');
    }
  }

  // Convert UI visibility options to API-compatible audience values
  String _convertVisibilityToApiValue(String visibility) {
    switch (visibility) {
      case 'Everyone':
        return 'Public';
      case 'Verified accounts only':
        return 'Public'; // API only supports Public, Private, Friends
      case 'Accounts you follow':
        return 'Friends';
      case 'Accounts you mention':
        return 'Private';
      default:
        return 'Public';
    }
  }
}
