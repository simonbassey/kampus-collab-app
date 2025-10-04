import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/api.dart';
import '../controllers/auth_controller.dart';
import '../controllers/student_profile_controller.dart';

class PostCreationService {
  final AuthController _authController = Get.find<AuthController>();
  final StudentProfileController _profileController = Get.find<StudentProfileController>();

  Future<Map<String, dynamic>> createPost(String content, String visibility, {List<String>? imagePaths}) async {
    // Check authentication
    if (!_authController.isAuthenticated.value) {
      throw Exception('User not authenticated. Please log in.');
    }
    
    final token = await _authController.getAuthToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }
    
    // Make sure profile is loaded
    if (_profileController.studentProfile.value == null) {
      await _profileController.fetchCurrentUserProfile();
    }

    final response = await http.post(
      Uri.parse(ApiConstants.createPost),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'content': content,
        // Convert visibility options to backend-compatible values
        'visibility': _convertVisibilityToApiValue(visibility),
        // Add user profile metadata if available
        'authorId': _profileController.studentProfile.value?.userId,
        'authorName': _profileController.studentProfile.value?.fullName,
        'authorProfileImage': _profileController.studentProfile.value?.profilePhotoUrl,
        // Include image paths if available
        'images': imagePaths ?? [],
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
  
  // Convert UI visibility options to API-compatible values
  String _convertVisibilityToApiValue(String visibility) {
    switch (visibility) {
      case 'Everyone':
        return 'public';
      case 'Verified accounts only':
        return 'verified';
      case 'Accounts you follow':
        return 'followers';
      case 'Accounts you mention':
        return 'mentioned';
      default:
        return 'public';
    }
  }
}
