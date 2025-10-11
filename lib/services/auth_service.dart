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

  // Login with email/phone and password
  Future<Map<String, dynamic>> login(
    String emailOrPhone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.token),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrPhone': emailOrPhone, 'password': password}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            return {
              'success': false,
              'message': 'Empty response received from server',
            };
          }
          final responseData = jsonDecode(response.body);
          // Save the token
          if (responseData != null) {
            final token =
                responseData is String ? responseData : responseData['token'];
            if (token != null) {
              await saveToken(token);
            }
          }

          return {
            'success': true,
            'message': 'Login successful',
            'token': responseData,
          };
        } catch (e) {
          print('Error parsing login response: $e');
          return {
            'success': false,
            'message': 'Failed to parse server response: $e',
          };
        }
      } else if (response.statusCode == 401) {
        // Handle email not verified case
        final responseData = response.body;
        if (responseData.contains('not confirmed your email')) {
          // Extract email from response if possible, or use the provided email/phone
          String email = emailOrPhone;
          try {
            final Map<String, dynamic> errorData = jsonDecode(responseData);
            if (errorData['email'] != null) {
              email = errorData['email'];
            }
          } catch (e) {
            // Use the provided email if parsing fails
            print(
              "Error parsing response for unverified email: ${e.toString()}",
            );
          }

          // Automatically send OTP for unverified account
          print("Sending OTP for unverified account: $email");
          final otpResponse = await resendOtp(email);
          print("OTP send response: $otpResponse");

          return {
            'success': false,
            'message': 'Email not verified',
            'needsVerification': true,
            'email': email,
          };
        } else {
          // General unauthorized case
          return {'success': false, 'message': 'Invalid credentials'};
        }
      } else {
        // Other errors
        return {'success': false, 'message': 'Login failed. Please try again.'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Get stored auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Check if token exists and if it's expired
    if (token != null) {
      if (isTokenExpired(token)) {
        print('Token is expired, clearing token');
        await clearToken();
        return null;
      }
    }

    return token;
  }

  // Check if token is expired
  bool isTokenExpired(String token) {
    try {
      // JWT tokens have 3 parts separated by dots
      final parts = token.split('.');
      if (parts.length != 3) {
        return true; // Not a valid JWT token format
      }

      // Decode the payload (second part)
      String normalizedPayload = parts[1]
          .replaceAll('-', '+')
          .replaceAll('_', '/');
      // Add padding if needed
      while (normalizedPayload.length % 4 != 0) {
        normalizedPayload += '=';
      }

      final payloadJson = utf8.decode(base64Url.decode(normalizedPayload));
      final payload = jsonDecode(payloadJson);

      // Check if 'exp' claim exists
      if (payload['exp'] != null) {
        // JWT exp is in seconds since epoch
        final expiry = DateTime.fromMillisecondsSinceEpoch(
          payload['exp'] * 1000,
        );
        final now = DateTime.now();

        print('Token expiry: $expiry');
        print('Current time: $now');

        return now.isAfter(expiry);
      }

      return true; // No expiry claim means we can't verify
    } catch (e) {
      print('Error checking token expiry: $e');
      return true; // On error, assume token is expired for safety
    }
  }

  // Clear stored auth token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Initiate account creation
  Future<Map<String, dynamic>> initiateSignup(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final requestBody = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };

    print('Initiate Signup Request URL: ${ApiConstants.initiateOnboarding}');
    print('Initiate Signup Request Body: ${jsonEncode(requestBody)}');

    // Try up to 3 times for 500 errors
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print('Attempt $attempt of 3');

        final response = await http.post(
          Uri.parse(ApiConstants.initiateOnboarding),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        print('Initiate Signup Response Status: ${response.statusCode}');
        print('Initiate Signup Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            if (response.body.isEmpty) {
              return {
                'success': false,
                'message': 'Empty response received from server',
              };
            }
            final responseData = jsonDecode(response.body);
            return {
              'success': true,
              'message': 'Account creation initiated successfully',
              'data': responseData,
            };
          } catch (e) {
            print('Error parsing initiate signup response: $e');
            return {
              'success': false,
              'message': 'Failed to parse server response: $e',
            };
          }
        } else if (response.statusCode == 500 && attempt < 3) {
          // Retry on 500 errors
          print('Server error on attempt $attempt, retrying...');
          await Future.delayed(
            Duration(seconds: attempt),
          ); // Exponential backoff
          continue;
        } else {
          try {
            if (response.body.isEmpty) {
              // Handle empty response with specific error messages based on status code
              String errorMessage;
              switch (response.statusCode) {
                case 500:
                  errorMessage =
                      'Server error - Please try a different email address or try again later';
                  break;
                case 404:
                  errorMessage = 'Service temporarily unavailable';
                  break;
                case 503:
                  errorMessage = 'Service temporarily unavailable';
                  break;
                default:
                  errorMessage =
                      'Failed to initiate account creation - Server error (${response.statusCode})';
              }
              return {'success': false, 'message': errorMessage};
            }
            final responseData = jsonDecode(response.body);
            return {
              'success': false,
              'message':
                  responseData['message'] ??
                  'Failed to initiate account creation',
              'errors': responseData['errors'],
            };
          } catch (e) {
            print('Error parsing error response: $e');
            return {
              'success': false,
              'message':
                  'Failed to initiate account creation - Invalid response format',
            };
          }
        }
      } catch (e) {
        if (attempt < 3) {
          print('Network error on attempt $attempt, retrying...');
          await Future.delayed(Duration(seconds: attempt));
          continue;
        }
        return {
          'success': false,
          'message': 'An error occurred: ${e.toString()}',
        };
      }
    }

    // If we get here, all retries failed
    return {
      'success': false,
      'message': 'Failed to initiate account creation after 3 attempts',
    };
  }

  // Complete account creation with OTP
  Future<Map<String, dynamic>> completeSignup(
    String email,
    String otpCode, [
    String? password,
  ]) async {
    try {
      final url = ApiConstants.completeOnboarding.replaceAll('{email}', email);

      final Map<String, dynamic> payload = {'otpCode': otpCode};

      // Add password only if provided
      if (password != null && password.isNotEmpty) {
        payload['password'] = password;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Complete Signup Response Status: ${response.statusCode}');
      print('Complete Signup Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            return {
              'success': false,
              'message': 'Empty response received from server',
            };
          }
          final responseData = jsonDecode(response.body);

          // If successful, save the token
          if (responseData['data'] != null &&
              responseData['data']['token'] != null) {
            await saveToken(responseData['data']['token']);
          }

          return {
            'success': true,
            'message': 'Account creation completed successfully',
            'data': responseData['data'],
          };
        } catch (e) {
          print('Error parsing complete signup response: $e');
          return {
            'success': false,
            'message': 'Failed to parse server response: $e',
          };
        }
      } else {
        try {
          if (response.body.isEmpty) {
            return {
              'success': false,
              'message': 'Failed to complete account creation - Empty response',
            };
          }
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message':
                responseData['message'] ??
                'Failed to complete account creation',
            'errors': responseData['errors'],
          };
        } catch (e) {
          print('Error parsing error response: $e');
          return {
            'success': false,
            'message':
                'Failed to complete account creation - Invalid response format',
          };
        }
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
        body: jsonEncode({'email': email, 'otpCode': otpCode}),
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
          'checkOnly':
              true, // This is a custom parameter that the backend might support
        }),
      );

      final responseData = jsonDecode(response.body);

      // If the response indicates the email already exists
      if (response.statusCode == 409 ||
          (responseData['message'] != null &&
              responseData['message'].toString().toLowerCase().contains(
                'already exists',
              ))) {
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
