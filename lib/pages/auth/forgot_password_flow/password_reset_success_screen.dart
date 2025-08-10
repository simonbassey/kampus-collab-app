import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

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
              
              // Success Icon
              Container(
                width: 83.33333587646484,
                height: 83.33333587646484,
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  color: const Color(0xFF5796FF),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 51,
                  weight: 51.66041564941406,
                ),
              ),
              
              const SizedBox(height: 24.0),
              
              // Success Message
              Text(
                'Success',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  fontFamily: GoogleFonts.inter().fontFamily,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16.0),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'You have successfully changed your password',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
             const SizedBox(height: 24.0),
              
              // Back to Login Button
              TextButton(
                onPressed: () => Get.offAllNamed('/login'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                child: Text(
                  'Back to Login',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5796FF),
                    fontFamily: GoogleFonts.inter().fontFamily,
                  ),
                ),
              ),
              
              const Spacer(flex: 2)
            ],
          ),
        ),
      ),
    );
  }
}
