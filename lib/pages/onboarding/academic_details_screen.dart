import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/institution_model.dart';
import '../../models/program_model.dart';
import '../../models/faculty_model.dart';
import '../../services/academic_service.dart';
import '../onboarding/username_screen.dart';
import '../../utils/error_message_helper.dart';

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
  FacultyModel? _selectedFaculty;
  ProgramModel? _selectedProgram;
  String? _selectedLevel;

  // State variables
  bool _isLoading = false;
  bool _isLoadingInstitutions = true;
  bool _isLoadingFaculties = false;
  bool _isLoadingPrograms = false;
  bool _isCreatingInstitution = false;
  bool _isCreatingProgram = false;
  String _error = '';

  // Text controllers for custom inputs
  final TextEditingController _customInstitutionController =
      TextEditingController();
  final TextEditingController _customDomainController = TextEditingController();
  final TextEditingController _customCollegeTypeController =
      TextEditingController(text: 'University'); // Default
  final TextEditingController _customFacultyController =
      TextEditingController();
  final TextEditingController _customCampusController = TextEditingController();
  final TextEditingController _customLocationController =
      TextEditingController();
  final TextEditingController _customProgramController =
      TextEditingController();
  final TextEditingController _customDurationController = TextEditingController(
    text: '4',
  ); // Default to 4 years

  // Data for dropdowns
  final RxList<InstitutionModel> _institutions = <InstitutionModel>[].obs;
  final RxList<FacultyModel> _faculties = <FacultyModel>[].obs;
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

  @override
  void dispose() {
    _customInstitutionController.dispose();
    _customDomainController.dispose();
    _customCollegeTypeController.dispose();
    _customFacultyController.dispose();
    _customCampusController.dispose();
    _customLocationController.dispose();
    _customProgramController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  Future<void> _fetchInstitutions() async {
    try {
      setState(() {
        _isLoadingInstitutions = true;
        _error = '';
      });

      final institutions = await _academicService.getInstitutions();

      print(
        'AcademicDetailsScreen: Received ${institutions.length} institutions from API',
      );

      setState(() {
        // Remove duplicates and ensure unique institutions
        final uniqueInstitutions = <int, InstitutionModel>{};
        for (final institution in institutions) {
          print(
            'AcademicDetailsScreen: Adding institution - ID: ${institution.id}, Name: ${institution.name}',
          );
          uniqueInstitutions[institution.id] = institution;
        }
        _institutions.value = uniqueInstitutions.values.toList();

        print(
          'AcademicDetailsScreen: After deduplication, have ${_institutions.length} unique institutions',
        );

        // Clear selected institution if it's no longer valid
        if (_selectedInstitution != null) {
          final isValid = _institutions.any(
            (inst) => inst.id == _selectedInstitution!.id,
          );
          if (!isValid) {
            _selectedInstitution = null;
            _selectedFaculty = null;
            _selectedProgram = null;
            _faculties.clear();
            _programs.clear();
          }
        }
      });
    } catch (e) {
      setState(() {
        _error = ErrorMessageHelper.cleanErrorMessage(
          'Failed to load institutions: ${e.toString()}',
        );
      });
      print('AcademicDetailsScreen: Error fetching institutions: $e');
    } finally {
      setState(() {
        _isLoadingInstitutions = false;
      });
    }
  }

  Future<void> _fetchFaculties(int institutionId) async {
    try {
      setState(() {
        _isLoadingFaculties = true;
        _error = '';
        _selectedFaculty = null;
        _selectedProgram = null;
        _programs.clear();
      });

      final faculties = await _academicService.getFacultiesByInstitution(
        institutionId,
      );

      print(
        'AcademicDetailsScreen: Received ${faculties.length} faculties from API',
      );

      setState(() {
        // Remove duplicates and ensure unique faculties
        final uniqueFaculties = <int, FacultyModel>{};
        for (final faculty in faculties) {
          uniqueFaculties[faculty.id] = faculty;
        }
        _faculties.value = uniqueFaculties.values.toList();

        print(
          'AcademicDetailsScreen: After deduplication, have ${_faculties.length} unique faculties',
        );
      });
    } catch (e) {
      setState(() {
        _error = ErrorMessageHelper.cleanErrorMessage(
          'Failed to load faculties: ${e.toString()}',
        );
      });
      print('AcademicDetailsScreen: Error fetching faculties: $e');
    } finally {
      setState(() {
        _isLoadingFaculties = false;
      });
    }
  }

  Future<void> _fetchPrograms(int institutionId, int facultyId) async {
    try {
      setState(() {
        _isLoadingPrograms = true;
        _error = '';
        _selectedProgram = null;
      });

      final programs = await _academicService
          .getProgramsByInstitutionAndFaculty(institutionId, facultyId);

      print(
        'AcademicDetailsScreen: Received ${programs.length} programs from API',
      );

      setState(() {
        // Remove duplicates and ensure unique programs
        final uniquePrograms = <int, ProgramModel>{};
        for (final program in programs) {
          uniquePrograms[program.id] = program;
        }
        _programs.value = uniquePrograms.values.toList();

        print(
          'AcademicDetailsScreen: After deduplication, have ${_programs.length} unique programs',
        );
      });
    } catch (e) {
      setState(() {
        _error = ErrorMessageHelper.cleanErrorMessage(
          'Failed to load programs: ${e.toString()}',
        );
      });
      print('AcademicDetailsScreen: Error fetching programs: $e');
    } finally {
      setState(() {
        _isLoadingPrograms = false;
      });
    }
  }

  Future<InstitutionModel?> _createCustomInstitution() async {
    if (_customInstitutionController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter an institution name');
      return null;
    }

    setState(() {
      _isCreatingInstitution = true;
      _error = '';
    });

    try {
      final newInstitution = await _academicService.createInstitution(
        _customInstitutionController.text.trim(),
        _customDomainController.text.trim(),
        _customCollegeTypeController.text.trim(),
      );

      // Add to the list
      setState(() {
        _institutions.add(newInstitution);
        _selectedInstitution = newInstitution;
        _customInstitutionController.clear();
        _customDomainController.clear();
        _customCollegeTypeController.text = 'University';
      });

      // Fetch faculties for the new institution
      await _fetchFaculties(newInstitution.id);

      return newInstitution;
    } catch (e) {
      setState(
        () => _error = ErrorMessageHelper.cleanErrorMessage(e.toString()),
      );
      return null;
    } finally {
      setState(() => _isCreatingInstitution = false);
    }
  }

  Future<ProgramModel?> _createCustomProgram() async {
    if (_customProgramController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a program name');
      return null;
    }

    if (_customFacultyController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a faculty name');
      return null;
    }

    if (_selectedInstitution == null) {
      setState(() => _error = 'Please select an institution first');
      return null;
    }

    setState(() {
      _isCreatingProgram = true;
      _error = '';
    });

    try {
      // First create the faculty (auto-populate campus and location with defaults)
      final facultyData = await _academicService.createFaculty(
        _selectedInstitution!.id,
        _customFacultyController.text.trim(),
        _customCampusController.text.trim().isNotEmpty
            ? _customCampusController.text.trim()
            : 'Main Campus',
        _customLocationController.text.trim().isNotEmpty
            ? _customLocationController.text.trim()
            : 'N/A',
      );

      final facultyId = facultyData['id'] as int;
      final facultyName = facultyData['name'] as String;

      // Create a FacultyModel and add it to the list
      final newFaculty = FacultyModel(
        id: facultyId,
        name: facultyName,
        institutionId: _selectedInstitution!.id,
      );

      // Get duration as string (API expects string)
      String duration = _customDurationController.text.trim();
      if (duration.isEmpty) {
        duration = '4'; // Default to 4 if empty
      }

      // Then create the program
      final newProgram = await _academicService.createProgram(
        _selectedInstitution!.id,
        facultyId,
        _customProgramController.text.trim(),
        duration,
      );

      // Add faculty and program to the lists
      setState(() {
        _faculties.add(newFaculty);
        _selectedFaculty = newFaculty;
        _programs.add(newProgram);
        _selectedProgram = newProgram;
        _customProgramController.clear();
        _customFacultyController.clear();
        _customCampusController.clear();
        _customLocationController.clear();
        _customDurationController.text = '4';
      });

      return newProgram;
    } catch (e) {
      setState(
        () => _error = ErrorMessageHelper.cleanErrorMessage(e.toString()),
      );
      return null;
    } finally {
      setState(() {
        _isCreatingProgram = false;
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
          _selectedFaculty != null &&
          _selectedProgram != null &&
          _selectedLevel != null) {
        // Pass the data as arguments to the username screen
        Get.to(
          () => const UsernameScreen(),
          arguments: {
            'institutionId': _selectedInstitution!.id,
            'facultyId': _selectedFaculty!.id,
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

  void _showAddInstitutionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width:
                  MediaQuery.of(context).size.width *
                  0.85, // 85% of screen width
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Institution',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      color: Color(0xFF161515),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _customInstitutionController,
                    decoration: InputDecoration(
                      labelText: 'Institution Name',
                      labelStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      hintText: 'e.g., University of Lagos',
                      hintStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF5796FF),
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 16,
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _customDomainController,
                    decoration: InputDecoration(
                      labelText: 'Domain',
                      labelStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      hintText: 'e.g., unilag.edu.ng',
                      hintStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF5796FF),
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _customCollegeTypeController,
                    decoration: InputDecoration(
                      labelText: 'College Type',
                      labelStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      hintText: 'e.g., University, Polytechnic, College',
                      hintStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF5796FF),
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _customInstitutionController.clear();
                          _customDomainController.clear();
                          _customCollegeTypeController.text = 'University';
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: GoogleFonts.inter().fontFamily,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _createCustomInstitution();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5796FF),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isCreatingInstitution
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: GoogleFonts.inter().fontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showAddFacultyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Faculty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      color: Color(0xFF161515),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _customFacultyController,
                    decoration: InputDecoration(
                      labelText: 'Faculty Name',
                      labelStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      hintText: 'e.g., Faculty of Science',
                      hintStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF5796FF),
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 16,
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _customCampusController,
                    decoration: InputDecoration(
                      labelText: 'Campus',
                      labelStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      hintText: 'e.g., Main Campus',
                      hintStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF5796FF),
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _customLocationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      hintText: 'e.g., Lagos, Nigeria',
                      hintStyle: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Color(0xFF5796FF),
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _customFacultyController.clear();
                          _customCampusController.clear();
                          _customLocationController.clear();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: GoogleFonts.inter().fontFamily,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (_customFacultyController.text.trim().isEmpty) {
                            setState(
                              () => _error = 'Please enter a faculty name',
                            );
                            Navigator.pop(context);
                            return;
                          }

                          if (_selectedInstitution == null) {
                            setState(
                              () =>
                                  _error = 'Please select an institution first',
                            );
                            Navigator.pop(context);
                            return;
                          }

                          Navigator.pop(context);

                          setState(() => _isLoading = true);

                          try {
                            final facultyData = await _academicService
                                .createFaculty(
                                  _selectedInstitution!.id,
                                  _customFacultyController.text.trim(),
                                  _customCampusController.text.trim().isNotEmpty
                                      ? _customCampusController.text.trim()
                                      : 'Main Campus',
                                  _customLocationController.text
                                          .trim()
                                          .isNotEmpty
                                      ? _customLocationController.text.trim()
                                      : 'N/A',
                                );

                            final newFaculty = FacultyModel(
                              id: facultyData['id'] as int,
                              name: facultyData['name'] as String,
                              institutionId: _selectedInstitution!.id,
                            );

                            setState(() {
                              _faculties.add(newFaculty);
                              _selectedFaculty = newFaculty;
                              _customFacultyController.clear();
                              _customCampusController.clear();
                              _customLocationController.clear();
                              _error = '';
                            });
                          } catch (e) {
                            setState(
                              () =>
                                  _error = ErrorMessageHelper.cleanErrorMessage(
                                    e.toString(),
                                  ),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5796FF),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.inter().fontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showAddProgramDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width:
                  MediaQuery.of(context).size.width *
                  0.85, // 85% of screen width
              padding: EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Program',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        color: Color(0xFF161515),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _customFacultyController,
                      decoration: InputDecoration(
                        labelText: 'Faculty Name',
                        labelStyle: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: 14,
                        ),
                        hintText: 'e.g., Faculty of Science',
                        hintStyle: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF5796FF),
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 16,
                      ),
                      autofocus: true,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _customProgramController,
                      decoration: InputDecoration(
                        labelText: 'Program Name',
                        labelStyle: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: 14,
                        ),
                        hintText: 'e.g., Computer Science',
                        hintStyle: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF5796FF),
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _customDurationController,
                      decoration: InputDecoration(
                        labelText: 'Duration (Years)',
                        labelStyle: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: 14,
                        ),
                        hintText: 'e.g., 4',
                        hintStyle: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF5796FF),
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 16,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _customFacultyController.clear();
                            _customCampusController.clear();
                            _customLocationController.clear();
                            _customProgramController.clear();
                            _customDurationController.text =
                                '4'; // Reset to default
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: GoogleFonts.inter().fontFamily,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _createCustomProgram();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5796FF),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isCreatingProgram
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    'Add',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily:
                                          GoogleFonts.inter().fontFamily,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Institution',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: Color(0xFF414141),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddInstitutionDialog(),
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: Color(0xFF5796FF),
                            ),
                            label: Text(
                              'Add New',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5796FF),
                                fontFamily: GoogleFonts.inter().fontFamily,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      _isLoadingInstitutions
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<InstitutionModel>(
                            value:
                                _selectedInstitution != null &&
                                        _institutions.any(
                                          (inst) =>
                                              inst.id ==
                                              _selectedInstitution!.id,
                                        )
                                    ? _selectedInstitution
                                    : null,
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
                                _institutions.isEmpty
                                    ? []
                                    : _institutions.map((
                                      InstitutionModel institution,
                                    ) {
                                      return DropdownMenuItem<InstitutionModel>(
                                        key: ValueKey(institution.id),
                                        value: institution,
                                        child: Text(
                                          institution.name,
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
                            onChanged: (InstitutionModel? newValue) {
                              setState(() {
                                _selectedInstitution = newValue;
                                _selectedFaculty = null;
                                _selectedProgram = null;
                                _faculties.clear();
                                _programs.clear();
                                if (newValue != null) {
                                  _fetchFaculties(newValue.id);
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

                  // Faculty Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Faculty',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: Color(0xFF414141),
                            ),
                          ),
                          if (_selectedInstitution != null)
                            TextButton.icon(
                              onPressed: () => _showAddFacultyDialog(),
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: 16,
                                color: Color(0xFF5796FF),
                              ),
                              label: Text(
                                'Add New',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5796FF),
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      _isLoadingFaculties
                          ? Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<FacultyModel>(
                            value:
                                _selectedFaculty != null &&
                                        _faculties.any(
                                          (fac) =>
                                              fac.id == _selectedFaculty!.id,
                                        )
                                    ? _selectedFaculty
                                    : null,
                            hint: Text(
                              _selectedInstitution == null
                                  ? 'Select an institution first'
                                  : 'Select your faculty',
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
                                _faculties.isEmpty &&
                                        _selectedInstitution != null
                                    ? [
                                      DropdownMenuItem<FacultyModel>(
                                        value: null,
                                        child: Text(
                                          'No faculties available',
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
                                    : _faculties.map((FacultyModel faculty) {
                                      return DropdownMenuItem<FacultyModel>(
                                        key: ValueKey(faculty.id),
                                        value: faculty,
                                        child: Text(
                                          faculty.name,
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
                                    : (FacultyModel? newValue) {
                                      setState(() {
                                        _selectedFaculty = newValue;
                                        _selectedProgram = null;
                                        _programs.clear();
                                        if (newValue != null &&
                                            _selectedInstitution != null) {
                                          _fetchPrograms(
                                            _selectedInstitution!.id,
                                            newValue.id,
                                          );
                                        }
                                      });
                                    },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a faculty';
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Program/Course',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: Color(0xFF414141),
                            ),
                          ),
                          if (_selectedInstitution != null)
                            TextButton.icon(
                              onPressed: () => _showAddProgramDialog(),
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: 16,
                                color: Color(0xFF5796FF),
                              ),
                              label: Text(
                                'Add New',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5796FF),
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      _isLoadingPrograms
                          ? Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<ProgramModel>(
                            value:
                                _selectedProgram != null &&
                                        _programs.any(
                                          (prog) =>
                                              prog.id == _selectedProgram!.id,
                                        )
                                    ? _selectedProgram
                                    : null,
                            hint: Text(
                              _selectedFaculty == null
                                  ? 'Select a faculty first'
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
                                        key: ValueKey(program.id),
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
                                _selectedFaculty == null
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
