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
    print('Fetching profiles from: ${ApiConstants.getAllStudentProfiles}');

    try {
      // Get the auth token
      final token = await getAuthToken();
      print('Auth token: ${token != null ? 'Present' : 'Not found'}');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      print('Request headers: $headers');

      final response = await http.get(
        Uri.parse(ApiConstants.getAllStudentProfiles),
        headers: headers,
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<dynamic> profilesJson = jsonDecode(response.body);
          print('Parsed ${profilesJson.length} profiles from response');
          return profilesJson
              .map((json) => StudentProfileModel.fromJson(json))
              .toList();
        } else {
          print('Response body is empty even though status code is 200');
          return [];
        }
      } else {
        print(
          'Failed to load profiles with status code: ${response.statusCode}',
        );
        throw Exception('Failed to load profiles: ${response.body}');
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

    final response = await http.put(
      Uri.parse('$baseUrl/api/StudentProfiles/update/$id'),
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

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse(ApiConstants.updateAcademicProfile),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return StudentProfileModel.fromJson(jsonDecode(response.body));
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
