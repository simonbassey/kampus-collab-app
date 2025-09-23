import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../controllers/student_profile_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/profile_photo_viewer.dart';
import '../../models/post_model.dart';

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
  // Get the controllers if needed
  StudentProfileController? _profileController;
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // User data
  String userName = '';
  String userEmail = '';
  String userAvatar = '';
  String userBio = '';
  int followerCount = 0;
  int followingCount = 0;

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

  void _fetchCurrentUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _profileController!.fetchCurrentUserProfile();

      setState(() {
        _isLoading = false;
        userName = _profileController!.studentProfile.value?.fullName ?? 'User';
        userEmail = _profileController!.studentProfile.value?.email ?? '';
        userBio =
            _profileController!.studentProfile.value?.shortBio ??
            'No bio available';
        // Get follower and following counts from the profile if available
        followerCount =
            _profileController!.studentProfile.value?.followerCount ?? 0;
        followingCount =
            _profileController!.studentProfile.value?.followingCount ?? 0;
        // userAvatar is from profile controller
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  void _fetchUserProfile() {
    // In a real app, this would fetch user profile data from API
    // For now, we'll just use what was passed in
    setState(() {
      _isLoading = false;
      userName = widget.userName;
      userAvatar = widget.userAvatar;
      userEmail = userName.replaceAll(' ', '').toLowerCase() + '@example.com';
      userBio = '';
      followerCount = 0; // Default to 0 until API provides real data
      followingCount = 0; // Default to 0 until API provides real data
    });
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
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF5796FF)),
                    SizedBox(height: 16),
                    Text('Loading profile...'),
                  ],
                ),
              )
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
    return Column(
      children: [
        // Profile avatar
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
                border: Border.all(color: const Color(0xFF5796FF), width: 3),
                image:
                    widget.isCurrentUser &&
                            _profileController
                                    ?.studentProfile
                                    .value
                                    ?.profilePhotoUrl !=
                                null
                        ? DecorationImage(
                          image: MemoryImage(
                            _convertBase64ToImage(
                              _profileController!
                                  .studentProfile
                                  .value!
                                  .profilePhotoUrl!,
                            ),
                          ),
                          fit: BoxFit.cover,
                        )
                        : widget.userAvatar.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(widget.userAvatar),
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: -0.41,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 4),
            Text(
              '@${userEmail.split('@').first}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                letterSpacing: -0.41,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          userBio,
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

  // Helper method to convert base64 string to image bytes
  Uint8List _convertBase64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  // Method to show expanded profile photo
  void _showExpandedProfilePhoto() {
    if (widget.isCurrentUser &&
        _profileController?.studentProfile.value?.profilePhotoUrl != null) {
      // Show the profile photo from base64 data
      final imageData = _convertBase64ToImage(
        _profileController!.studentProfile.value!.profilePhotoUrl!,
      );
      showDialog(
        context: context,
        builder:
            (context) =>
                ProfilePhotoViewer(photoData: imageData, isAssetImage: false),
      );
    } else if (widget.userAvatar.isNotEmpty) {
      // For network images, we just show a larger version in a dialog
      showDialog(
        context: context,
        builder:
            (context) => Dialog(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.userAvatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
      );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFollowColumn('Following', followingCount.toString()),
        Container(
          height: 24,
          width: 1,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(horizontal: 32),
        ),
        _buildFollowColumn('Followers', followerCount.toString()),
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
        SizedBox(
          height: 60, // Space for tab content
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBlogPostsTab(),
              _buildSavedTab(),
              _buildProjectsTab(),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _buildEducationSection(),
        const SizedBox(height: 30),
        _buildSkillsSection(),
      ],
    );
  }

  Widget _buildBlogPostsTab() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          '0 post',
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
      ),
    );
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
    // For the view profile, we'll just show placeholder since we don't have the data
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
        _buildEducationItem(
          institution: 'University Information Not Available',
          field: 'Program/Department Not Available',
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
    // For the view profile, we'll just show placeholder skills
    List<String> skills = ['Not Available']; // Placeholder skills

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 12),
        ...skills.map(
          (skill) => _buildSkillItem(
            skill: skill,
            skillSvg: 'assets/icons/service.svg',
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
}
