import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api.dart';

class AuthService {
  // Store auth token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get stored auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Clear stored auth token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Initiate account creation
  Future<Map<String, dynamic>> initiateSignup(String firstName, String lastName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.initiateOnboarding),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Account creation initiated successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to initiate account creation',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Complete account creation with OTP
  Future<Map<String, dynamic>> completeSignup(String email, String otpCode, [String? password]) async {
    try {
      final url = ApiConstants.completeOnboarding.replaceAll('{email}', email);
      
      final Map<String, dynamic> payload = {
        'otpCode': otpCode,
      };
      
      // Add password only if provided
      if (password != null && password.isNotEmpty) {
        payload['password'] = password;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // If successful, save the token
        if (responseData['data'] != null && responseData['data']['token'] != null) {
          await saveToken(responseData['data']['token']);
        }
        
        return {
          'success': true,
          'message': 'Account creation completed successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to complete account creation',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final url = ApiConstants.resendOtp.replaceAll('{recipientEmail}', email);
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP resent successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to resend OTP',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otpCode': otpCode,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP verified successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to verify OTP',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
  
  // Check if email is already registered
  Future<Map<String, dynamic>> checkEmailExists(String email) async {
    try {
      // Assuming the API has an endpoint to check if email exists
      // If not, we can use the initiateOnboarding endpoint and check the response
      final response = await http.post(
        Uri.parse(ApiConstants.initiateOnboarding),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'checkOnly': true, // This is a custom parameter that the backend might support
        }),
      );

      final responseData = jsonDecode(response.body);
      
      // If the response indicates the email already exists
      if (response.statusCode == 409 || 
          (responseData['message'] != null && 
           responseData['message'].toString().toLowerCase().contains('already exists'))) {
        return {
          'success': false,
          'exists': true,
          'message': 'Email is already registered',
        };
      } else if (response.statusCode == 200 || response.statusCode == 404) {
        // Email doesn't exist or is available
        return {
          'success': true,
          'exists': false,
          'message': 'Email is available',
        };
      } else {
        // Some other error
        return {
          'success': false,
          'exists': false,
          'message': responseData['message'] ?? 'Failed to check email',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'exists': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
}
