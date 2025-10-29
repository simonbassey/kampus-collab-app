import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/student_profile_controller.dart';
import '../../services/username_service.dart';
import 'dart:async';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final StudentProfileController _profileController =
      Get.find<StudentProfileController>();
  final UsernameService _usernameService = UsernameService();

  bool _isLoading = false;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  List<String> _usernameSuggestions = [];
  String? _usernameError;
  Timer? _debounceTimer;

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
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Reset states
    setState(() {
      _isUsernameAvailable = null;
      _usernameSuggestions.clear();
      _usernameError = null;
    });

    // Don't check if username is too short or empty
    if (value.trim().isEmpty || value.trim().length < 3) {
      return;
    }

    // Debounce the API call
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _checkUsernameAvailability(value.trim());
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty || username.length < 3) return;

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      final result = await _usernameService.checkUsernameAvailability(username);

      if (mounted) {
        setState(() {
          _isUsernameAvailable = result['data']['isAvailable'] as bool;
          if (!_isUsernameAvailable!) {
            _usernameSuggestions = List<String>.from(
              result['data']['suggestions'] ?? [],
            );
          } else {
            _usernameSuggestions.clear();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUsernameAvailable = false;
          _usernameError = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
        });
      }
    }
  }

  void _continueToFeed() async {
    if (_formKey.currentState!.validate()) {
      // Check if username is available before proceeding
      if (_isUsernameAvailable != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose an available username')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final username = _usernameController.text.trim();

        // Set the username using the new endpoint
        final setUsernameResult = await _usernameService.setUsername(username);

        // Check if username was successfully set
        if (setUsernameResult['success'] != true) {
          // Username is no longer available, show suggestions
          final suggestions = List<String>.from(
            setUsernameResult['data']['suggestions'] ?? [],
          );

          setState(() {
            _isUsernameAvailable = false;
            _usernameSuggestions = suggestions;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                setUsernameResult['message'] ??
                    'Username is no longer available',
              ),
            ),
          );
          return;
        }

        // Get the year of study from the level string (e.g., "100 LEVEL" -> 1)
        final int yearOfStudy = int.parse(_level.split(' ')[0]) ~/ 100;

        // Update the academic details in the profile
        final academicUpdateSuccess = await _profileController
            .updateAcademicDetails(
              institutionId: _institutionId,
              departmentOrProgramId: _programId,
              facultyOrDisciplineId:
                  1, // Default faculty ID, could be fetched if available
              yearOfStudy: yearOfStudy,
            );

        if (academicUpdateSuccess) {
          // Navigate to feed route
          Get.offAllNamed(
            '/feed',
          ); // Using offAllNamed to clear the navigation stack
        } else {
          // Show error if update failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update academic details: ${_profileController.error.value}',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
          ),
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
                          suffixIcon:
                              _isCheckingUsername
                                  ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF5796FF),
                                            ),
                                      ),
                                    ),
                                  )
                                  : _isUsernameAvailable == true
                                  ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                  : _isUsernameAvailable == false
                                  ? const Icon(Icons.cancel, color: Colors.red)
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color:
                                  _isUsernameAvailable == true
                                      ? Colors.green
                                      : _isUsernameAvailable == false
                                      ? Colors.red
                                      : const Color(0xFFE8E8E8),
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color:
                                  _isUsernameAvailable == true
                                      ? Colors.green
                                      : _isUsernameAvailable == false
                                      ? Colors.red
                                      : const Color(0xFFE8E8E8),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color:
                                  _isUsernameAvailable == true
                                      ? Colors.green
                                      : _isUsernameAvailable == false
                                      ? Colors.red
                                      : const Color(0xFF5796FF),
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
                        onChanged: _onUsernameChanged,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          if (_usernameError != null) {
                            return _usernameError;
                          }
                          if (_isUsernameAvailable == false) {
                            return 'Username is not available';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ],
                  ),

                  // Username availability status
                  if (_isUsernameAvailable == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Username is available!',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_isUsernameAvailable == false &&
                      _usernameSuggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Username is not available',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Suggestions:',
                            style: TextStyle(
                              color: const Color(0xFF666666),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children:
                                _usernameSuggestions.take(5).map((suggestion) {
                                  return GestureDetector(
                                    onTap: () {
                                      _usernameController.text = suggestion;
                                      _onUsernameChanged(suggestion);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF5796FF,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF5796FF,
                                          ).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        suggestion,
                                        style: TextStyle(
                                          color: const Color(0xFF5796FF),
                                          fontSize: 13,
                                          fontFamily:
                                              GoogleFonts.inter().fontFamily,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 60.0),

                  // Continue Button
                  ElevatedButton(
                    onPressed:
                        (_isLoading ||
                                _isCheckingUsername ||
                                _isUsernameAvailable != true)
                            ? null
                            : _continueToFeed,
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
