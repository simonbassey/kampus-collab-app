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

  // Create a student profile
  Future<StudentProfileModel> createProfile(StudentProfileModel profile) async {
    // Get the auth token
    final token = await getAuthToken();
    
    try {
      print('Creating profile with data: ${jsonEncode(profile.toJson())}');
      
      // Wrap the profile data in a 'dto' field as required by the API
      final Map<String, dynamic> requestBody = {
        'dto': profile.toJson()
      };
      
      print('Request body: ${jsonEncode(requestBody)}');
      
      // Use the API constant instead of hardcoded URL
      final response = await http.post(
        Uri.parse(ApiConstants.createStudentProfile),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      // Try different content types if server 500 error persists
      if (response.statusCode == 500) {
        print('Trying with different Content-Type header...');
        final retryResponse = await http.post(
          Uri.parse(ApiConstants.createStudentProfile),
          headers: {
            'Content-Type': 'application/json-patch+json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        );
        
        if (retryResponse.statusCode != 500) {
          print('Alternative Content-Type successful with status: ${retryResponse.statusCode}');
          return StudentProfileModel.fromJson(jsonDecode(retryResponse.body));
        }
      }

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Headers: ${response.headers}');
      print('API Raw Response Body: "${response.body}"');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          return StudentProfileModel.fromJson(jsonDecode(response.body));
        } else {
          // Handle empty response
          throw Exception('Server returned empty response with status code ${response.statusCode}');
        }
      } else {
        throw Exception('Failed to create profile: ${response.body}');
      }
    } catch (e) {
      print('Exception during profile creation: $e');
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

  // Get all student profiles
  Future<List<StudentProfileModel>> getAllProfiles() async {
    print('Fetching profiles from: $baseUrl/api/StudentProfiles/all');
    
    try {
      // Get the auth token
      final token = await getAuthToken();
      print('Auth token: ${token != null ? 'Present' : 'Not found'}');
      if (token != null) {
        print('Token value: $token');
      }
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      print('Request headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/StudentProfiles/all'),
        headers: headers,
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Headers: ${response.headers}');
      print('API Raw Response Body: "${response.body}"');

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
        print('Failed to load profiles with status code: ${response.statusCode}');
        throw Exception('Failed to load profiles: ${response.body}');
      }
    } catch (e) {
      print('Exception during API call: $e');
      rethrow;
    }
  }

  // Update a student profile
  Future<StudentProfileModel> updateProfile(
    int id,
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
  Future<bool> deleteProfile(int id) async {
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
}
