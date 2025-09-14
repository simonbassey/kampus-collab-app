import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/institution_model.dart';
import '../../models/program_model.dart';
import '../../services/academic_service.dart';
import '../onboarding/username_screen.dart';

class AcademicDetailsScreen extends StatefulWidget {
  const AcademicDetailsScreen({super.key});

  @override
  State<AcademicDetailsScreen> createState() => _AcademicDetailsScreenState();
}

class _AcademicDetailsScreenState extends State<AcademicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final AcademicService _academicService = AcademicService();

  // Selected values
  InstitutionModel? _selectedInstitution;
  ProgramModel? _selectedProgram;
  String? _selectedLevel;

  // State variables
  bool _isLoading = false;
  bool _isLoadingInstitutions = true;
  bool _isLoadingPrograms = false;
  String _error = '';

  // Data for dropdowns
  final RxList<InstitutionModel> _institutions = <InstitutionModel>[].obs;
  final RxList<ProgramModel> _programs = <ProgramModel>[].obs;

  final List<String> _levels = [
    '100 LEVEL',
    '200 LEVEL',
    '300 LEVEL',
    '400 LEVEL',
    '500 LEVEL',
  ];

  @override
  void initState() {
    super.initState();
    _fetchInstitutions();
  }

  Future<void> _fetchInstitutions() async {
    try {
      setState(() {
        _isLoadingInstitutions = true;
        _error = '';
      });

      final institutions = await _academicService.getInstitutions();

      _institutions.value = institutions;
    } catch (e) {
      setState(() {
        _error = 'Failed to load institutions: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingInstitutions = false;
      });
    }
  }

  Future<void> _fetchPrograms(int institutionId) async {
    try {
      setState(() {
        _isLoadingPrograms = true;
        _error = '';
        _selectedProgram = null;
      });

      final programs = await _academicService.getProgramsByInstitution(
        institutionId,
      );

      _programs.value = programs;
    } catch (e) {
      setState(() {
        _error = 'Failed to load programs: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingPrograms = false;
      });
    }
  }

  void _continueToUsername() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Store the selected values in Get storage to be used later
      if (_selectedInstitution != null &&
          _selectedProgram != null &&
          _selectedLevel != null) {
        // Pass the data as arguments to the username screen
        Get.to(
          () => const UsernameScreen(),
          arguments: {
            'institutionId': _selectedInstitution!.id,
            'programId': _selectedProgram!.id,
            'level': _selectedLevel,
          },
        );
      }

      // Reset loading state if the screen is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
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

                  // Error message (if any)
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _error,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

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
                      _isLoadingInstitutions
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<InstitutionModel>(
                            value: _selectedInstitution,
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
                            hint: Text(
                              'Select your institution',
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
                            validator: (value) {
                              if (value == null) {
                                return 'Please select your institution';
                              }
                              return null;
                            },
                            items:
                                _institutions.map((
                                  InstitutionModel institution,
                                ) {
                                  return DropdownMenuItem<InstitutionModel>(
                                    value: institution,
                                    child: Text(
                                      institution.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontSize: 16,
                                            fontFamily:
                                                GoogleFonts.inter().fontFamily,
                                          ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (InstitutionModel? newValue) {
                              setState(() {
                                _selectedInstitution = newValue;
                                if (newValue != null) {
                                  _fetchPrograms(newValue.id);
                                }
                              });
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
                  const SizedBox(height: 24.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Program/Course',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xFF414141),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      _isLoadingPrograms
                          ? Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<ProgramModel>(
                            value: _selectedProgram,
                            hint: Text(
                              _selectedInstitution == null
                                  ? 'Select an institution first'
                                  : 'Select your program',
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
                            items:
                                _programs.isEmpty &&
                                        _selectedInstitution != null
                                    ? [
                                      DropdownMenuItem<ProgramModel>(
                                        value: null,
                                        child: Text(
                                          'No programs available',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontSize: 16,
                                                fontFamily:
                                                    GoogleFonts.inter()
                                                        .fontFamily,
                                              ),
                                        ),
                                      ),
                                    ]
                                    : _programs.map((ProgramModel program) {
                                      return DropdownMenuItem<ProgramModel>(
                                        value: program,
                                        child: Text(
                                          program.name,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontSize: 16,
                                                fontFamily:
                                                    GoogleFonts.inter()
                                                        .fontFamily,
                                              ),
                                        ),
                                      );
                                    }).toList(),
                            onChanged:
                                _selectedInstitution == null
                                    ? null
                                    : (ProgramModel? newValue) {
                                      setState(() {
                                        _selectedProgram = newValue;
                                      });
                                    },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a program';
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
                        items:
                            _levels.map((String level) {
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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
