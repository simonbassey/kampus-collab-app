import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../controllers/student_profile_controller.dart';
import '../../controllers/auth_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // Get the controllers
  final StudentProfileController _profileController =
      Get.find<StudentProfileController>();
  final AuthController _authController = Get.find<AuthController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch profile data when page loads
    _profileController.fetchCurrentUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Monda',
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop(); // Close the dialog

                    // Show loading indicator
                    Get.dialog(
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5796FF),
                        ),
                      ),
                      barrierDismissible: false,
                    );

                    // Perform logout
                    await _authController.logout();

                    // Close loading indicator and navigate to login page
                    Get.back();
                    Get.offAllNamed('/login'); // Navigate to login page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5796FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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
            const SizedBox(width: 16),
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
          PopupMenuButton<String>(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            elevation: 1,
            color: Color(0xffF9FAFB),
            icon: const Icon(Icons.more_vert, color: Color(0xff333333)),
            onSelected: (value) {
              if (value == 'edit') {
                Get.toNamed('/profile-setup');
              } else if (value == 'logout') {
                _showLogoutConfirmation(context);
              } else if (value == 'start-live') {
                Get.toNamed('/live-session');
              } else if (value == 'settings') {
                Get.toNamed('/settings');
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_square,
                          color: Color(0xff333333),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            letterSpacing: 0,
                            color: Color(0xff333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'start-live',
                    child: Row(
                      children: [
                        Icon(
                          Icons.video_call,
                          color: Color(0xff333333),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Start Live Session',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            letterSpacing: 0,
                            color: Color(0xff333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Color(0xff333333), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            letterSpacing: 0,
                            color: Color(0xff333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          color: Color(0xff333333),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            letterSpacing: 0,
                            color: Color(0xff333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Obx(() {
        // Show error if any
        if (_profileController.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${_profileController.error.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _profileController.fetchCurrentUserProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5796FF),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        // Show loading indicator
        if (_profileController.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF5796FF)),
                SizedBox(height: 16),
                Text('Loading profile...'),
              ],
            ),
          );
        }

        // Show profile content
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildFollowSection(),
                const SizedBox(height: 16),
                _buildTabBar(),
                _buildTabContent(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      final profile = _profileController.studentProfile.value;
      final isLoading = _profileController.isLoading.value;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Profile avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF5796FF), width: 3),
                  image:
                      profile?.profilePhotoUrl != null
                          ? DecorationImage(
                            image: MemoryImage(
                              _convertBase64ToImage(profile!.profilePhotoUrl!),
                            ),
                            fit: BoxFit.cover,
                          )
                          : const DecorationImage(
                            image: AssetImage('assets/images/Group 13.png'),
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => Get.toNamed('/profile-setup'),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5796FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${profile?.fullName} @${profile?.email?.split('@').first ?? 'Anonymous'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            profile?.shortBio ?? 'No bio available',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      );
    });
  }

  // Helper method to convert base64 string to image bytes
  Uint8List _convertBase64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  Widget _buildFollowSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFollowColumn('Following', '0'),
        Container(
          height: 24,
          width: 1,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(horizontal: 32),
        ),
        _buildFollowColumn('Followers', '0'),
      ],
    );
  }

  Widget _buildFollowColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF5796FF),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF5796FF),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Blog Posts'),
          Tab(text: 'Saved'),
          Tab(text: 'Projects'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 400, // Adjust height as needed
      child: TabBarView(
        controller: _tabController,
        children: [_buildBlogPostsTab(), _buildSavedTab(), _buildProjectsTab()],
      ),
    );
  }

  Widget _buildBlogPostsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            '0 post',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTab() {
    return const Center(child: Text('No saved items yet'));
  }

  Widget _buildProjectsTab() {
    return const Center(child: Text('No projects yet'));
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Education',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildEducationItem(
          'University Of Cross River State',
          'Computer Science',
        ),
      ],
    );
  }

  Widget _buildEducationItem(String institution, String field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.school, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                institution,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                field,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Skill as a service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSkillItem('Tailoring'),
        _buildSkillItem('Tailoring'),
      ],
    );
  }

  Widget _buildSkillItem(String skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            skill,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
