import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/student_profile_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final StudentProfileController _profileController =
      Get.find<StudentProfileController>();

  // Form controllers
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  // For the skills/interests
  final List<String> _skills = ['Tailoring'];
  final TextEditingController _newSkillController = TextEditingController();

  // For profile picture
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isFormChanged = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _newSkillController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final profile = _profileController.studentProfile.value;
    if (profile != null) {
      _bioController.text = profile.shortBio ?? '';
      _emailController.text = profile.email;
      // Add these fields when the model supports them
      //_phoneController.text = profile.phoneNumber ?? '';
      //_studentIdController.text = profile.academicDetails?.identityNumber ?? '';

      // Placeholder for skills, would come from the API in future
      setState(() {
        _skills.clear();
        // Will add real skills when available from API
        _skills.add('Tailoring');
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _isFormChanged = true;
      });
    }
  }

  void _addSkill() {
    if (_newSkillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_newSkillController.text.trim());
        _newSkillController.clear();
        _isFormChanged = true;
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
      _isFormChanged = true;
    });
  }

  Future<void> _saveProfile() async {
    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF5796FF))),
      barrierDismissible: false,
    );

    // Log the request payload for debugging
    final requestPayload = {
      'fullName': null, // Not updating in this screen
      'email': _emailController.text,
      'shortBio': _bioController.text,
      'hasProfileImage': _profileImage != null,
      'skills': _skills,
    };
    print('API Request payload: $requestPayload');

    try {
      // Update profile
      final success = await _profileController.updateProfile(
        fullName: null, // Not updating the name in this screen
        email: _emailController.text,
        shortBio: _bioController.text,
        profileImageFile: _profileImage,
        // Other fields would be included here
        // identityNumber: _studentIdController.text,
      );

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
        Get.snackbar(
          'Error',
          'Failed to update profile: ${_profileController.error.value}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      // Log any exceptions
      print('Exception during profile update: $e');
      print('Stack trace: $stackTrace');

      // Close loading indicator
      Get.back();

      // Show error feedback
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
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
                      onPressed: _isFormChanged ? _saveProfile : null,
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
                                _isFormChanged
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

        if (_profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profile == null) {
          return const Center(child: Text('Profile not found'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo
                _buildProfileAvatar(profile),
                const SizedBox(height: 24),

                // Email
                _buildFormField(
                  'Email',
                  'Your email address',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Bio
                _buildFormField(
                  'Bio',
                  'Write something about yourself',
                  _bioController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Phone (to be implemented when model supports it)
                _buildFormField(
                  'Phone',
                  'Your phone number',
                  _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Student ID
                _buildFormField(
                  'Student ID',
                  'Your student ID number',
                  _studentIdController,
                ),
                const SizedBox(height: 24),

                // Skills Section with inline Add button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skill as a service',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newSkillController,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'E.g tailor, phone engineer',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              contentPadding: const EdgeInsets.only(
                                bottom: 8,
                                top: 4,
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF5796FF),
                                  width: 2,
                                ),
                              ),
                              filled: false,
                              isDense: true,
                            ),
                            onChanged:
                                (_) => setState(() => _isFormChanged = true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addSkill,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5796FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Display existing skills
                if (_skills.isNotEmpty)
                  ..._skills.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildSkillItem(entry.key, entry.value),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFormField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
          onChanged: (_) => setState(() => _isFormChanged = true),
        ),
      ],
    );
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
                          image: MemoryImage(
                            _convertBase64ToImage(profile.profilePhotoUrl!),
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

  Widget _buildSkillItem(int index, String skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/service.svg', width: 18, height: 18),
          const SizedBox(width: 12),
          Text(
            skill,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF606060),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _removeSkill(index),
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Helper method to convert base64 string to image bytes
  Uint8List _convertBase64ToImage(String base64String) {
    return base64Decode(base64String);
  }
}
