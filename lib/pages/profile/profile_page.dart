import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../controllers/student_profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/post_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'edit_profile_page.dart';
import '../../widgets/profile_photo_viewer.dart';
import '../feed/post_components/post_base.dart';
import '../feed/post_components/text_post.dart';
import '../feed/post_components/image_post.dart';
import '../feed/post_components/link_post.dart';
import '../../models/post_model.dart';

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
  final PostController _postController = Get.put(PostController());
  late TabController _tabController;

  // State for "See More" functionality
  int _displayedPostsCount = 1; // Show 1 post initially

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Check if profile is already loaded and has valid data
    final currentProfile = _profileController.studentProfile.value;

    if (currentProfile == null) {
      print('ProfilePage: No cached data, fetching profile...');
      _profileController.fetchCurrentUserProfile();
    } else if (currentProfile.fullName == null ||
        currentProfile.fullName!.isEmpty) {
      print('ProfilePage: Username is null/empty, refetching profile...');
      _profileController.fetchCurrentUserProfile();
    } else {
      print(
        'ProfilePage: Using preloaded profile data with username: ${currentProfile.fullName}',
      );
      // Fetch user posts when profile is loaded
      if (currentProfile.userId != null) {
        _postController.loadUserPosts(currentProfile.userId!);
      }
    }
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
                Get.to(() => const EditProfilePage());
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
        final profile = _profileController.studentProfile.value;

        // Show loading only if loading AND no profile data exists
        if (_profileController.isLoading.value && profile == null) {
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

        // Show error only if there's an error AND no profile data
        if (_profileController.error.value.isNotEmpty && profile == null) {
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

        // Show profile content
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildFollowSection(),
                const SizedBox(height: 50),
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
              GestureDetector(
                onTap: () {
                  _showExpandedProfilePhoto(profile);
                },
                child: Hero(
                  tag: 'profile-photo-hero',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF5796FF),
                        width: 3,
                      ),
                      image:
                          profile?.profilePhotoUrl != null
                              ? DecorationImage(
                                image:
                                    _isUrl(profile!.profilePhotoUrl)
                                        ? NetworkImage(profile.profilePhotoUrl!)
                                            as ImageProvider
                                        : MemoryImage(
                                          _convertBase64ToImage(
                                            profile.profilePhotoUrl!,
                                          ),
                                        ),
                                fit: BoxFit.cover,
                              )
                              : const DecorationImage(
                                image: AssetImage('assets/images/Group 13'),
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => Get.to(() => const EditProfilePage()),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${profile?.fullName}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  letterSpacing: -0.41,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 4),
              Text(
                '@${profile?.username ?? profile?.fullName?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  letterSpacing: -0.41,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profile?.shortBio ?? 'No bio available',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              letterSpacing: -0.41,
              color: const Color(0xFF4A4A4A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    });
  }

  // Helper to check if string is a URL
  bool _isUrl(String? str) {
    if (str == null) return false;
    return str.startsWith('http://') || str.startsWith('https://');
  }

  // Helper method to convert base64 string to image bytes
  Uint8List _convertBase64ToImage(String base64String) {
    try {
      // Remove any data URI prefix if present
      String sanitizedBase64 = base64String;
      if (base64String.contains(',')) {
        sanitizedBase64 = base64String.split(',')[1];
      }
      return base64Decode(sanitizedBase64);
    } catch (e) {
      print('Error converting base64 to image: $e');
      // Return a 1x1 transparent pixel as fallback
      return Uint8List.fromList([0, 0, 0, 0]);
    }
  }

  // Method to show expanded profile photo
  void _showExpandedProfilePhoto(dynamic profile) {
    if (profile?.profilePhotoUrl != null) {
      final photoUrl = profile.profilePhotoUrl!;

      if (_isUrl(photoUrl)) {
        // Show network image
        showDialog(
          context: context,
          builder:
              (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const CircularProgressIndicator(
                            color: Color(0xFF5796FF),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
        );
      } else {
        // Show base64 image
        final imageData = _convertBase64ToImage(photoUrl);
        showDialog(
          context: context,
          builder:
              (context) =>
                  ProfilePhotoViewer(photoData: imageData, isAssetImage: false),
        );
      }
    } else {
      // Show the default avatar
      showDialog(
        context: context,
        builder:
            (context) => ProfilePhotoViewer(
              photoData: 'assets/images/Group 13.png',
              isAssetImage: true,
            ),
      );
    }
  }

  Widget _buildFollowSection() {
    return Obx(() {
      final profile = _profileController.studentProfile.value;
      final followingCount =
          profile?.followingCount != null
              ? profile!.followingCount.toString()
              : '0';
      final followerCount =
          profile?.followerCount != null
              ? profile!.followerCount.toString()
              : '0';

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFollowColumn('Following', followingCount),
          Container(
            height: 24,
            width: 1,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 32),
          ),
          _buildFollowColumn('Followers', followerCount),
        ],
      );
    });
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
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        tabs: const [
          Tab(text: 'Blog Posts'),
          Tab(text: 'Saved'),
          Tab(text: 'Projects'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab content based on selected index
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            switch (_tabController.index) {
              case 0:
                return _buildBlogPostsTab();
              case 1:
                return _buildSavedTab();
              case 2:
                return _buildProjectsTab();
              default:
                return _buildBlogPostsTab();
            }
          },
        ),
        const SizedBox(height: 20),
        _buildEducationSection(),
        const SizedBox(height: 30),
        _buildSkillsSection(),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildBlogPostsTab() {
    return Obx(() {
      final isLoading = _postController.isLoadingUserPosts.value;
      final userPosts = _postController.userPosts;

      if (isLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Color(0xFF5796FF)),
          ),
        );
      }

      if (userPosts.isEmpty) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '0 posts',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ),
        );
      }

      // Calculate how many posts to display
      final postsToShow = userPosts.take(_displayedPostsCount).toList();
      final hasMore = userPosts.length > _displayedPostsCount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Text(
              '${userPosts.length} ${userPosts.length == 1 ? 'post' : 'posts'}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Display posts
          ...postsToShow.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildPostByType(post),
            ),
          ),
          // "See More" button
          if (hasMore)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _displayedPostsCount += 5; // Load 5 more posts
                  });
                },
                icon: Icon(Icons.expand_more, color: Color(0xFF5796FF)),
                label: Text(
                  'See More',
                  style: TextStyle(
                    color: Color(0xFF5796FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          // Show "Show Less" button if more than 1 post is displayed
          if (_displayedPostsCount > 1 && !hasMore)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _displayedPostsCount = 1; // Reset to show only 1 post
                  });
                },
                icon: Icon(Icons.expand_less, color: Colors.grey[700]),
                label: Text(
                  'Show Less',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          SizedBox(height: 10),
        ],
      );
    });
  }

  Widget _buildSavedTab() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          'No saved items',
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildProjectsTab() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          'No projects',
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Obx(() {
      final profile = _profileController.studentProfile.value;
      final academic = profile?.academicDetails;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Education',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              letterSpacing: -0.41,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),

          // Check if academic data exists
          if (academic != null &&
              academic.institutionName.isNotEmpty &&
              academic.departmentOrProgramName.isNotEmpty)
            // Display actual academic data
            _buildEducationItem(
              institution: academic.institutionName,
              field: academic.departmentOrProgramName,
              institutionSvg: 'assets/icons/flaculty.svg',
              fieldSvg: 'assets/icons/department.svg',
              fieldIconFallback: Icons.school_outlined,
              institutionIconFallback: Icons.school_outlined,
            )
          else
            // Display placeholder when data is missing
            _buildEducationItem(
              institution: 'Add your institution',
              field: 'Add your program/department',
              institutionSvg: 'assets/icons/flaculty.svg',
              fieldSvg: 'assets/icons/department.svg',
              fieldIconFallback: Icons.school_outlined,
              institutionIconFallback: Icons.school_outlined,
            ),
        ],
      );
    });
  }

  Widget _buildEducationItem({
    required String institution,
    required String field,
    String? institutionSvg,
    String? fieldSvg,
    IconData institutionIconFallback = Icons.school,
    IconData fieldIconFallback = Icons.subject,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Institution with icon
          Row(
            children: [
              institutionSvg != null
                  ? SvgPicture.asset(institutionSvg, width: 18, height: 18)
                  : Icon(
                    institutionIconFallback,
                    color: Colors.grey[600],
                    size: 18,
                  ),
              const SizedBox(width: 12),
              Text(
                institution,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  height: 22 / 14,
                  letterSpacing: -0.41,
                  color: Color(0xFF606060),
                ),
              ),
            ],
          ),

          // Program with icon
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                fieldSvg != null
                    ? SvgPicture.asset(fieldSvg, width: 16, height: 16)
                    : Icon(
                      fieldIconFallback,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                const SizedBox(width: 12),
                Text(
                  field,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    height: 22 / 14,
                    letterSpacing: -0.41,
                    color: Color(0xFF606060),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    // In the future, we'll get skills from the API
    // For now, using placeholder data
    List<String> skills = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Skill as a service',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: -0.41,
                color: Color(0xFF333333),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const EditProfilePage());
              },
              child: SvgPicture.asset(
                'assets/icons/edit.svg',
                width: 18,
                height: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (skills.isNotEmpty)
          ...skills.map(
            (skill) => _buildSkillItem(
              skill: skill,
              skillSvg: 'assets/icons/service.svg',
            ),
          )
        else
          GestureDetector(
            onTap: () {
              Get.to(() => const EditProfilePage());
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 18,
                    color: Color(0xFF5796FF),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add your skills',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      height: 22 / 14,
                      letterSpacing: -0.41,
                      color: Color(0xFF5796FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkillItem({
    required String skill,
    String? skillSvg,
    IconData iconFallback = Icons.check_circle_outline,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          skillSvg != null
              ? SvgPicture.asset(skillSvg, width: 18, height: 18)
              : Icon(iconFallback, color: Colors.grey[600], size: 18),
          const SizedBox(width: 12),
          Text(
            skill,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              height: 22 / 14,
              letterSpacing: -0.41,
              color: Color(0xFF606060),
            ),
          ),
        ],
      ),
    );
  }

  // Build post widget based on post type
  Widget _buildPostByType(PostModel post) {
    switch (post.type) {
      case PostType.text:
        return TextPost(post: post);
      case PostType.image:
        return ImagePost(post: post);
      case PostType.link:
        return LinkPost(post: post);
    }
  }
}
