import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/student_profile_controller.dart';

class ProfileSetupModal extends StatelessWidget {
  const ProfileSetupModal({Key? key}) : super(key: key);

  // Check if profile needs setup
  static bool _needsSetup(StudentProfileController controller) {
    final profile = controller.studentProfile.value;

    // If no profile at all, needs setup
    if (profile == null) {
      print('ProfileSetupModal: No profile found, needs setup');
      return true;
    }

    // Check key profile fields
    final hasShortBio =
        profile.shortBio != null && profile.shortBio!.isNotEmpty;
    final hasAcademicDetails = profile.academicDetails != null;

    // Get identity number from either direct field or academic details
    final identityNumber =
        profile.identityNumber ?? profile.academicDetails?.identityNumber;
    final hasIdentityNumber =
        identityNumber != null && identityNumber.isNotEmpty;

    // Check email
    final hasEmail = profile.email.isNotEmpty;

    // Check for profile photo
    final hasProfilePhoto =
        profile.profilePhotoUrl != null && profile.profilePhotoUrl!.isNotEmpty;

    // Calculate missing fields
    final missingFields = <String>[];
    if (!hasShortBio) missingFields.add('Bio');
    if (!hasAcademicDetails) missingFields.add('Academic Details');
    if (!hasIdentityNumber) missingFields.add('Identity Number');
    if (!hasEmail) missingFields.add('Email');
    if (!hasProfilePhoto) missingFields.add('Profile Photo');

    // Show modal if ANY critical field is missing
    // Note: Profile photo is not critical, so we check for at least 2 missing fields
    final needsSetup = missingFields.length >= 2;

    if (needsSetup) {
      print(
        'ProfileSetupModal: Profile incomplete - Missing: ${missingFields.join(", ")}',
      );
      return true;
    }

    print('ProfileSetupModal: Profile is complete, no setup needed');
    return false;
  }

  // Show a modal dialog prompting the user to setup their profile
  static void show(BuildContext context) {
    try {
      final profileController = Get.find<StudentProfileController>();

      // Only show if profile needs setup
      if (_needsSetup(profileController)) {
        showDialog(
          context: context,
          barrierDismissible: false, // User must take action
          builder: (context) => const ProfileSetupModal(),
        );
      }
    } catch (e) {
      print('ProfileSetupModal: Error checking profile status: $e');
      // If controller not found, don't show modal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: const Color(0x1A000000),
      borderRadius: BorderRadius.circular(8),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.all(0),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            SizedBox(height: 10),
            Text(
              'Click on "Setup", to setup\nyour profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          Divider(height: 1, color: Color(0xffE8E8E8)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionButton(
                    label: 'Later',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Container(height: 24, width: 1, color: Color(0xffE8E8E8)),
                  _ActionButton(
                    label: 'Setup',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.toNamed('/profile-setup');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({Key? key, required this.label, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 16,
          letterSpacing: 0,
          color: Color(0xff333333),
        ),
      ),
    );
  }
}
