import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/app_pages.dart';
import 'bindings/app_binding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inkstryq',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.inter().fontFamily,
        // Using Inter as default font
        textTheme: TextTheme(
          // Display styles - Large (Monda)
          displayLarge: TextStyle(
            fontFamily: 'Monda',
            fontSize: 57,
            fontWeight: FontWeight.w700, // Bold
            letterSpacing: -0.25,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Monda',
            fontSize: 45,
            fontWeight: FontWeight.w700, // Bold
          ),
          displaySmall: TextStyle(
            fontFamily: 'Monda',
            fontSize: 36,
            fontWeight: FontWeight.w700, // Bold
          ),
          
          // Headline styles - Medium (Monda)
          headlineLarge: TextStyle(
            fontFamily: 'Monda',
            fontSize: 32,
            fontWeight: FontWeight.w700, // Bold
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Monda',
            fontSize: 28,
            fontWeight: FontWeight.w700, // Bold
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Monda',
            fontSize: 24,
            fontWeight: FontWeight.w700, // Bold
          ),
          
          // Title styles - Small (Monda)
          titleLarge: TextStyle(
            fontFamily: 'Monda',
            fontSize: 22,
            fontWeight: FontWeight.w500, // Medium (Regular)
          ),
          titleMedium: TextStyle(
            fontFamily: 'Monda',
            fontSize: 16,
            fontWeight: FontWeight.w500, // Medium (Regular)
            letterSpacing: 0.1,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Monda',
            fontSize: 14,
            fontWeight: FontWeight.w500, // Medium (Regular)
            letterSpacing: 0.1,
          ),
          
          // Body styles - Regular
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400, // Light
            letterSpacing: 0.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400, // Light
            letterSpacing: 0.25,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400, // Light
            letterSpacing: 0.4,
          ),
          
          // Label styles - All caps (Monda)
          labelLarge: TextStyle(
            fontFamily: 'Monda',
            fontSize: 14,
            fontWeight: FontWeight.w700, // Bold
            letterSpacing: 0.1,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Monda',
            fontSize: 12,
            fontWeight: FontWeight.w700, // Bold
            letterSpacing: 0.5,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Monda',
            fontSize: 11,
            fontWeight: FontWeight.w700, // Bold
            letterSpacing: 0.5,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF5796FF)),
        useMaterial3: true,
      ),
      initialBinding: AppBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}