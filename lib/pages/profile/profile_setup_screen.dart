import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/student_profile_controller.dart';
import '../../utils/error_message_helper.dart';
import '../../services/profile_image_upload_service.dart';
import '../../services/supabase_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _shortBioController = TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();
  final TextEditingController _academicEmailController =
      TextEditingController();

  // Get the StudentProfileController
  final StudentProfileController _profileController = Get.put(
    StudentProfileController(),
  );

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Selected profile image file
  File? _profileImageFile;

  // Selected identity card file
  File? _identityCardFile;
  String? _identityCardFilePath;

  // Loading state
  RxBool isLoading = false.obs;
  RxBool isFetchingProfile = false.obs;
  RxBool isSuccess = false.obs;

  // Form change tracking
  bool _isFormChanged = false;

  @override
  void initState() {
    super.initState();
    // Fetch current profile data when the screen initializes
    _fetchCurrentProfileData();
  }

  // Fetch the current user's profile data
  Future<void> _fetchCurrentProfileData() async {
    isFetchingProfile.value = true;
    try {
      // Check if profile is already loaded (from preload service)
      if (_profileController.studentProfile.value != null) {
        print('ProfileSetupScreen: Profile already loaded, using cached data');
        _populateFormWithProfileData();
        isFetchingProfile.value = false;
        return;
      }

      // Fetch from API if not cached
      print('ProfileSetupScreen: No cached data, fetching from API...');
      await _profileController.fetchCurrentUserProfile();

      // If profile was successfully fetched, populate the form
      if (_profileController.studentProfile.value != null) {
        _populateFormWithProfileData();
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      // Don't show error snackbar - just log it
      print('ProfileSetupScreen: Will use empty form');
    } finally {
      isFetchingProfile.value = false;
    }
  }

  // Populate form fields with existing profile data
  void _populateFormWithProfileData() {
    final profile = _profileController.studentProfile.value;

    if (profile == null) {
      print('ProfileSetupScreen: No profile to populate');
      return;
    }

    print('ProfileSetupScreen: Populating form with profile data...');

    // Set the text controllers with existing data
    if (profile.shortBio?.isNotEmpty == true) {
      _shortBioController.text = profile.shortBio!;
      print('ProfileSetupScreen: Loaded bio: ${profile.shortBio}');
    }

    // Load identity number from either direct field or academic details
    final identityNumber =
        profile.identityNumber ?? profile.academicDetails?.identityNumber;
    if (identityNumber?.isNotEmpty == true) {
      _identityNumberController.text = identityNumber!;
      print('ProfileSetupScreen: Loaded identity number: $identityNumber');
    }

    // Load email
    if (profile.email.isNotEmpty) {
      _academicEmailController.text = profile.email;
      print('ProfileSetupScreen: Loaded email: ${profile.email}');
    }

    print('ProfileSetupScreen: Form population complete');

    // Note: For profile image and identity card, we cannot set File objects directly.
    // We would need to store the paths or URLs and display them, but we won't
    // modify the actual File objects until the user selects new files.
  }

  @override
  void dispose() {
    _shortBioController.dispose();
    _identityNumberController.dispose();
    _academicEmailController.dispose();
    super.dispose();
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
                _profileController.isSaving.value || isLoading.value
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
                      onPressed: _saveProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            letterSpacing: -0.41,
                            color: Color(0xff333333),
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileAvatar(),
              const SizedBox(height: 32),
              _buildTextField(
                label: 'Short Bio',
                controller: _shortBioController,
                placeholder: 'Tell your friends about yourself',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Identity Number',
                controller: _identityNumberController,
                placeholder: 'Your student ID number',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Academic Email',
                controller: _academicEmailController,
                placeholder: 'your.email@university.edu',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              _buildIdentityCardUpload(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to check if string is a URL
  bool _isUrl(String? str) {
    if (str == null) return false;
    return str.startsWith('http://') || str.startsWith('https://');
  }

  Widget _buildProfileAvatar() {
    final profile = _profileController.studentProfile.value;
    
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showProfileImagePicker,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                image:
                    _profileImageFile != null
                        ? DecorationImage(
                          image: FileImage(_profileImageFile!),
                          fit: BoxFit.cover,
                        )
                        : profile?.profilePhotoUrl != null
                        ? DecorationImage(
                          image: _isUrl(profile!.profilePhotoUrl)
                              ? NetworkImage(profile.profilePhotoUrl!) as ImageProvider
                              : MemoryImage(
                                  _convertBase64ToImage(profile.profilePhotoUrl!),
                                ),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  _profileImageFile == null && profile?.profilePhotoUrl == null
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
              onTap: _showProfileImagePicker,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: placeholder,
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
            // Remove box shadow and background
            filled: false,
            isDense: maxLines == 1,
          ),
          onChanged: (value) {
            setState(() => _isFormChanged = true);
          },
        ),
      ],
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
          onTap: _showIdCardPicker,
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
                        _identityCardFile != null
                            ? _identityCardFilePath ?? 'Identity card selected'
                            : 'No file selected',
                        style: TextStyle(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_identityCardFile != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _identityCardFile!,
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

  // Method to show image source selection dialog for profile image
  void _showProfileImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  _pickProfileImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  _pickProfileImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to pick profile image from camera or gallery
  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
          _isFormChanged = true;
        });
      }
    } catch (e) {
      // Handle any errors
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method to show image source selection dialog for ID card
  void _showIdCardPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  _pickIdCardFile(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  _pickIdCardFile(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to pick ID card image from camera or gallery
  Future<void> _pickIdCardFile(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _identityCardFile = File(pickedFile.path);
          _identityCardFilePath = pickedFile.name;
          _isFormChanged = true;
        });
      }
    } catch (e) {
      // Handle any errors
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveProfile() async {
    print('Save button clicked');

    // No required fields for now - all fields are optional
    print('Starting save...');
    // Set loading state
    isLoading.value = true;
    isSuccess.value = false;

    String? profilePhotoUrl;
    String? idCardUrl;
    final uploadService = ProfileImageUploadService();

    // Show loading dialog
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
                  _profileImageFile != null || _identityCardFile != null
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

    bool success = false;
    try {
      // Upload profile photo to Supabase if selected
      if (_profileImageFile != null) {
        if (!SupabaseService.isInitialized) {
          throw Exception('Supabase is not initialized');
        }

        print('ProfileSetupScreen: Uploading profile photo to Supabase');
        profilePhotoUrl = await uploadService.uploadProfilePhoto(
          _profileImageFile!,
        );
        print('ProfileSetupScreen: Profile photo URL: $profilePhotoUrl');
      }

      // Upload ID card to Supabase if selected
      if (_identityCardFile != null) {
        if (!SupabaseService.isInitialized) {
          throw Exception('Supabase is not initialized');
        }

        print('ProfileSetupScreen: Uploading ID card to Supabase');
        idCardUrl = await uploadService.uploadIdCard(_identityCardFile!);
        print('ProfileSetupScreen: ID card URL: $idCardUrl');
      }

      // Try updating/creating profile using the new API with image URLs
      print('Attempting to save profile with new API...');
      success = await _profileController.updateProfileWithNewAPI(
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

      // Close loading dialog
      Get.back();

      if (success) {
        // Show success state
        isSuccess.value = true;
        _isFormChanged = false;

        // Show success dialog
        Get.dialog(
          Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Success!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your profile has been updated successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close success dialog
                        Get.back(); // Navigate back to profile page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5796FF),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Clean the error message to remove URLs and technical details
        String errorMessage = ErrorMessageHelper.getUserFriendlyMessage(
          _profileController.error.value,
        );

        // Check if it's the "profile not found" error - show dialog with option to go to academic details
        if (errorMessage.contains('academic details')) {
          Get.dialog(
            AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Academic Details Required',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
              content: Text(
                'You need to set up your academic details before updating your profile. Would you like to do that now?',
                style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                  },
                  child: Text(
                    'Later',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Close profile setup
                    Get.toNamed('/academic-details'); // Go to academic details
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5796FF),
                  ),
                  child: Text(
                    'Set Up Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          Get.snackbar(
            'Error',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Clean up uploaded images if profile update failed
      if (profilePhotoUrl != null || idCardUrl != null) {
        print('ProfileSetupScreen: Cleaning up uploaded images due to error');
        try {
          if (profilePhotoUrl != null) {
            await uploadService.deleteImage(profilePhotoUrl);
          }
          if (idCardUrl != null) {
            await uploadService.deleteImage(idCardUrl);
          }
        } catch (cleanupError) {
          print('ProfileSetupScreen: Error cleaning up images: $cleanupError');
        }
      }

      // Clean the exception message
      String cleanError = ErrorMessageHelper.cleanErrorMessage(e.toString());

      Get.snackbar(
        'Error',
        cleanError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to convert base64 string to image bytes
  Uint8List _convertBase64ToImage(String base64String) {
    return base64Decode(base64String);
  }
}
