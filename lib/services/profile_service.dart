import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_profile_model.dart';
import '../services/api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  /// Fetch user profile by user ID
  /// Uses the GET /api/profile/{userId} endpoint
  Future<StudentProfileModel?> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get('/api/profile/$userId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Handle different response structures
        if (data.containsKey('data')) {
          // If response has a 'data' wrapper
          return StudentProfileModel.fromJson(data['data']);
        } else {
          // Direct response
          return StudentProfileModel.fromJson(data);
        }
      } else if (response.statusCode == 404) {
        throw Exception('User profile not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }
}