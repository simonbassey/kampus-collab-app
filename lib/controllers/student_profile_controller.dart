import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/student_profile_model.dart';
import '../services/student_profile_service.dart';
import '../controllers/auth_controller.dart';

class StudentProfileController extends GetxController {
  final StudentProfileService _profileService = StudentProfileService();
  final AuthController _authController = Get.find<AuthController>();

  Rx<StudentProfileModel?> studentProfile = Rx<StudentProfileModel?>(null);
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Try to fetch the profile when controller is initialized
    fetchCurrentUserProfile();
  }

  // Method to fetch profile for the current authenticated user
  Future<void> fetchCurrentUserProfile() async {
    if (!_authController.isAuthenticated.value) {
      error.value = 'User not authenticated. Please log in.';
      // Redirect to login screen
      Get.offAllNamed('/login');
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      // First check if auth token is valid by requesting it
      final token = await _authController.getAuthToken();
      if (token == null) {
        // Token is expired or invalid
        error.value = 'Your session has expired. Please log in again.';
        _authController.isAuthenticated.value = false;
        // Redirect to login screen
        Get.offAllNamed('/login');
        return;
      }

      // APPROACH 1: Try the /profile/me endpoint first (recommended API)
      try {
        print('Attempting to load profile using /profile/me endpoint');
        final currentUserProfile =
            await _profileService.getCurrentUserProfile();
        // Log detailed profile information
        _logProfileDetails(currentUserProfile, 'from /profile/me endpoint');

        studentProfile.value = currentUserProfile;
        print(
          'Successfully loaded profile for: ${currentUserProfile.email} using /profile/me endpoint',
        );
        return;
      } catch (profileError) {
        print(
          'New endpoint failed: $profileError. Trying alternative approach.',
        );
      }

      // APPROACH 2: Extract user ID from token and use /profile/{userId} endpoint
      try {
        String? userId;
        // Parse the middle part of the JWT token
        final parts = token.split('.');
        if (parts.length > 1) {
          final payload = parts[1];
          final normalized = base64.normalize(payload);
          final decoded = utf8.decode(base64.decode(normalized));
          final Map<String, dynamic> decodedJson = jsonDecode(decoded);

          // Get the user ID from the token claims
          userId =
              decodedJson['sub'] ??
              decodedJson['nameid'] ??
              decodedJson['sid'] ??
              decodedJson['id'];

          print('Extracted userId from token: $userId');

          if (userId != null) {
            print(
              'Attempting to load profile using /profile/{userId} endpoint',
            );
            final userProfile = await _profileService.getUserProfileById(
              userId,
            );
            studentProfile.value = userProfile;
            print('Successfully loaded profile using userId: $userId');
            return;
          }
        }
      } catch (tokenError) {
        print('Error extracting or using userId from token: $tokenError');
      }

      // APPROACH 3: Fallback to the legacy method if all other approaches fail
      print('Attempting legacy method to find user profile');
      final profiles = await _profileService.getAllProfiles();
      print('Fetched ${profiles.length} profiles from API');

      // Check if profiles list is empty
      if (profiles.isEmpty) {
        print('No profiles found in the system');
        error.value = 'No profiles found. Please create a profile first.';
        // Navigate to profile setup page
        Get.toNamed('/profile-setup');
        return;
      }

      final currentUserEmail = _authController.currentEmail.value;
      print('Looking for profile with email: $currentUserEmail');

      if (currentUserEmail.isEmpty) {
        error.value = 'User email not available';
        return;
      }

      final currentUserProfile = profiles.firstWhere(
        (profile) => profile.email == currentUserEmail,
        orElse: () {
          print('No profile found for current user email: $currentUserEmail');
          return StudentProfileModel();
        },
      );

      // Check if the found profile is empty (default model)
      if (currentUserProfile.userId == null) {
        error.value =
            'Profile not found for your account. Please create a profile.';
        // Navigate to profile setup page
        Get.toNamed('/profile-setup');
        return;
      }

      studentProfile.value = currentUserProfile;
      print(
        'Successfully loaded profile for: ${currentUserProfile.email} using legacy method',
      );
    } catch (e) {
      String errorMessage = e.toString();

      // Check if it's an authentication error (401)
      if (errorMessage.contains('401') ||
          errorMessage.toLowerCase().contains('unauthorized') ||
          errorMessage.toLowerCase().contains('token expired')) {
        // Token is likely expired
        error.value = 'Your session has expired. Please log in again.';
        _authController.isAuthenticated.value = false;
        // Clear the token
        await _authController.logout();
        // Redirect to login screen
        Get.offAllNamed('/login');
      } else {
        error.value = 'Failed to load profile: $errorMessage';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Method to update an existing profile
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? shortBio,
    File? idCardFile,
    String? identityNumber,
    File? profileImageFile,
    int? departmentOrProgramId,
    int? facultyOrDisciplineId,
    int? yearOfStudy,
  }) async {
    if (studentProfile.value == null || studentProfile.value!.userId == null) {
      error.value = 'No profile exists to update';
      return false;
    }

    isSaving.value = true;
    error.value = '';

    try {
      // API validation requires these fields to be present
      // Default to existing values or placeholder as fallback
      String identityCardBase64 =
          studentProfile.value!.academicDetails?.identityCardBase64 ??
          'placeholder_image_data';
      String profilePictureBase64 =
          studentProfile.value!.profilePhotoUrl ?? 'placeholder_image_data';

      // Try to encode new images if provided
      if (idCardFile != null) {
        try {
          print('Encoding ID card image for update...');
          final bytes = await idCardFile.readAsBytes();
          identityCardBase64 = base64Encode(bytes);
          print('ID card image encoded successfully for update');
        } catch (e) {
          print('Error encoding ID card image: $e');
          // Keep using existing or placeholder value if encoding fails
        }
      } else {
        print('No new ID card image, using existing or placeholder');
      }

      if (profileImageFile != null) {
        try {
          print('Encoding profile image for update...');
          final bytes = await profileImageFile.readAsBytes();
          profilePictureBase64 = base64Encode(bytes);
          print('Profile image encoded successfully for update');
        } catch (e) {
          print('Error encoding profile image: $e');
          // Keep using existing or placeholder value if encoding fails
        }
      } else {
        print('No new profile image, using existing or placeholder');
      }

      final updatedProfile = StudentProfileModel(
        fullName: fullName ?? studentProfile.value!.fullName,
        email: email ?? studentProfile.value!.email,
        profilePhotoUrl: profilePictureBase64,
        shortBio: shortBio ?? studentProfile.value!.shortBio,
        // Preserve existing follower and following counts
        followerCount: studentProfile.value!.followerCount,
        followingCount: studentProfile.value!.followingCount,
        postCount: studentProfile.value!.postCount,
        academicDetails: AcadmicProfileDetails(
          institutionId:
              studentProfile.value!.academicDetails?.institutionId ?? 0,
          institutionName:
              studentProfile.value!.academicDetails?.institutionName ?? '',
          departmentOrProgramId:
              departmentOrProgramId ??
              studentProfile.value!.academicDetails?.departmentOrProgramId ??
              0,
          departmentOrProgramName:
              studentProfile.value!.academicDetails?.departmentOrProgramName ??
              '',
          facultyOrDisciplineId:
              facultyOrDisciplineId ??
              studentProfile.value!.academicDetails?.facultyOrDisciplineId ??
              0,
          facultyOrDisciplineName:
              studentProfile.value!.academicDetails?.facultyOrDisciplineName ??
              '',
          yearOfStudy:
              yearOfStudy ??
              studentProfile.value!.academicDetails?.yearOfStudy ??
              0,
          identityCardBase64: identityCardBase64,
          identityNumber:
              identityNumber ??
              studentProfile.value!.academicDetails?.identityNumber ??
              '',
        ),
      );

      final result = await _profileService.updateProfile(
        studentProfile.value!.userId!,
        updatedProfile,
      );

      studentProfile.value = result;
      return true;
    } catch (e) {
      error.value = 'Failed to update profile: $e';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Method to delete a profile
  Future<bool> deleteProfile() async {
    if (studentProfile.value == null || studentProfile.value!.userId == null) {
      error.value = 'No profile exists to delete';
      return false;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final result = await _profileService.deleteProfile(
        studentProfile.value!.userId!,
      );
      if (result) {
        studentProfile.value = null;
      }
      return result;
    } catch (e) {
      error.value = 'Failed to delete profile: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Method to update academic details only (institution, program, faculty, year)
  Future<bool> updateAcademicDetails({
    required int institutionId,
    required int departmentOrProgramId,
    required int facultyOrDisciplineId,
    required int yearOfStudy,
  }) async {
    if (!_authController.isAuthenticated.value) {
      error.value = 'User not authenticated';
      return false;
    }

    isSaving.value = true;
    error.value = '';

    try {
      print(
        'Updating academic profile with data: institutionId=$institutionId, programId=$departmentOrProgramId, facultyId=$facultyOrDisciplineId, yearOfStudy=$yearOfStudy',
      );

      final updatedProfile = await _profileService.updateAcademicProfile(
        institutionId: institutionId,
        departmentOrProgramId: departmentOrProgramId,
        facultyOrDisciplineId: facultyOrDisciplineId,
        yearOfStudy: yearOfStudy,
      );

      // Update the local profile with the returned data
      studentProfile.value = updatedProfile;
      return true;
    } catch (e) {
      // Better error handling for network issues
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        error.value = 'Network error: Please check your internet connection';
        print('Exception updating academic profile: $e');
      } else if (e.toString().contains('401') ||
          e.toString().toLowerCase().contains('unauthorized')) {
        error.value = 'Authentication error: Please log in again';
        print('Authentication error updating academic profile: $e');
        // Consider handling authentication renewal here
      } else {
        error.value = 'Failed to update academic details: $e';
        print('General error updating academic profile: $e');
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Method to fetch another user's public profile
  Future<StudentProfileModel?> fetchUserProfileById(String userId) async {
    if (!_authController.isAuthenticated.value) {
      error.value = 'User not authenticated';
      return null;
    }

    try {
      final profile = await _profileService.getUserProfileById(userId);
      return profile;
    } catch (e) {
      print('Error fetching user profile: $e');
      error.value = 'Failed to fetch user profile: $e';
      return null;
    }
  }

  // Helper method to log profile details for debugging
  void _logProfileDetails(StudentProfileModel profile, String source) {
    print('=============== PROFILE DETAILS $source ===============');
    // Print raw object representation to see all available data
    print('Raw Profile Object: $profile');
    // Print a more detailed view of each field
    print('ID: ${profile.userId}');
    print('UserID: ${profile.userId}');
    print('Full Name: ${profile.fullName}');
    print('Email: ${profile.email}');
    print('Short Bio: ${profile.shortBio}');
    print('Institution ID: ${profile.academicDetails?.institutionId}');
    print(
      'Department/Program ID: ${profile.academicDetails?.departmentOrProgramId}',
    );
    print(
      'Faculty/Discipline ID: ${profile.academicDetails?.facultyOrDisciplineId}',
    );
    print('Year of Study: ${profile.academicDetails?.yearOfStudy}');
    print(
      'Has Identity Card: ${profile.academicDetails?.identityCardBase64 != null}',
    );
    print('Has Profile Picture: ${profile.profilePhotoUrl != null}');
    print('Follower Count: ${profile.followerCount}');
    print('Following Count: ${profile.followingCount}');
    print('Post Count: ${profile.postCount}');
    print('=============== END PROFILE DETAILS ===============');
  }
}
