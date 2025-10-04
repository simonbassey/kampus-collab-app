import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api.dart';
import '../models/student_profile_model.dart';

class StudentProfileService {
  final String baseUrl = ApiConstants.baseUrl;

  // Helper method to get the auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Update profile using the new /api/profile/me endpoint
  Future<StudentProfileModel> updateUserProfile(Map<String, dynamic> profileData) async {
    print('Updating profile with data: $profileData');

    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      // First, check if the profile exists by making a GET request
      final getApiUrl = '${ApiConstants.baseUrl}/api/profile/me';
      print('Checking if profile exists: $getApiUrl');
      
      print('REQUEST TYPE: GET - Checking if profile exists');
      final getResponse = await http.get(
        Uri.parse(getApiUrl),
        headers: headers,
      );
      
      print('GET Profile Response Status Code: ${getResponse.statusCode}');
      print('GET Profile Response Body: ${getResponse.body}');
      
      if (getResponse.statusCode != 200) {
        print('Warning: Profile may not exist yet - GET returned ${getResponse.statusCode}');
      } else {
        final profileJson = jsonDecode(getResponse.body);
        print('Current profile data: ${profileJson['data']}');
      }
      
      // Only use the known working endpoint
      print('Using the correct profile endpoint: /api/profile/me');
      
      // No need to test multiple endpoints anymore
      
      // Now proceed with the update
      final putApiUrl = '${ApiConstants.baseUrl}/api/profile/me';
      print('Using update API URL: $putApiUrl');
      print('Update headers: $headers');
      print('Update body: ${jsonEncode(profileData)}');

      print('REQUEST TYPE: PUT - Updating profile with provided data');
      final response = await http.put(
        Uri.parse(putApiUrl),
        headers: headers,
        body: jsonEncode(profileData),
      );

      print('Update API Response Status Code: ${response.statusCode}');
      print('Update API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            return StudentProfileModel.fromJson(jsonResponse['data']);
          } else {
            // Handle success:false case
            throw Exception('API returned success:false - ${jsonResponse['message']}');
          }
        } else {
          throw Exception('Empty response received from server');
        }
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('Exception updating profile: $e');
      rethrow;
    }
  }

  // Get a student profile by ID
  Future<StudentProfileModel> getProfileById(int id) async {
    // Get the auth token
    final token = await getAuthToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/StudentProfiles/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return StudentProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  // Get all student profiles - legacy method
  Future<List<StudentProfileModel>> getAllProfiles() async {
    // Use the known working endpoint instead of legacy endpoint
    // Note: This doesn't actually return all profiles, but we're adapting to the available API
    final workingUrl = '${ApiConstants.baseUrl}/api/profile/me';
    print('Fetching profile from: $workingUrl');

    try {
      // Get the auth token
      final token = await getAuthToken();
      print('Auth token: ${token != null ? 'Present' : 'Not found'}');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      print('Request headers: $headers');

      print('REQUEST TYPE: GET - Fetching profile');
      final response = await http.get(
        Uri.parse(workingUrl),
        headers: headers,
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final profileJson = jsonResponse['data'];
            print('Successfully fetched profile for: ${profileJson['email'] ?? 'unknown'}');
            // Return as a list containing just the current user's profile
            return [StudentProfileModel.fromJson(profileJson)];
          } else {
            print('API response format unexpected: ${response.body}');
            return [];
          }
        } else {
          print('Response body is empty even though status code is 200');
          return [];
        }
      } else {
        print('Failed to load profile with status code: ${response.statusCode}');
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
      print('Exception during API call: $e');
      rethrow;
    }
  }

  // Get the current user's profile using the new endpoint
  Future<StudentProfileModel> getCurrentUserProfile() async {
    print(
      'Fetching current user profile from: ${ApiConstants.getCurrentUserProfile}',
    );

    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('REQUEST TYPE: GET - Fetching current user profile');
      final response = await http.get(
        Uri.parse(ApiConstants.getCurrentUserProfile),
        headers: headers,
      );

      print('API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return StudentProfileModel.fromJson(
            jsonDecode(response.body)['data'],
          );
        } else {
          throw Exception('Empty response received from server');
        }
      } else {
        throw Exception(
          'Failed to load current user profile: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception fetching current user profile: $e');
      rethrow;
    }
  }

  // Get a user's public profile by userId
  Future<StudentProfileModel> getUserProfileById(String userId) async {
    final endpoint = ApiConstants.getUserProfileById.replaceAll(
      '{userId}',
      userId,
    );
    print('Fetching user profile from: $endpoint');

    try {
      final token = await getAuthToken();

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      print('Request headers: $token');

      final response = await http.get(Uri.parse(endpoint), headers: headers);

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return StudentProfileModel.fromJson(jsonDecode(response.body));
        } else {
          throw Exception('Empty response received from server');
        }
      } else {
        throw Exception('Failed to load user profile: ${response.body}');
      }
    } catch (e) {
      print('Exception fetching user profile: $e');
      rethrow;
    }
  }

  // Update a student profile
  Future<StudentProfileModel> updateProfile(
    String id,
    StudentProfileModel profile,
  ) async {
    // Get the auth token
    final token = await getAuthToken();

    print('REQUEST TYPE: PUT - Updating profile using legacy endpoint (not recommended)');
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/StudentProfiles/update/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profile.toUpdateJson()),
    );

    if (response.statusCode == 200) {
      return StudentProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  // Delete a student profile
  Future<bool> deleteProfile(String id) async {
    // Get the auth token
    final token = await getAuthToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/StudentProfiles/delete/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete profile: ${response.body}');
    }
  }

  // Update academic profile details (institution, course, year of study)
  Future<StudentProfileModel> updateAcademicProfile({
    required int institutionId,
    required int departmentOrProgramId,
    required int facultyOrDisciplineId,
    required int yearOfStudy,
  }) async {
    print(
      'Updating academic profile with data: institutionId=$institutionId, programId=$departmentOrProgramId, facultyId=$facultyOrDisciplineId, yearOfStudy=$yearOfStudy',
    );

    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final Map<String, dynamic> requestBody = {
        'institutionId': institutionId,
        'departmentOrProgramId': departmentOrProgramId,
        'facultyOrDisciplineId': facultyOrDisciplineId,
        'yearOfStudy': yearOfStudy,
      };
      
      print('REQUEST TYPE: PUT - Updating academic profile');
      final response = await http.put(
        Uri.parse(ApiConstants.updateAcademicProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      print('Academic profile update response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            return StudentProfileModel.fromJson(jsonResponse['data']);
          } else {
            throw Exception('API returned success:false - ${jsonResponse['message']}');
          }
        } else {
          throw Exception('Empty response received from server');
        }
      } else {
        throw Exception('Failed to update academic profile: ${response.body}');
      }
    } catch (e) {
      print('Exception updating academic profile: $e');
      rethrow;
    }
  }
}
