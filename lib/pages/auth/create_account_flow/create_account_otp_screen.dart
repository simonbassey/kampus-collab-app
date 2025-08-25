import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../controllers/auth_controller.dart';

class CreateAccountOtpScreen extends StatefulWidget {
  const CreateAccountOtpScreen({super.key});

  @override
  State<CreateAccountOtpScreen> createState() => _CreateAccountOtpScreenState();
}

class _CreateAccountOtpScreenState extends State<CreateAccountOtpScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final List<TextEditingController> _otpControllers = List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  
  String? _email;
  int _resendSeconds = 30;
  Timer? _timer;
  bool _isOtpValid = true;
  bool _isOtpCorrect = false;
  
  @override
  void initState() {
    super.initState();
    _startResendTimer();
    
    // Get email from arguments if available
    if (Get.arguments != null && Get.arguments['email'] != null) {
      _email = Get.arguments['email'];
    }
    
    // Set up focus node listeners for auto-advance
    for (int i = 0; i < 4; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _otpControllers[i].text.isNotEmpty) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
  
  void _startResendTimer() {
    _timer?.cancel();
    _resendSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  void _resendCode() async {
    if (_resendSeconds == 0) {
      final result = await _authController.resendOtp();
      if (result) {
        Get.snackbar(
          'Success',
          'OTP code has been resent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          'Error',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          margin: const EdgeInsets.all(16),
        );
      }
      _startResendTimer();
    }
  }
  
  void _verifyOtp() async {
    // Collect OTP digits
    final otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length == 5) {
      // Call the auth controller to complete signup with OTP
      final success = await _authController.completeSignup(otp);
      
      if (success) {
        setState(() {
          _isOtpValid = true;
          _isOtpCorrect = true;
        });
        
        // Show success message
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          margin: const EdgeInsets.all(16),
        );
        
        // Wait a moment to show the green borders before navigating
        Future.delayed(const Duration(milliseconds: 1000), () {
          // Navigate to success screen or home screen
          Get.offAllNamed('/academic-details');
        });
      } else {
        setState(() {
          _isOtpValid = false;
          _isOtpCorrect = false;
        });
        
        // Show error message
        Get.snackbar(
          'Error',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          margin: const EdgeInsets.all(16),
        );
        
        // Clear the fields after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            // Clear the fields for retry
            for (var controller in _otpControllers) {
              controller.clear();
            }
            // Reset validation state
            _isOtpValid = true;
            // Focus on first field again
            _focusNodes[0].requestFocus();
          });
        });
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Header with back button and logo
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Get.back(),
                    ),
                    const Spacer(),
                    Text(
                      'INKSTRYQ',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    // Empty space to balance the back button
                    const SizedBox(width: 48),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Title
                Text(
                  'Enter the code',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16.0),
                
                // Email info
                Text(
                  'A code was sent to ${_email ?? "your email"}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: const Color(0xFF4A4A4A),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48.0),
                
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Container(
                      width: 50,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: !_isOtpValid 
                              ? const Color.fromARGB(255, 245, 117, 117) 
                              : _isOtpCorrect 
                                  ? const Color(0xFF57C696) 
                                  : const Color(0xFFE8E8E8),
                          width: !_isOtpValid || _isOtpCorrect ? 2.0 : 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            // Auto-advance to next field
                            if (index < 4) {
                              _focusNodes[index + 1].requestFocus();
                            } else {
                              // Last field filled, verify OTP
                              _verifyOtp();
                            }
                          } else if (value.isEmpty && index > 0) {
                            // Handle backspace - go back to previous field
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 32.0),
                
                // Resend code timer/button
                Obx(() => GestureDetector(
                  onTap: (_resendSeconds > 0 || _authController.isResendingOtp.value) ? null : _resendCode,
                  child: _authController.isResendingOtp.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF5796FF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Resending...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5796FF),
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _resendSeconds > 0
                            ? 'Resend code in $_resendSeconds'
                            : 'Resend code',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _resendSeconds > 0
                              ? Colors.grey
                              : const Color(0xFF5796FF),
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                      ),
                )),
                
                const SizedBox(height: 40.0),
                
                // Verify Button
                Obx(() => ElevatedButton(
                  onPressed: _authController.isCompletingSignup.value ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5796FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _authController.isCompletingSignup.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                      ),
                )),
                
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
