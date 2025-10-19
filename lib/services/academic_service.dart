import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/institution_model.dart';
import '../models/program_model.dart';
import '../models/faculty_model.dart';
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

      print('Fetching institutions from: $baseUrl/api/institutions');
      print('Auth token: ${token != null ? 'Present' : 'Not found'}');

      final response = await http.get(
        Uri.parse('$baseUrl/api/institutions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Institutions API Response Status: ${response.statusCode}');
      print('Institutions API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response received from server');
          }

          final dynamic responseData = json.decode(response.body);

          // Handle different response formats
          List<dynamic> institutionsData;

          if (responseData is List) {
            // Direct array format: [...]
            institutionsData = responseData;
          } else if (responseData is Map<String, dynamic>) {
            // Wrapped format: {"data": [...]} or {"institutions": [...]}
            if (responseData.containsKey('data')) {
              institutionsData = responseData['data'];
            } else if (responseData.containsKey('institutions')) {
              institutionsData = responseData['institutions'];
            } else if (responseData.containsKey('success') &&
                responseData.containsKey('data')) {
              institutionsData = responseData['data'];
            } else {
              // If it's a single institution object, wrap it in a list
              institutionsData = [responseData];
            }
          } else {
            throw Exception(
              'Unexpected response format: ${responseData.runtimeType}',
            );
          }

          // institutionsData is already guaranteed to be a List from the logic above

          return institutionsData
              .map((json) => InstitutionModel.fromJson(json))
              .toList();
        } catch (e) {
          print('Error parsing institutions response: $e');
          throw Exception('Failed to parse institutions response: $e');
        }
      } else {
        throw Exception('Failed to load institutions: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching institutions: $e');
      throw Exception('Error fetching institutions: $e');
    }
  }

  // Get faculties for a specific institution
  Future<List<FacultyModel>> getFacultiesByInstitution(
    int institutionId,
  ) async {
    try {
      final token = await _authController.getAuthToken();

      print(
        'Fetching faculties from: $baseUrl/api/institutions/$institutionId/faculties',
      );
      print('Auth token: ${token != null ? 'Present' : 'Not found'}');

      final response = await http.get(
        Uri.parse('$baseUrl/api/institutions/$institutionId/faculties'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Faculties API Response Status: ${response.statusCode}');
      print('Faculties API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response received from server');
          }

          final dynamic responseData = json.decode(response.body);

          // Handle different response formats
          List<dynamic> facultiesData;

          if (responseData is List) {
            facultiesData = responseData;
          } else if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data')) {
              facultiesData = responseData['data'];
            } else if (responseData.containsKey('faculties')) {
              facultiesData = responseData['faculties'];
            } else {
              facultiesData = [responseData];
            }
          } else {
            throw Exception(
              'Unexpected response format: ${responseData.runtimeType}',
            );
          }

          return facultiesData
              .map((json) => FacultyModel.fromJson(json))
              .toList();
        } catch (e) {
          print('Error parsing faculties response: $e');
          throw Exception('Failed to parse faculties response: $e');
        }
      } else {
        throw Exception('Failed to load faculties: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching faculties: $e');
      throw Exception('Error fetching faculties: $e');
    }
  }

  // Get programs for a specific institution and faculty
  Future<List<ProgramModel>> getProgramsByInstitutionAndFaculty(
    int institutionId,
    int facultyId,
  ) async {
    try {
      final token = await _authController.getAuthToken();

      print(
        'Fetching programs from: $baseUrl/api/programs/programs/institution/$institutionId/faculty/$facultyId',
      );
      print('Auth token: ${token != null ? 'Present' : 'Not found'}');

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/programs/programs/institution/$institutionId/faculty/$facultyId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Programs API Response Status: ${response.statusCode}');
      print('Programs API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response received from server');
          }

          final dynamic responseData = json.decode(response.body);

          // Handle different response formats
          List<dynamic> programsData;

          if (responseData is List) {
            programsData = responseData;
          } else if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data')) {
              programsData = responseData['data'];
            } else if (responseData.containsKey('programs')) {
              programsData = responseData['programs'];
            } else {
              programsData = [responseData];
            }
          } else {
            throw Exception(
              'Unexpected response format: ${responseData.runtimeType}',
            );
          }

          return programsData
              .map((json) => ProgramModel.fromJson(json))
              .toList();
        } catch (e) {
          print('Error parsing programs response: $e');
          throw Exception('Failed to parse programs response: $e');
        }
      } else {
        throw Exception('Failed to load programs: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching programs: $e');
      throw Exception('Error fetching programs: $e');
    }
  }

  // Get programs for a specific institution (backward compatibility)
  Future<List<ProgramModel>> getProgramsByInstitution(int institutionId) async {
    try {
      final token = await _authController.getAuthToken();

      print(
        'Fetching programs from: $baseUrl/api/programs/institution/$institutionId',
      );
      print('Auth token: ${token != null ? 'Present' : 'Not found'}');

      final response = await http.get(
        Uri.parse('$baseUrl/api/programs/institution/$institutionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Programs API Response Status: ${response.statusCode}');
      print('Programs API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response received from server');
          }

          final dynamic responseData = json.decode(response.body);

          // Handle different response formats
          List<dynamic> programsData;

          if (responseData is List) {
            // Direct array format: [...]
            programsData = responseData;
          } else if (responseData is Map<String, dynamic>) {
            // Wrapped format: {"data": [...]} or {"programs": [...]}
            if (responseData.containsKey('data')) {
              programsData = responseData['data'];
            } else if (responseData.containsKey('programs')) {
              programsData = responseData['programs'];
            } else if (responseData.containsKey('success') &&
                responseData.containsKey('data')) {
              programsData = responseData['data'];
            } else {
              // If it's a single program object, wrap it in a list
              programsData = [responseData];
            }
          } else {
            throw Exception(
              'Unexpected response format: ${responseData.runtimeType}',
            );
          }

          // programsData is already guaranteed to be a List from the logic above

          return programsData
              .map((json) => ProgramModel.fromJson(json))
              .toList();
        } catch (e) {
          print('Error parsing programs response: $e');
          throw Exception('Failed to parse programs response: $e');
        }
      } else {
        throw Exception('Failed to load programs: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching programs: $e');
      throw Exception('Error fetching programs: $e');
    }
  }

  // Create a new institution
  Future<InstitutionModel> createInstitution(
    String name,
    String domain,
    String collegeType,
  ) async {
    try {
      final token = await _authController.getAuthToken();

      print(
        'Creating institution: $name (Domain: $domain, Type: $collegeType)',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/api/institutions/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'domain': domain,
          'collegeType': collegeType,
        }),
      );

      print('Create Institution Response Status: ${response.statusCode}');
      print('Create Institution Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Handle different response formats
        if (responseData is Map && responseData.containsKey('data')) {
          return InstitutionModel.fromJson(responseData['data']);
        } else {
          return InstitutionModel.fromJson(responseData);
        }
      } else {
        throw Exception('Failed to create institution: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception creating institution: $e');
      throw Exception('Error creating institution: $e');
    }
  }

  // Create a new faculty/discipline for an institution
  Future<Map<String, dynamic>> createFaculty(
    int institutionId,
    String facultyName,
    String campus,
    String location,
  ) async {
    try {
      final token = await _authController.getAuthToken();

      print('Creating faculty: $facultyName for institution $institutionId');

      final response = await http.post(
        Uri.parse('$baseUrl/api/institutions/$institutionId/faculties/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': facultyName,
          'campus': campus,
          'location': location,
          'institutionId': institutionId,
        }),
      );

      print('Create Faculty Response Status: ${response.statusCode}');
      print('Create Faculty Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Handle different response formats
        if (responseData is Map && responseData.containsKey('data')) {
          return responseData['data'];
        } else {
          return responseData;
        }
      } else {
        throw Exception('Failed to create faculty: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception creating faculty: $e');
      throw Exception('Error creating faculty: $e');
    }
  }

  // Create a new program
  Future<ProgramModel> createProgram(
    int institutionId,
    int facultyId,
    String programName,
    String durationYears,
  ) async {
    try {
      final token = await _authController.getAuthToken();

      print('Creating program: $programName (Duration: $durationYears years)');

      final requestBody = {
        'Name': programName,
        'InstitutionId': institutionId,
        'FacultyId': facultyId,
        'Duration': durationYears,
      };

      print('Create Program Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/programs/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Create Program Response Status: ${response.statusCode}');
      print('Create Program Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Handle different response formats
        if (responseData is Map && responseData.containsKey('data')) {
          return ProgramModel.fromJson(responseData['data']);
        } else {
          return ProgramModel.fromJson(responseData);
        }
      } else {
        throw Exception('Failed to create program: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception creating program: $e');
      throw Exception('Error creating program: $e');
    }
  }
}
