import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/api.dart';
import '../controllers/auth_controller.dart';
import '../controllers/student_profile_controller.dart';

class ProjectCreationService {
  final AuthController _authController = Get.find<AuthController>();
  final StudentProfileController _profileController =
      Get.find<StudentProfileController>();

  Future<Map<String, dynamic>> createProject({
    required String title,
    required String description,
    required String skills,
    required int teammatesCount,
    required String visibility,
  }) async {
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

    // For demo purposes, using the same endpoint as posts with modified fields
    final response = await http.post(
      Uri.parse(
        ApiConstants.createPost,
      ), // Ideally use a project-specific endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'skills': skills,
        'teammatesCount': teammatesCount,
        'visibility': _convertVisibilityToApiValue(visibility),
        'type': 'project', // Indicate this is a project, not a regular post
        // Add user profile metadata
        'authorId': _profileController.studentProfile.value?.userId,
        'authorName': _profileController.studentProfile.value?.fullName,
        'authorProfileImage':
            _profileController.studentProfile.value?.profilePhotoUrl,
      }),
    );

    print('REQUEST TYPE: POST - Creating a new project');
    print('POST create project status: ${response.statusCode}');
    print('POST create project response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to create project: ${response.body}');
    }
  }

  // Convert UI visibility options to API-compatible values
  String _convertVisibilityToApiValue(String visibility) {
    switch (visibility) {
      case 'Public':
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
