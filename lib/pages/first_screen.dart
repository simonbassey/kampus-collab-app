import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 19.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Text(
                'INKSTRYQ',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontSize: 20
                ),
                textAlign: TextAlign.center,
              ),
            
               const Spacer(),

              SizedBox(
                width: 293,
                height: 188,
                child: Image.asset('assets/images/Group 13.png'),
              ),

              const SizedBox(height: 40.0),

              // Main Heading
              Text(
                'Unite. Collaborate. Grow',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16.0),
              
              // Description Text
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
                
              
              const Spacer(),
              
              // Sign Up Button
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/signup');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Color(0xFF5796FF),
                ),
                child: Text(
                  'Sign Up',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 16.0, 
                    fontWeight: FontWeight.w500, 
                    color: Colors.white,
                    // Using Inter for button text
                    fontFamily: GoogleFonts.inter().fontFamily,
                  ),
                ),
              ),
              
              const SizedBox(height: 16.0),
              
              // Login Text Button
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF4A4A4A),
                          // Inter is already the default for bodyMedium as per theme
                        ),
                      ),
                      TextSpan(
                        text: 'Log in',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Color(0xFF5796FF),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          // Inter is already the default for bodyMedium as per theme
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Get.toNamed('/login');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}