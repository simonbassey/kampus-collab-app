import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSetupModal extends StatelessWidget {
  const ProfileSetupModal({Key? key}) : super(key: key);

  // Show a modal dialog prompting the user to setup their profile
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must take action
      builder: (context) => const ProfileSetupModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: const Color(0x1A000000), // 0px 4px 12px 0px #0000001A
      borderRadius: BorderRadius.circular(8),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
                  Container(
                    height: 24,
                    width: 1,
                    color: Color(0xffE8E8E8),
                  ),
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

  const _ActionButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

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
