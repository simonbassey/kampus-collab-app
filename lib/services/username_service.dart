import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/api.dart';
import '../controllers/auth_controller.dart';

class UsernameService {
  final AuthController _authController = Get.find<AuthController>();



  /// Check if a username is available
  /// Returns a map with availability status and suggestions if not available
  Future<Map<String, dynamic>> checkUsernameAvailability(
    String username,
  ) async {
    try {
      // Check authentication
      if (!_authController.isAuthenticated.value) {
        throw Exception('User not authenticated. Please log in.');
      }

      final token = await _authController.getAuthToken();
      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/users/usernames/$username/check-availability',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Username availability check status: ${response.statusCode}');
      print('Username availability check response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else if (response.statusCode == 400) {
        // Username is invalid according to some conditions
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid username format');
      } else {
        throw Exception(
          'Failed to check username availability: ${response.body}',
        );
      }
    } catch (e) {
      print('Error checking username availability: $e');
      rethrow;
    }
  }

  /// Set username using the new endpoint
  Future<Map<String, dynamic>> setUsername(String username) async {
    try {
      // Check authentication
      if (!_authController.isAuthenticated.value) {
        throw Exception('User not authenticated. Please log in.');
      }

      final token = await _authController.getAuthToken();
      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/users/usernames/$username/set',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}), // Empty body as specified
      );

      print('Set username status: ${response.statusCode}');
      print('Set username response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to set username: ${response.body}');
      }
    } catch (e) {
      print('Error setting username: $e');
      rethrow;
    }
  }

  /// Update user profile with username
  Future<bool> updateProfileWithUsername({
    required String username,
    String? identityCardBase64,
    String? identityNumber,
    String? profilePhotoUrl,
    String? shortBio,
    String? academicEmail,
  }) async {
    try {
      // Check authentication
      if (!_authController.isAuthenticated.value) {
        throw Exception('User not authenticated. Please log in.');
      }

      final token = await _authController.getAuthToken();
      if (token == null) {
        throw Exception('User is not authenticated');
      }

      // Use provided identityNumber or empty string if not provided
      String finalIdentityNumber = identityNumber ?? '';

      // Build request payload - username is now supported by the API
      final Map<String, dynamic> payload = {
        'username': username, // API now accepts lowercase username
        'identityNumber': finalIdentityNumber, // Use provided value or empty string
      };

      // Add optional fields if provided (using proper API field names)
      if (identityCardBase64 != null)
        payload['identityCardBase64'] = identityCardBase64;
      if (profilePhotoUrl != null) payload['profilePhotoUrl'] = profilePhotoUrl;
      if (shortBio != null) payload['shortBio'] = shortBio;
      if (academicEmail != null) payload['academicEmail'] = academicEmail;

      print('Profile update payload: ${jsonEncode(payload)}');

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      print('Profile update with username status: ${response.statusCode}');
      print('Profile update with username response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to update profile with username',
        );
      }
    } catch (e) {
      print('Error updating profile with username: $e');
      rethrow;
    }
  }


}
