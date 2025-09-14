import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/student_profile_controller.dart';

class FeedAppBar extends StatelessWidget {
  const FeedAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get access to the student profile controller
    final StudentProfileController profileController =
        Get.find<StudentProfileController>();
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 5.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile avatar on left side
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/profile');
                      },
                      child: Obx(() {
                        final hasProfile =
                            profileController.studentProfile.value != null;
                        final hasValidProfilePicture =
                            hasProfile &&
                            profileController
                                    .studentProfile
                                    .value!
                                    .profilePicture !=
                                null &&
                            profileController
                                    .studentProfile
                                    .value!
                                    .profilePicture !=
                                'placeholder_image_data';

                        // Try to decode the profile image if it exists
                        ImageProvider? profileImageProvider;
                        if (hasValidProfilePicture) {
                          try {
                            final String base64String =
                                profileController
                                    .studentProfile
                                    .value!
                                    .profilePicture!;
                            final Uint8List imageBytes = base64Decode(
                              base64String,
                            );
                            profileImageProvider = MemoryImage(imageBytes);
                          } catch (e) {
                            // If decoding fails, we'll show the fallback icon
                            print('Error decoding profile image: $e');
                          }
                        }

                        return CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 20,
                          backgroundImage: profileImageProvider,
                          child:
                              profileImageProvider == null
                                  ? const Icon(
                                    Icons.person_rounded,
                                    color: Colors.black,
                                  )
                                  : null,
                        );
                      }),
                    ),

                    const SizedBox(width: 12),

                    // App title - blue INKSTRYQ text as shown in image
                    const Text(
                      'INKSTRYQ',
                      style: TextStyle(
                        fontFamily: 'Monda',
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        fontSize: 20,
                        height: 1.25,
                        color: Color(0xFF4285F4), // Blue color as per image
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                // Action buttons - Search and Chat AI
                Row(
                  children: [
                    // AI Chat button
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // Navigate to chat AI page
                          Get.toNamed('/chat_ai');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/icons/chat_ai.svg',
                            width: 77,
                          ),
                        ),
                      ),
                    ),

                    // Search button with SVG icon
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // Navigate to search page
                          Get.toNamed('/feed-search');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            'assets/icons/search 02.svg',
                            width: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000), // 0px 4px 12px 0px #0000001A
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
