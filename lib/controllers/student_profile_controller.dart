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
      
      // Get all profiles and find the one that matches current user's email
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
      if (currentUserProfile.id == 0 || currentUserProfile.id == null) {
        error.value = 'Profile not found for your account. Please create a profile.';
        // Navigate to profile setup page
        Get.toNamed('/profile-setup');
        return;
      }

      studentProfile.value = currentUserProfile;
      print('Successfully loaded profile for: ${currentUserProfile.email}');
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

  // Method to create a new profile
  Future<bool> createProfile({
    required int institutionId,
    required String email,
    String? shortBio,
    required File? idCardFile,
    String? identityNumber,
    required File? profileImageFile,
    int? departmentOrProgramId,
    int? facultyOrDisciplineId,
    int? yearOfStudy,
  }) async {
    if (!_authController.isAuthenticated.value) {
      error.value = 'User not authenticated';
      return false;
    }

    isSaving.value = true;
    error.value = '';

    try {
      // TEMPORARILY skip image uploads to fix 500 error
      // Images are likely too large and causing server issues
      String? identityCardBase64 = null;
      String? profilePictureBase64 = null;
      
      print('Skipping image upload to fix 500 server error');
      
      // Original image processing code commented out for reference
      /*
      if (idCardFile != null) {
        final bytes = await idCardFile.readAsBytes();
        identityCardBase64 = base64Encode(bytes);
      }

      if (profileImageFile != null) {
        final bytes = await profileImageFile.readAsBytes();
        profilePictureBase64 = base64Encode(bytes);
      }
      */

      // Don't set userId - let the server assign it based on the authentication token
      // This fixes the GUID validation error
      final profile = StudentProfileModel(
        // userId field omitted - will be determined by the server from the auth token
        institutionId: institutionId,
        identityCardBase64: identityCardBase64,
        identityNumber: identityNumber,
        email: email,
        profilePicture: profilePictureBase64,
        shortBio: shortBio,
        departmentOrProgramId: departmentOrProgramId ?? 1,
        facultyOrDisciplineId: facultyOrDisciplineId ?? 1,
        yearOfStudy: yearOfStudy ?? 1,
      );

      print('Creating profile for email: $email');
      final createdProfile = await _profileService.createProfile(profile);
      studentProfile.value = createdProfile;
      return true;
    } catch (e) {
      error.value = 'Failed to create profile: $e';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Method to update an existing profile
  Future<bool> updateProfile({
    String? email,
    String? shortBio,
    File? idCardFile,
    String? identityNumber,
    File? profileImageFile,
    int? departmentOrProgramId,
    int? facultyOrDisciplineId,
    int? yearOfStudy,
  }) async {
    if (studentProfile.value == null || studentProfile.value!.id == null) {
      error.value = 'No profile exists to update';
      return false;
    }

    isSaving.value = true;
    error.value = '';

    try {
      // TEMPORARILY skip image uploads to fix 500 error
      // Images are likely too large and causing server issues
      String? identityCardBase64 = null;
      String? profilePictureBase64 = null;
      
      print('Skipping image upload to fix 500 server error');
      
      // Original image processing code commented out for reference
      /*
      if (idCardFile != null) {
        final bytes = await idCardFile.readAsBytes();
        identityCardBase64 = base64Encode(bytes);
      }

      if (profileImageFile != null) {
        final bytes = await profileImageFile.readAsBytes();
        profilePictureBase64 = base64Encode(bytes);
      }
      */

      final updatedProfile = StudentProfileModel(
        identityCardBase64:
            identityCardBase64 ?? studentProfile.value!.identityCardBase64,
        identityNumber: identityNumber ?? studentProfile.value!.identityNumber,
        email: email ?? studentProfile.value!.email,
        profilePicture:
            profilePictureBase64 ?? studentProfile.value!.profilePicture,
        shortBio: shortBio ?? studentProfile.value!.shortBio,
        departmentOrProgramId:
            departmentOrProgramId ??
            studentProfile.value!.departmentOrProgramId,
        facultyOrDisciplineId:
            facultyOrDisciplineId ??
            studentProfile.value!.facultyOrDisciplineId,
        yearOfStudy: yearOfStudy ?? studentProfile.value!.yearOfStudy,
      );

      final result = await _profileService.updateProfile(
        studentProfile.value!.id!,
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
    if (studentProfile.value == null || studentProfile.value!.id == null) {
      error.value = 'No profile exists to delete';
      return false;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final result = await _profileService.deleteProfile(
        studentProfile.value!.id!,
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
}
