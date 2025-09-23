import 'package:http/http.dart' as http;
import '../controllers/auth_controller.dart';
import '../utils/api_constants.dart';
import 'package:get/get.dart';

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;
  
  // Get the auth controller for token management
  AuthController? get _authController => 
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

  // Helper method to get auth headers
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token if available
    if (_authController != null) {
      final token = await _authController!.getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.get(url, headers: headers);
  }

  // POST request
  Future<http.Response> post(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.post(
      url,
      headers: headers,
      body: body,
    );
  }

  // PUT request
  Future<http.Response> put(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.put(
      url,
      headers: headers,
      body: body,
    );
  }

  // DELETE request
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.delete(url, headers: headers);
  }
}
