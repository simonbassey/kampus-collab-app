import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Check if profile needs setup - delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showProfileSetupModal(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            Expanded(
              child: Center(
                child: Text(
                  'Feed Content Will Go Here',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile avatar button
              GestureDetector(
                onTap: () {
                  // Navigate to profile page
                  Get.toNamed('/profile');
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 20,
                  child: const Icon(Icons.person, color: Colors.black),
                ),
              ),

              // App title
              const Text(
                'INKSTRYQ',
                style: TextStyle(
                  fontFamily: 'Monda',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              // Search button
              GestureDetector(
                onTap: () {
                  // Handle search tap
                  // Get.toNamed('/search'); // Replace with your search route
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 20,
                  child: const Icon(Icons.search, color: Colors.black),
                ),
              ),
            ],
          ),

          // Post creation input
          const SizedBox(height: 16),
          _buildPostCreationInput(),
        ],
      ),
    );
  }

  Widget _buildPostCreationInput() {
    return Row(
      children: [
        // Main post creation input field
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Navigate to create post screen when tapping the input field
              Get.toNamed('/create-post');
            },
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Color(0xFFE8E8E8)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      enabled: false, // Disable actual text input
                      decoration: InputDecoration(
                        hintText: "What's happening in school?",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Separate AI button with SVG icon
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            // Show AI assistance dialog
            _showAIAssistanceDialog(Get.context!);
          },
          child: SvgPicture.asset(
            'assets/icons/ai_icon.svg',
            height: 40,
            width: 40,
          ),
        ),
      ],
    );
  }

  void _showAIAssistanceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistance',
                  style: TextStyle(
                    fontFamily: 'Monda',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'How would you like AI to help you with your post?',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                _buildAIOption(
                  icon: Icons.lightbulb_outline,
                  title: 'Generate post ideas',
                  onTap: () => Get.back(),
                ),
                const SizedBox(height: 12),
                _buildAIOption(
                  icon: Icons.edit_note,
                  title: 'Help me draft a post',
                  onTap: () => Get.back(),
                ),
                const SizedBox(height: 12),
                _buildAIOption(
                  icon: Icons.auto_fix_high,
                  title: 'Improve my writing',
                  onTap: () => Get.back(),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildAIOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5796FF)),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Show a modal dialog prompting the user to setup their profile
  void showProfileSetupModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must take action
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Center(
              child: Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontFamily: 'Monda',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            titleTextStyle: const TextStyle(color: Colors.black),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User avatar placeholder
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your profile is incomplete. Adding your information helps others connect with you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Progress indicator
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.2, // 20% complete
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5796FF),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '20% Complete',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5796FF)),
                    ),
                    Text(
                      '4 steps left',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: Text(
                  'Later',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate to profile setup screen
                  Get.toNamed('/profile-setup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5796FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Complete Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
