import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/student_profile_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();

  // Get the StudentProfileController
  final StudentProfileController _profileController = Get.put(
    StudentProfileController(),
  );

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Selected profile image file
  File? _profileImageFile;

  // Selected student ID file
  File? _idCardFile;
  String? _idCardFilePath;

  // Loading state
  RxBool isLoading = false.obs;
  RxBool isFetchingProfile = false.obs;

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
      // First try the new API endpoint
      await _profileController.fetchCurrentUserProfile();

      // If profile was successfully fetched, populate the form
      if (_profileController.studentProfile.value != null) {
        _populateFormWithProfileData();
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      // Show a snackbar with the error
      Get.snackbar(
        'Error',
        'Could not load your profile data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isFetchingProfile.value = false;
    }
  }

  // Populate form fields with existing profile data
  void _populateFormWithProfileData() {
    final profile = _profileController.studentProfile.value;
    if (profile != null) {
      // Set the text controllers with existing data
      if (profile.fullName?.isNotEmpty == true) {
        _nameController.text = profile.fullName!;
      }

      if (profile.email?.isNotEmpty == true) {
        _emailController.text = profile.email!;
      }

      if (profile.shortBio?.isNotEmpty == true) {
        _bioController.text = profile.shortBio!;
      }

      if (profile.academicDetails?.identityNumber?.isNotEmpty == true) {
        _identityNumberController.text =
            profile.academicDetails!.identityNumber!;
      }

      // Note: For profile image and ID card, we cannot set File objects directly.
      // We would need to store the paths or URLs and display them, but we won't
      // modify the actual File objects until the user selects new files.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Row(
          children: [
            SizedBox(width: 16),
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF5FF),
                borderRadius: BorderRadius.circular(1000),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Color(0xff5796FF),
                ),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () =>
                isLoading.value
                    ? Container(
                      padding: const EdgeInsets.only(right: 16),
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
                label: 'User Name',
                controller: _nameController,
                placeholder: 'Precious_Eyo',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Bio',
                controller: _bioController,
                placeholder: 'Tell your friends about yourself',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildStudentIdUpload(),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Institutional email address',
                controller: _emailController,
                placeholder: 'preciouseyo@unicross.mail',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Skill as a service',
                controller: _skillController,
                placeholder: 'E.g tailor, phone engineer',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
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
                        : null,
              ),
              child:
                  _profileImageFile == null
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
        ),
      ],
    );
  }

  Widget _buildStudentIdUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload student ID',
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
                        _idCardFilePath ?? 'No file selected',
                        style: TextStyle(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_idCardFile != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _idCardFile!,
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
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
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
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _idCardFile = File(pickedFile.path);
          _idCardFilePath = pickedFile.name;
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
    if (_nameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a username',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Set loading state
    isLoading.value = true;

    bool success = false;
    try {
      // Check if we're updating an existing profile or creating a new one
      final existingProfile = _profileController.studentProfile.value;

      if (existingProfile != null && existingProfile.academicDetails != null) {
        // Updating existing profile
        success = await _profileController.updateProfile(
          fullName: _nameController.text,
          email: _emailController.text,
          shortBio: _bioController.text,
          idCardFile: _idCardFile,
          identityNumber: _identityNumberController.text,
          profileImageFile: _profileImageFile,
        );

        if (success) {
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Navigate back to profile page
          Get.back();
        } else {
          Get.snackbar(
            'Error',
            'Failed to update profile: ${_profileController.error.value}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
