import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _passwordVisible = false;
  bool _hasMinLength = false;
  bool _hasUpperAndLowerCase = false;
  bool _hasNumberOrSpecialChar = false;
  bool _notContainsEmail = true;
  bool _notCommonlyUsed = true;
  
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  void _validatePassword() {
    final password = _passwordController.text;
    final email = _emailController.text.toLowerCase();
    
    setState(() {
      // Check for minimum length
      _hasMinLength = password.length >= 8;
      
      // Check for uppercase and lowercase letters
      _hasUpperAndLowerCase = password.contains(RegExp(r'[a-z]')) && 
                              password.contains(RegExp(r'[A-Z]'));
      
      // Check for at least one number or special character
      _hasNumberOrSpecialChar = password.contains(RegExp(r'[0-9]')) || 
                               password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
      
      // Check if password contains email
      _notContainsEmail = email.isEmpty || 
                         !password.toLowerCase().contains(email.split('@')[0].toLowerCase());
      
      // This would normally check against a database of common passwords
      // For now, we'll just check if it's not too simple
      _notCommonlyUsed = !['password', '123456', 'qwerty', 'admin'].contains(password.toLowerCase());
    });
  }
  
  void _signUp() async {
    if (_formKey.currentState!.validate() &&
        _hasMinLength &&
        _hasUpperAndLowerCase &&
        _hasNumberOrSpecialChar &&
        _notContainsEmail &&
        _notCommonlyUsed) {
      
      // Call the auth controller to initiate signup
      final success = await _authController.initiateSignup(
        _nameController.text,
        _emailController.text,
        _passwordController.text
      );
      
      if (success) {
        // Navigate to account creation OTP verification
        Get.toNamed('/create-account-otp', arguments: {'email': _emailController.text});
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          margin: const EdgeInsets.all(16),
        );
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // Logo
                  Center(
                    child: Text(
                      'INKSTRYQ',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Create Account Title
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Sign up with Email text
                  Text(
                    'Sign up with Email',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF4A4A4A),
                      fontFamily: GoogleFonts.inter().fontFamily,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Already have an account
                  Row(
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed('/login'),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5796FF),
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Full Name Field
                  Text(
                    'Full name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      fontFamily: GoogleFonts.inter().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF5796FF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email Field
                  Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      fontFamily: GoogleFonts.inter().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF5796FF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (_) => _validatePassword(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password Field
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      fontFamily: GoogleFonts.inter().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      hintText: 'Create a password',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF5796FF)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password Requirements
                  Text(
                    'Create a password that:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      fontFamily: GoogleFonts.inter().fontFamily,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Password Requirements List
                  PasswordRequirement(
                    text: 'Contains at least 8 characters',
                    isMet: _hasMinLength,
                  ),
                  PasswordRequirement(
                    text: 'Contains both lower and uppercase letter (A-Z)',
                    isMet: _hasUpperAndLowerCase,
                  ),
                  PasswordRequirement(
                    text: 'Contains at least one number (0-9),or a character',
                    isMet: _hasNumberOrSpecialChar,
                  ),
                  PasswordRequirement(
                    text: 'Does not contain your Email address',
                    isMet: _notContainsEmail,
                  ),
                  PasswordRequirement(
                    text: 'Is not commonly used',
                    isMet: _notCommonlyUsed,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign Up Button
                  Obx(() => ElevatedButton(
                    onPressed: _authController.isInitiatingSignup.value ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5796FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _authController.isInitiatingSignup.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
                  )),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;
  
  const PasswordRequirement({
    super.key,
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? const Color(0xFF57C696) : const Color(0xFFFF5757),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF4A4A4A),
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}