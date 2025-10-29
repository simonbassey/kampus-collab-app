import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../controllers/student_profile_controller.dart';
import '../../controllers/post_controller.dart';
import '../../services/profile_service.dart';
import '../../models/student_profile_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/profile_photo_viewer.dart';
import '../../widgets/skeleton_loader.dart';
import '../../models/post_model.dart';
import '../feed/post_components/post_base.dart';
import '../feed/post_components/text_post.dart';
import '../feed/post_components/image_post.dart';
import '../feed/post_components/link_post.dart';

class ViewProfilePage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userAvatar;
  final bool isCurrentUser;

  const ViewProfilePage({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    this.isCurrentUser = false,
  });

  static void showProfile(BuildContext context, PostModel post) {
    // Navigate to profile view using the post data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ViewProfilePage(
              userId: post.userId,
              userName: post.userName,
              userAvatar: post.userAvatar,
              isCurrentUser:
                  false, // Assume it's not the current user when coming from a post
            ),
      ),
    );
  }

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage>
    with SingleTickerProviderStateMixin {
  // Get the controllers and services
  StudentProfileController? _profileController;
  final PostController _postController = Get.put(PostController());
  final ProfileService _profileService = ProfileService();
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // State for "See More" functionality
  int _displayedPostsCount = 1; // Show 1 post initially

  // User profile data from API
  StudentProfileModel? _userProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // If it's the current user, get data from the profile controller
    if (widget.isCurrentUser) {
      _profileController = Get.find<StudentProfileController>();
      _fetchCurrentUserProfile();
    } else {
      // For other users, use the data provided in the widget or fetch from API
      _fetchUserProfile();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Show logout confirmation dialog (for current user only)
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

                    // Perform logout - you might need to import AuthController
                    // await Get.find<AuthController>().logout();

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

  void _fetchCurrentUserProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await _profileController!.fetchCurrentUserProfile();
      _userProfile = _profileController!.studentProfile.value;

      setState(() {
        _isLoading = false;
      });

      // Load user posts if profile is available
      if (_userProfile?.userId != null) {
        _postController.loadUserPosts(_userProfile!.userId!);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  void _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Fetch user profile from API using the profile service
      _userProfile = await _profileService.getUserProfile(widget.userId);

      setState(() {
        _isLoading = false;
      });

      // Load user posts
      _postController.loadUserPosts(widget.userId);
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
        // Only show menu for current user
        actions:
            widget.isCurrentUser
                ? [
                  PopupMenuButton<String>(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    elevation: 1,
                    color: Color(0xffF9FAFB),
                    icon: const Icon(Icons.more_vert, color: Color(0xff333333)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Navigate to edit profile
                        // Get.to(() => const EditProfilePage());
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
                                Icon(
                                  Icons.logout,
                                  color: Color(0xff333333),
                                  size: 20,
                                ),
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
                ]
                : null,
      ),
      body:
          _isLoading
              ? _buildSkeletonLoader()
              : _hasError
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          widget.isCurrentUser
                              ? _fetchCurrentUserProfile
                              : _fetchUserProfile,
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
              )
              : SingleChildScrollView(
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
              ),
    );
  }

  Widget _buildProfileHeader() {
    if (_userProfile == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Profile avatar
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                _showExpandedProfilePhoto();
              },
              child: Hero(
                tag: 'profile-photo-hero-${widget.userId}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF5796FF),
                      width: 3,
                    ),
                    image: _userProfile!.profilePhotoUrl != null
                        ? DecorationImage(
                            image: _isUrl(_userProfile!.profilePhotoUrl!)
                                ? NetworkImage(_userProfile!.profilePhotoUrl!) as ImageProvider
                                : MemoryImage(
                                    _convertBase64ToImage(_userProfile!.profilePhotoUrl!),
                                  ),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/images/Group 13.png'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            // Only show edit button for current user
            if (widget.isCurrentUser)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to edit profile - you might need to import the edit profile page
                    // Get.to(() => const EditProfilePage());
                  },
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
            Flexible(
              flex: 2,
              child: Text(
                _userProfile!.fullName ?? 'Unknown User',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  letterSpacing: -0.41,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              flex: 1,
              child: Text(
                '@${_userProfile!.username ?? _userProfile!.fullName?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  letterSpacing: -0.41,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _userProfile!.shortBio ?? 'No bio available',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            letterSpacing: -0.41,
            color: Color(0xFF4A4A4A),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
  void _showExpandedProfilePhoto() {
    if (_userProfile?.profilePhotoUrl != null) {
      final photoUrl = _userProfile!.profilePhotoUrl!;

      if (_isUrl(photoUrl)) {
        // Show network image
        showDialog(
          context: context,
          builder: (context) => Dialog(
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
          builder: (context) =>
              ProfilePhotoViewer(photoData: imageData, isAssetImage: false),
        );
      }
    } else {
      // Show the default avatar
      showDialog(
        context: context,
        builder: (context) => ProfilePhotoViewer(
          photoData: 'assets/images/Group 13.png',
          isAssetImage: true,
        ),
      );
    }
  }

  Widget _buildFollowSection() {
    if (_userProfile == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFollowColumn('Following', _userProfile!.followingCount.toString()),
        Container(
          height: 24,
          width: 1,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(horizontal: 32),
        ),
        _buildFollowColumn('Followers', _userProfile!.followerCount.toString()),
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
        const SizedBox(height: 30),
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
        // Show education data from API if available
        if (_userProfile?.academicDetails != null)
          _buildEducationItem(
            institution: _userProfile!.academicDetails!.institutionName,
            field: _userProfile!.academicDetails!.departmentOrProgramName,
            institutionSvg: 'assets/icons/flaculty.svg',
            fieldSvg: 'assets/icons/department.svg',
            fieldIconFallback: Icons.school_outlined,
            institutionIconFallback: Icons.school_outlined,
          )
        else
          _buildEducationItem(
            institution: widget.isCurrentUser ? 'Add your institution' : 'Institution not specified',
            field: widget.isCurrentUser ? 'Add your program/department' : 'Program not specified',
            institutionSvg: 'assets/icons/flaculty.svg',
            fieldSvg: 'assets/icons/department.svg',
            fieldIconFallback: Icons.school_outlined,
            institutionIconFallback: Icons.school_outlined,
          ),
      ],
    );
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
    // In the future, skills will come from the API
    // For now, show placeholder since the API doesn't provide skills yet
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
            // Only show edit icon for current user
            if (widget.isCurrentUser)
              GestureDetector(
                onTap: () {
                  // Navigate to edit profile - you might need to import the edit profile page
                  // Get.to(() => const EditProfilePage());
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
          widget.isCurrentUser
              ? GestureDetector(
                  onTap: () {
                    // Navigate to edit profile for current user
                    // Get.to(() => const EditProfilePage());
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
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        'No skills listed',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          height: 22 / 14,
                          letterSpacing: -0.41,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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

  // Build skeleton loader for loading state
  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile header skeleton
            _buildProfileHeaderSkeleton(),
            const SizedBox(height: 24),
            // Follow section skeleton
            _buildFollowSectionSkeleton(),
            const SizedBox(height: 50),
            // Tab bar skeleton
            _buildTabBarSkeleton(),
            const SizedBox(height: 20),
            // Posts skeleton
            _buildPostsSkeleton(),
            const SizedBox(height: 20),
            // Education section skeleton
            _buildEducationSkeleton(),
            const SizedBox(height: 30),
            // Skills section skeleton
            _buildSkillsSkeleton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderSkeleton() {
    return Column(
      children: [
        // Profile avatar skeleton
        Stack(
          children: [
            SkeletonLoader(
              width: 100,
              height: 100,
              borderRadius: BorderRadius.circular(50),
            ),
            // Edit button skeleton for current user
            if (widget.isCurrentUser)
              Positioned(
                right: 0,
                bottom: 0,
                child: SkeletonLoader(
                  width: 32,
                  height: 32,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Name and username skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonLoader(width: 120, height: 20),
            const SizedBox(width: 8),
            SkeletonLoader(width: 80, height: 16),
          ],
        ),
        const SizedBox(height: 8),
        // Bio skeleton
        SkeletonLoader(width: 200, height: 16),
      ],
    );
  }

  Widget _buildFollowSectionSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            SkeletonLoader(width: 40, height: 24),
            const SizedBox(height: 4),
            SkeletonLoader(width: 60, height: 16),
          ],
        ),
        Container(
          height: 24,
          width: 1,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(horizontal: 32),
        ),
        Column(
          children: [
            SkeletonLoader(width: 40, height: 24),
            const SizedBox(height: 4),
            SkeletonLoader(width: 60, height: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBarSkeleton() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SkeletonLoader(width: 80, height: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SkeletonLoader(width: 60, height: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SkeletonLoader(width: 70, height: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post count skeleton
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: SkeletonLoader(width: 80, height: 16),
        ),
        // Post skeleton
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header skeleton
              Row(
                children: [
                  SkeletonLoader(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SkeletonLoader(width: 100, height: 16),
                            const SizedBox(width: 8),
                            SkeletonLoader(width: 60, height: 14),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SkeletonLoader(width: 40, height: 12),
                            const SizedBox(width: 16),
                            SkeletonLoader(width: 80, height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SkeletonLoader(width: 24, height: 24),
                ],
              ),
              const SizedBox(height: 12),
              // Post content skeleton
              Padding(
                padding: const EdgeInsets.only(left: 55.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: double.infinity, height: 16),
                    const SizedBox(height: 8),
                    SkeletonLoader(width: 250, height: 16),
                    const SizedBox(height: 16),
                    // Interaction bar skeleton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonLoader(width: 85, height: 30, borderRadius: BorderRadius.circular(15)),
                        const SizedBox(width: 20),
                        SkeletonLoader(width: 85, height: 30, borderRadius: BorderRadius.circular(15)),
                        const SizedBox(width: 20),
                        SkeletonLoader(width: 85, height: 30, borderRadius: BorderRadius.circular(15)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEducationSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoader(width: 100, height: 20),
        const SizedBox(height: 12),
        Row(
          children: [
            SkeletonLoader(width: 18, height: 18),
            const SizedBox(width: 12),
            SkeletonLoader(width: 180, height: 16),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SkeletonLoader(width: 16, height: 16),
            const SizedBox(width: 12),
            SkeletonLoader(width: 150, height: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonLoader(width: 140, height: 20),
            if (widget.isCurrentUser)
              SkeletonLoader(width: 18, height: 18),
          ],
        ),
        const SizedBox(height: 12),
        // Skills skeleton items
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SkeletonLoader(width: 18, height: 18),
              const SizedBox(width: 12),
              SkeletonLoader(width: 120 + (index * 20).toDouble(), height: 16),
            ],
          ),
        )),
      ],
    );
  }
}
