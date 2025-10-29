import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/student_profile_controller.dart';
import '../../utils/error_message_helper.dart';
import '../../services/profile_image_upload_service.dart';
import '../../services/supabase_service.dart';
import '../../services/username_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final StudentProfileController _profileController =
      Get.find<StudentProfileController>();

  // Form controllers - matching API parameters
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _shortBioController = TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();
  final TextEditingController _academicEmailController =
      TextEditingController();

  // For profile picture and identity card
  File? _profileImage;
  File? _identityCardImage;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isFormChanged = false;

  // Check if required fields are filled
  bool get _isFormValid {
    return _shortBioController.text.trim().isNotEmpty &&
           _identityNumberController.text.trim().isNotEmpty;
  }

  // Username availability checking
  final UsernameService _usernameService = UsernameService();
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  List<String> _usernameSuggestions = [];
  String? _usernameError;
  Timer? _debounceTimer;
  String? _originalUsername;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadProfileData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _shortBioController.dispose();
    _identityNumberController.dispose();
    _academicEmailController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAndLoadProfileData() async {
    print('EditProfilePage: Fetching user profile data...');

    try {
      // Check if profile is already loaded (from preload service)
      if (_profileController.studentProfile.value != null) {
        print('EditProfilePage: Profile already loaded, using cached data');
        _loadProfileData();
        return;
      }

      // Fetch the latest profile data from the API
      print('EditProfilePage: No cached data, fetching from API...');
      await _profileController.fetchCurrentUserProfile();

      // Load the data into form fields
      if (mounted) {
        _loadProfileData();
      }
    } catch (e) {
      print('EditProfilePage: Error fetching profile: $e');
      // Still try to load any cached data
      if (mounted) {
        _loadProfileData();
      }
    }
  }

  void _loadProfileData() {
    final profile = _profileController.studentProfile.value;

    print('EditProfilePage: Loading profile data into form fields...');

    if (profile != null) {
      print('EditProfilePage: Profile found - ${profile.fullName}');

      _usernameController.text = profile.username ?? '';
      _originalUsername = profile.username; // Store original username
      _shortBioController.text = profile.shortBio ?? '';
      _identityNumberController.text =
          profile.identityNumber ??
          profile.academicDetails?.identityNumber ??
          '';
      _academicEmailController.text = profile.email;

      print(
        'EditProfilePage: Loaded - Username: "${profile.username}", Bio: "${profile.shortBio}", ID: "${_identityNumberController.text}", Email: "${profile.email}"',
      );
    } else {
      print('EditProfilePage: No profile data available');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _isFormChanged = true;
      });
    }
  }

  Future<void> _pickIdentityCard() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _identityCardImage = File(pickedFile.path);
        _isFormChanged = true;
      });
    }
  }

  void _onUsernameChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Reset states
    setState(() {
      _isUsernameAvailable = null;
      _usernameSuggestions.clear();
      _usernameError = null;
      _isFormChanged = true;
    });

    // Don't check if username is empty, too short, or same as original
    if (value.trim().isEmpty || 
        value.trim().length < 3 || 
        value.trim() == _originalUsername) {
      if (value.trim() == _originalUsername) {
        setState(() {
          _isUsernameAvailable = true; // Original username is always available
        });
      }
      return;
    }

    // Debounce the API call
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _checkUsernameAvailability(value.trim());
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty || username.length < 3 || username == _originalUsername) return;

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

  Future<void> _saveProfile() async {
    String? profilePhotoUrl;
    String? idCardUrl;
    final uploadService = ProfileImageUploadService();

    // Show loading indicator
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF5796FF),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  _profileImage != null || _identityCardImage != null
                      ? 'Uploading images...'
                      : 'Saving your profile...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Upload profile photo to Supabase if selected
      if (_profileImage != null) {
        if (!SupabaseService.isInitialized) {
          throw Exception('Supabase is not initialized');
        }

        print('EditProfilePage: Uploading profile photo to Supabase');
        profilePhotoUrl = await uploadService.uploadProfilePhoto(
          _profileImage!,
        );
        print('EditProfilePage: Profile photo URL: $profilePhotoUrl');
      }

      // Upload ID card to Supabase if selected
      if (_identityCardImage != null) {
        if (!SupabaseService.isInitialized) {
          throw Exception('Supabase is not initialized');
        }

        print('EditProfilePage: Uploading ID card to Supabase');
        idCardUrl = await uploadService.uploadIdCard(_identityCardImage!);
        print('EditProfilePage: ID card URL: $idCardUrl');
      }

      // Check if username has changed and update it separately if needed
      final currentProfile = _profileController.studentProfile.value;
      bool usernameChanged =
          currentProfile?.username != _usernameController.text.trim();
      bool usernameSuccess = true;

      if (usernameChanged && _usernameController.text.trim().isNotEmpty) {
        // Check if username is available before proceeding
        if (_isUsernameAvailable != true) {
          throw Exception('Please choose an available username');
        }

        print('Username changed, updating username...');
        final usernameService = UsernameService();

        try {
          final setUsernameResult = await usernameService.setUsername(
            _usernameController.text.trim(),
          );

          // Check if username was successfully set
          if (setUsernameResult['success'] != true) {
            // Username is no longer available, update suggestions
            final suggestions = List<String>.from(
              setUsernameResult['data']['suggestions'] ?? [],
            );
            setState(() {
              _isUsernameAvailable = false;
              _usernameSuggestions = suggestions;
            });
            throw Exception(
              setUsernameResult['message'] ?? 'Username is no longer available',
            );
          }

          usernameSuccess = true;
          print('Username update success: $usernameSuccess');
        } catch (e) {
          print('Username update failed: $e');
          usernameSuccess = false;
          throw e; // Re-throw to be caught by outer try-catch
        }
      }

      // Update other profile fields (excluding username)
      // Log the request payload for debugging
      final requestPayload = {
        'shortBio': _shortBioController.text,
        'identityNumber': _identityNumberController.text,
        'academicEmail': _academicEmailController.text,
        'profilePhotoUrl': profilePhotoUrl,
        'idCardUrl': idCardUrl,
      };
      print('API Request payload: $requestPayload');

      bool profileSuccess = await _profileController.updateProfileWithNewAPI(
        shortBio:
            _shortBioController.text.isNotEmpty
                ? _shortBioController.text
                : null,
        identityNumber:
            _identityNumberController.text.isNotEmpty
                ? _identityNumberController.text
                : null,
        academicEmail:
            _academicEmailController.text.isNotEmpty
                ? _academicEmailController.text
                : null,
        profileImageUrl: profilePhotoUrl,
        idCardUrl: idCardUrl,
      );

      bool success = usernameSuccess && profileSuccess;

      // If the update failed, show helpful error message
      if (!success &&
          _profileController.error.value.contains('Profile not found')) {
        print(
          'Profile not found - user needs to complete academic details first',
        );
      }

      // Log the result
      print('API Response success: $success');
      if (success) {
        // Log the updated profile data
        print(
          'Updated profile data: ${_profileController.studentProfile.value}',
        );
      } else {
        // Log the error
        print('API Error: ${_profileController.error.value}');
      }

      // Close loading indicator
      Get.back();

      // Show feedback
      if (success) {
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        _isFormChanged = false;

        // Return to profile page
        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });
      } else {
        // Clean error message before showing to user
        String cleanError = ErrorMessageHelper.getUserFriendlyMessage(
          _profileController.error.value,
        );

        // Check if it's the "profile not found" error - show dialog with option to go to academic details
        if (cleanError.contains('academic details')) {
          Get.dialog(
            AlertDialog(
              title: Text(
                'Academic Details Required',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              content: Text(
                'You need to set up your academic details before updating your profile. Would you like to do that now?',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                  },
                  child: Text(
                    'Later',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Close edit profile
                    Get.toNamed('/academic-details'); // Go to academic details
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5796FF),
                  ),
                  child: Text(
                    'Set Up Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          Get.snackbar(
            'Error',
            cleanError,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e, stackTrace) {
      // Log any exceptions
      print('Exception during profile update: $e');
      print('Stack trace: $stackTrace');

      // Close loading indicator
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Clean up uploaded images if profile update failed
      if (profilePhotoUrl != null || idCardUrl != null) {
        print('EditProfilePage: Cleaning up uploaded images due to error');
        try {
          if (profilePhotoUrl != null) {
            await uploadService.deleteImage(profilePhotoUrl);
          }
          if (idCardUrl != null) {
            await uploadService.deleteImage(idCardUrl);
          }
        } catch (cleanupError) {
          print('EditProfilePage: Error cleaning up images: $cleanupError');
        }
      }

      // Clean exception message before showing to user
      String cleanError = ErrorMessageHelper.cleanErrorMessage(e.toString());

      // Show error feedback
      Get.snackbar(
        'Error',
        cleanError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            if (_isFormChanged) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text(
                        'Discard Changes?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          fontSize: 18,
                          letterSpacing: -0.41,
                          color: Color(0xff333333),
                        ),
                      ),
                      content: const Text(
                        'You have unsaved changes. Are you sure you want to discard them?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          letterSpacing: -0.41,
                          color: Color(0xff333333),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              letterSpacing: -0.41,
                              color: Color(0xff333333),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Get.back();
                          },
                          child: const Text(
                            'Discard',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ),
                      ],
                    ),
              );
            } else {
              Get.back();
            }
          },
          child: Container(
            margin: const EdgeInsets.only(left: 16, bottom: 16),
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FF),
              borderRadius: BorderRadius.circular(1000),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xff5796FF),
            ),
          ),
        ),
        actions: [
          Obx(
            () =>
                _profileController.isSaving.value
                    ? Container(
                      padding: const EdgeInsets.only(right: 16),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF5796FF),
                          ),
                        ),
                      ),
                    )
                    : TextButton(
                      onPressed: (_isFormChanged && _isFormValid) ? _saveProfile : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            letterSpacing: -0.41,
                            color:
                                (_isFormChanged && _isFormValid)
                                    ? const Color(0xff333333)
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
      body: Obx(() {
        final profile = _profileController.studentProfile.value;

        // Show loading only if actually loading and no profile exists yet
        if (_profileController.isLoading.value && profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5796FF)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading profile...',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Profile not found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _fetchAndLoadProfileData();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo
                _buildProfileAvatar(profile),
                const SizedBox(height: 32),

                // Username with availability checking
                _buildUsernameField(),
                const SizedBox(height: 24),

                // Short Bio
                _buildFormField(
                  'Short Bio',
                  'Tell your friends about yourself',
                  _shortBioController,
                  maxLines: 3,
                  isRequired: true,
                ),
                const SizedBox(height: 24),

                // Identity Number
                _buildFormField(
                  'Identity Number',
                  'Your student ID number',
                  _identityNumberController,
                  isRequired: true,
                ),
                const SizedBox(height: 24),

                // Academic Email
                _buildFormField(
                  'Academic Email',
                  'your.email@university.edu',
                  _academicEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                // Identity Card Upload
                _buildIdentityCardUpload(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Username',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _usernameController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Your unique username',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            contentPadding: const EdgeInsets.only(bottom: 8, top: 4),
            suffixIcon: _isCheckingUsername
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF5796FF),
                        ),
                      ),
                    ),
                  )
                : _isUsernameAvailable == true
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      )
                    : _isUsernameAvailable == false
                        ? const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 20,
                          )
                        : null,
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: _isUsernameAvailable == true
                    ? Colors.green
                    : _isUsernameAvailable == false
                        ? Colors.red
                        : Colors.grey[300]!,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: _isUsernameAvailable == true
                    ? Colors.green
                    : _isUsernameAvailable == false
                        ? Colors.red
                        : Colors.grey[300]!,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: _isUsernameAvailable == true
                    ? Colors.green
                    : _isUsernameAvailable == false
                        ? Colors.red
                        : const Color(0xFF5796FF),
                width: 2,
              ),
            ),
            filled: false,
            isDense: true,
          ),
          onChanged: _onUsernameChanged,
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
                  ),
                ),
              ],
            ),
          ),

        if (_isUsernameAvailable == false && _usernameSuggestions.isNotEmpty)
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
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _usernameSuggestions.take(5).map((suggestion) {
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
                          color: const Color(0xFF5796FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF5796FF).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          suggestion,
                          style: TextStyle(
                            color: const Color(0xFF5796FF),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFormField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    Function(String)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            contentPadding:
                maxLines > 1
                    ? const EdgeInsets.symmetric(vertical: 8)
                    : const EdgeInsets.only(bottom: 8, top: 4),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5796FF), width: 2),
            ),
            filled: false,
            isDense: maxLines == 1,
          ),
          onChanged: (value) {
            setState(() => _isFormChanged = true);
            if (validator != null) {
              validator(value);
            }
          },
        ),
      ],
    );
  }

  // Helper to check if string is a URL
  bool _isUrl(String? str) {
    if (str == null) return false;
    return str.startsWith('http://') || str.startsWith('https://');
  }

  Widget _buildProfileAvatar(dynamic profile) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                image:
                    _profileImage != null
                        ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                        : profile?.profilePhotoUrl != null
                        ? DecorationImage(
                          image:
                              _isUrl(profile.profilePhotoUrl)
                                  ? NetworkImage(profile.profilePhotoUrl!)
                                      as ImageProvider
                                  : MemoryImage(
                                    _convertBase64ToImage(
                                      profile.profilePhotoUrl!,
                                    ),
                                  ),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  _profileImage == null && profile?.profilePhotoUrl == null
                      ? const Center(
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.black54,
                        ),
                      )
                      : null,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5796FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCardUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Identity Card',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickIdentityCard,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5796FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Choose File',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _identityCardImage != null
                            ? 'Identity card selected'
                            : 'No file selected',
                        style: TextStyle(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_identityCardImage != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _identityCardImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to convert base64 string to image bytes
  Uint8List _convertBase64ToImage(String base64String) {
    return base64Decode(base64String);
  }
}
