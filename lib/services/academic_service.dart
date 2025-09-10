import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/institution_model.dart';
import '../models/program_model.dart';
import '../constants/api.dart';
import '../controllers/auth_controller.dart';
import 'package:get/get.dart';

class AcademicService {
  final AuthController _authController = Get.find<AuthController>();
  
  // Base URL
  final String baseUrl = ApiConstants.baseUrl;
  
  // Get all institutions
  Future<List<InstitutionModel>> getInstitutions() async {
    try {
      final token = await _authController.getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/institutions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => InstitutionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load institutions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching institutions: $e');
    }
  }
  
  // Get programs for a specific institution
  Future<List<ProgramModel>> getProgramsByInstitution(int institutionId) async {
    try {
      final token = await _authController.getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/programs/institution/$institutionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProgramModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load programs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching programs: $e');
    }
  }
}
