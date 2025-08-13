import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../onboarding/username_screen.dart';

class AcademicDetailsScreen extends StatefulWidget {
  const AcademicDetailsScreen({super.key});

  @override
  State<AcademicDetailsScreen> createState() => _AcademicDetailsScreenState();
}

class _AcademicDetailsScreenState extends State<AcademicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedInstitution;
  String? _selectedCourse;
  String? _selectedLevel;
  bool _isLoading = false;
  
  // Sample data for dropdowns
  final List<String> _institutions = [
    'University Of Calabar',
    'University of Lagos',
    'University of Ibadan',
    'Federal University of Technology, Akure',
  ];
  
  final List<String> _courses = [
    'Food Engineering',
    'Computer Science',
    'Electrical Engineering',
    'Medicine',
    'Business Administration',
  ];
  
  final List<String> _levels = [
    '100 LEVEL',
    '200 LEVEL',
    '300 LEVEL',
    '400 LEVEL',
    '500 LEVEL',
  ];

  void _continueToUsername() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate a short delay before navigation
      Future.delayed(const Duration(milliseconds: 800), () {
        // Navigate to username screen
        Get.to(() => const UsernameScreen());
        
        // Reset loading state if the screen is still mounted
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 19.0),
            child: Form(
              key: _formKey,
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
                  
                  const SizedBox(height: 40.0),
                  
                  // Academic Details Title
                  Text(
                    'Academic Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      color: Color(0xFF161515),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  
                  const SizedBox(height: 32.0),
                  
                  // Institution Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Institution',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xFF414141),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        value: _selectedInstitution,
                        hint: Text(
                          'E.g, University Of Calabar',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF5796FF),
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                        items: _institutions.map((String institution) {
                          return DropdownMenuItem<String>(
                            value: institution,
                            child: Text(institution),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedInstitution = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an institution';
                          }
                          return null;
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF414141),
                        ),
                        isExpanded: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24.0),
                  
                  // Course Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xFF414141),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        value: _selectedCourse,
                        hint: Text(
                          'Food Engineering',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF5796FF),
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                        items: _courses.map((String course) {
                          return DropdownMenuItem<String>(
                            value: course,
                            child: Text(course),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCourse = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a course';
                          }
                          return null;
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF414141),
                        ),
                        isExpanded: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24.0),
                  
                  // Level Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xFF414141),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        hint: Text(
                          '200 LEVEL',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF5796FF),
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                        items: _levels.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLevel = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a level';
                          }
                          return null;
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF414141),
                        ),
                        isExpanded: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60.0),
                  
                  // Continue Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _continueToUsername,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color(0xFF5796FF),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                        ),
                        if (_isLoading) ...[  
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}