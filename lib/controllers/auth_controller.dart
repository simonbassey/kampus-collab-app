import 'package:get/get.dart';
import 'dart:async';
import '../services/auth_service.dart';

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
    isAuthenticated.value = token != null && token.isNotEmpty;
  }
  
  // Initiate signup process
  Future<bool> initiateSignup(String fullName, String email, String password) async {
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
      
      // Split full name into first and last name
      final nameParts = fullName.trim().split(' ');
      String firstName = nameParts[0];
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      // Store email for OTP verification
      currentEmail.value = email;
      
      final result = await _authService.initiateSignup(firstName, lastName, email, password);
      
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
        errorMessage.value = 'Email not found. Please restart the signup process';
        return false;
      }
      
      final result = await _authService.completeSignup(currentEmail.value, otpCode, password);
      
      if (result['success']) {
        isAuthenticated.value = true;
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
        errorMessage.value = 'Email not found. Please restart the signup process';
        return false;
      }
      
      final result = await _authService.resendOtp(currentEmail.value);
      
      if (result['success']) {
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Failed to resend verification code';
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
    } catch (e) {
      errorMessage.value = 'Failed to logout: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Clear error message
  void clearError() {
    errorMessage.value = '';
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
