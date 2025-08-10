import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Logo
              Text(
                'INKSTRYQ',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              
             const Spacer(),
             
              
              // User circles image
              SizedBox(
                width: 293,
                height: 188,
                child: Image.asset('assets/images/Group 13.png'),
              ),
              
              const SizedBox(height: 40),
              
              // Tagline
              Text(
              'Unite. Collaborate. Grow',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
              
              const SizedBox(height: 16),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                'Connect with like-minded professionals, collaborate on projects, and grow your network in the creative industry.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Color(0xFF4A4A4A),
                  height: 1.5,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  // Inter is already the default for bodyMedium as per theme
                ),
                textAlign: TextAlign.center,
                              ),
              ),
              
              // const SizedBox(height: 40),
               const Spacer(),
              
              // Google Sign-in Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement Google sign-in
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color(0xFFD2D2D2)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/google_icon.png',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Email Sign-in Button
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/create-account');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD2D2D2).withValues(alpha: 0.3),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Color(0xFFD2D2D2)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 24,
                      color: Color(0xFF333333),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Already have an account link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}