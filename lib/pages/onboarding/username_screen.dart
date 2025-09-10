import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/student_profile_controller.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final StudentProfileController _profileController = Get.find<StudentProfileController>();
  bool _isLoading = false;
  
  // Academic details passed from previous screen
  late final int _institutionId;
  late final int _programId;
  late final String _level;

  @override
  void initState() {
    super.initState();
    // Get the arguments passed from the AcademicDetailsScreen
    final Map<String, dynamic>? args = Get.arguments;
    if (args != null) {
      _institutionId = args['institutionId'] as int;
      _programId = args['programId'] as int;
      _level = args['level'] as String;
    } else {
      // Fallback values in case no args are provided (shouldn't happen in normal flow)
      _institutionId = 1;
      _programId = 1;
      _level = '100 LEVEL';
    }
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _continueToFeed() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Get the year of study from the level string (e.g., "100 LEVEL" -> 1)
        final int yearOfStudy = int.parse(_level.split(' ')[0]) ~/ 100;
        
        // Update the academic details in the profile
        final success = await _profileController.updateAcademicDetails(
          institutionId: _institutionId,
          departmentOrProgramId: _programId,
          facultyOrDisciplineId: 1, // Default faculty ID, could be fetched if available
          yearOfStudy: yearOfStudy,
        );
        
        if (success) {
          // Navigate to feed route
          Get.offAllNamed('/feed'); // Using offAllNamed to clear the navigation stack
        } else {
          // Show error if update failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update academic details: ${_profileController.error.value}'))
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'))
        );
      } finally {
        // Reset loading state if the screen is still mounted
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 19.0,
            ),
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
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40.0),

                  // Username Title
                  Text(
                    'Username',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      color: Color(0xFF161515),
                    ),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 32.0),

                  // Username Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xFF414141),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Choose a unique username',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          // You can add more validation rules here
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ],
                  ),

                  const SizedBox(height: 60.0),

                  // Continue Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _continueToFeed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color(0xFF5796FF),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              'Continue',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontFamily: GoogleFonts.inter().fontFamily,
                              ),
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
