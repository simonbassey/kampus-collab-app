import 'package:get/get.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/data_preload_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentEmail = ''.obs;
  final RxBool isInitiatingSignup = false.obs;
  final RxBool isCompletingSignup = false.obs;
  final RxBool isResendingOtp = false.obs;
  final RxBool isLoggingIn = false.obs;

  // Timer for auto-checking auth status
  Timer? _authCheckTimer;

  // Check if user is authenticated on app start
  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();

    // Set up periodic auth check
    _authCheckTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      checkAuthStatus();
    });
  }

  @override
  void onClose() {
    _authCheckTimer?.cancel();
    super.onClose();
  }

  // Check if user has a valid token
  Future<void> checkAuthStatus() async {
    final token = await _authService.getToken();
    final wasAuthenticated = isAuthenticated.value;
    isAuthenticated.value = token != null && token.isNotEmpty;

    // If user is authenticated and this is first check, preload data
    if (isAuthenticated.value && !wasAuthenticated) {
      print(
        'AuthController: User authenticated on startup, preloading data...',
      );
      DataPreloadService.preloadEssentialData()
          .then((_) {
            print('AuthController: Startup data preload completed');
          })
          .catchError((e) {
            print('AuthController: Startup data preload error: $e');
          });
    }
  }

  // Initiate signup process
  Future<bool> initiateSignup(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      isLoading.value = true;
      isInitiatingSignup.value = true;
      errorMessage.value = '';

      // Validate inputs
      if (fullName.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
        errorMessage.value = 'Please fill in all required fields';
        return false;
      }

      // Basic email validation
      if (!GetUtils.isEmail(email)) {
        errorMessage.value = 'Please enter a valid email address';
        return false;
      }

      // Additional validation for known problematic patterns
      if (email.contains('arqsis.com') ||
          email.contains('temp-mail.org') ||
          email.contains('10minutemail')) {
        errorMessage.value =
            'This email domain is not supported. Please use a different email address.';
        return false;
      }

      // Split full name into first and last name
      final nameParts = fullName.trim().split(' ');

      if (nameParts.length < 2) {
        errorMessage.value = 'Please enter both first and last name';
        return false;
      }

      String firstName = nameParts[0];
      String lastName = nameParts.sublist(1).join(' ');

      // Store email for OTP verification
      currentEmail.value = email;

      final result = await _authService.initiateSignup(
        firstName,
        lastName,
        email,
        password,
      );

      if (result['success']) {
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Failed to initiate signup';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
      isInitiatingSignup.value = false;
    }
  }

  // Complete signup with OTP
  Future<bool> completeSignup(String otpCode, [String? password]) async {
    try {
      isLoading.value = true;
      isCompletingSignup.value = true;
      errorMessage.value = '';

      // Validate OTP
      if (otpCode.trim().isEmpty) {
        errorMessage.value = 'Please enter the verification code';
        return false;
      }

      // Validate email
      if (currentEmail.value.isEmpty) {
        errorMessage.value =
            'Email not found. Please restart the signup process';
        return false;
      }

      final result = await _authService.completeSignup(
        currentEmail.value,
        otpCode,
        password,
      );

      if (result['success']) {
        isAuthenticated.value = true;

        // Preload essential data in the background after signup
        print('AuthController: Signup completed, starting data preload...');
        DataPreloadService.preloadEssentialData()
            .then((_) {
              print('AuthController: Background data preload completed');
            })
            .catchError((e) {
              print('AuthController: Background data preload error: $e');
            });

        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Failed to verify OTP';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
      isCompletingSignup.value = false;
    }
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    try {
      isLoading.value = true;
      isResendingOtp.value = true;
      errorMessage.value = '';

      // Validate email
      if (currentEmail.value.isEmpty) {
        errorMessage.value =
            'Email not found. Please restart the signup process';
        return false;
      }

      final result = await _authService.resendOtp(currentEmail.value);

      if (result['success']) {
        return true;
      } else {
        errorMessage.value =
            result['message'] ?? 'Failed to resend verification code';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
      isResendingOtp.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.clearToken();
      isAuthenticated.value = false;
      currentEmail.value = '';
      errorMessage.value = '';

      // Navigate to login page and clear all previous routes
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = 'Failed to logout: ${e.toString()}';
      // Even if logout fails, still navigate to login
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Get authentication token
  Future<String?> getAuthToken() async {
    return await _authService.getToken();
  }

  // Login with email/phone and password
  Future<Map<String, dynamic>> login(
    String emailOrPhone,
    String password,
  ) async {
    try {
      isLoggingIn.value = true;
      errorMessage.value = '';

      // Validate inputs
      if (emailOrPhone.trim().isEmpty || password.isEmpty) {
        errorMessage.value = 'Email and password are required';
        return {'success': false};
      }

      final result = await _authService.login(emailOrPhone, password);

      if (result['success']) {
        isAuthenticated.value = true;

        // Preload essential data in the background (don't await to avoid blocking UI)
        print('AuthController: Login successful, starting data preload...');
        DataPreloadService.preloadEssentialData()
            .then((_) {
              print('AuthController: Background data preload completed');
            })
            .catchError((e) {
              print('AuthController: Background data preload error: $e');
            });

        return {'success': true};
      } else if (result['needsVerification'] == true) {
        // Email not verified, store the email for the verification flow
        currentEmail.value = result['email'];
        errorMessage.value = result['message'];
        return {
          'success': false,
          'needsVerification': true,
          'email': result['email'],
        };
      } else {
        errorMessage.value = result['message'];
        return {'success': false};
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      return {'success': false};
    } finally {
      isLoggingIn.value = false;
    }
  }

  // Check if email already exists
  Future<bool> checkEmailExists(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Basic email validation
      if (!GetUtils.isEmail(email)) {
        errorMessage.value = 'Please enter a valid email address';
        return false;
      }

      final result = await _authService.checkEmailExists(email);

      if (result['exists'] == true) {
        errorMessage.value = 'This email is already registered';
        return true; // Email exists
      } else if (result['success']) {
        return false; // Email doesn't exist
      } else {
        errorMessage.value = result['message'] ?? 'Failed to check email';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
