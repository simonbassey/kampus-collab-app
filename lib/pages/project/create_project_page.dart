import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data'; // For Uint8List
import '../../controllers/student_profile_controller.dart';
import '../../models/student_profile_model.dart';
import '../../services/project_creation_service.dart';
import '../../widgets/post_creation_toolbar.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({Key? key}) : super(key: key);

  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _teammatesController = TextEditingController();
  final StudentProfileController _profileController =
      Get.find<StudentProfileController>();
  final ProjectCreationService _projectService = ProjectCreationService();
  final List<String> _skills = []; // Store the list of skill chips

  String _visibility = 'Public';
  bool _isPosting = false;
  final int _maxDescriptionLength = 100;
  final int _maxTeammates = 5;

  @override
  void initState() {
    super.initState();
    // Ensure profile is loaded
    if (_profileController.studentProfile.value == null) {
      _profileController.fetchCurrentUserProfile();
    }

    // Set default value for teammates
    _teammatesController.text = '1';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _teammatesController.dispose();
    super.dispose();
  }

  // Handle adding a skill chip when a comma or space is typed
  void _handleSkillInput(String value) {
    // Check if the input ends with a comma, space, or enter key
    if (value.endsWith(',') || value.endsWith(' ')) {
      // Get the skill text without the separator
      String skill = value.trim();
      if (skill.endsWith(',')) {
        skill = skill.substring(0, skill.length - 1).trim();
      }

      // Only add non-empty skills that aren't duplicates
      if (skill.isNotEmpty && !_skills.contains(skill)) {
        setState(() {
          _skills.add(skill);
          _skillsController.clear();
        });
      } else {
        // Just clear the comma/space if the skill is empty or a duplicate
        _skillsController.clear();
      }
    }
  }

  // Remove a skill chip
  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  // Generate a username handle from profile data
  // Show audience selector bottom sheet
  void _showAudienceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Who can see your project?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose who can see your project',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAudienceOption(
                    'Public',
                    Icons.public,
                    _visibility == 'Public',
                    () {
                      setState(() {
                        this.setState(() => _visibility = 'Public');
                        Navigator.pop(context);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAudienceOption(
                    'Verified accounts only',
                    Icons.verified_user,
                    _visibility == 'Verified accounts only',
                    () {
                      setState(() {
                        this.setState(
                          () => _visibility = 'Verified accounts only',
                        );
                        Navigator.pop(context);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAudienceOption(
                    'Accounts you follow',
                    Icons.people,
                    _visibility == 'Accounts you follow',
                    () {
                      setState(() {
                        this.setState(
                          () => _visibility = 'Accounts you follow',
                        );
                        Navigator.pop(context);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAudienceOption(
                    'Accounts you mention',
                    Icons.alternate_email,
                    _visibility == 'Accounts you mention',
                    () {
                      setState(() {
                        this.setState(
                          () => _visibility = 'Accounts you mention',
                        );
                        Navigator.pop(context);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build audience option item
  Widget _buildAudienceOption(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFF4F4F4),
              radius: 24,
              child: Icon(icon, color: const Color(0xFF333333), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // Show hashtag selector bottom sheet
  void _showHashtagSelector(BuildContext context) {
    // Example trending hashtags
    final List<String> trendingHashtags = [
      'Nigerianstudents',
      'NACOS',
      'TechInnovation',
      'WebDev',
      'MobileApp',
      'AI',
      'MachineLearning',
      'CloudComputing',
      'UIDesign',
      'StartupIdea',
    ];

    final TextEditingController searchController = TextEditingController();
    List<String> filteredHashtags = List.from(trendingHashtags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search hashtags',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            filteredHashtags = List.from(trendingHashtags);
                          } else {
                            // Filter existing hashtags
                            filteredHashtags =
                                trendingHashtags
                                    .where(
                                      (hashtag) => hashtag
                                          .toLowerCase()
                                          .contains(value.toLowerCase()),
                                    )
                                    .toList();

                            // Add the search term as a hashtag if it's not in the list
                            final searchTerm = value.replaceAll('#', '').trim();
                            if (searchTerm.isNotEmpty &&
                                !filteredHashtags.contains(searchTerm) &&
                                !filteredHashtags
                                    .map((e) => e.toLowerCase())
                                    .contains(searchTerm.toLowerCase())) {
                              filteredHashtags.insert(0, searchTerm);
                            }
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                  // Results
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredHashtags.length,
                      separatorBuilder:
                          (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE5E7EB),
                            indent: 16,
                            endIndent: 16,
                          ),
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(
                            '#${filteredHashtags[index]}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            // Insert hashtag at current cursor position in the description
                            _insertTextInController(
                              _descriptionController,
                              '#${filteredHashtags[index]} ',
                            );
                            Navigator.pop(context); // Close bottom sheet
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Show mention selector bottom sheet
  void _showMentionSelector(BuildContext context) {
    // Example users to mention (potential team members)
    final List<Map<String, dynamic>> users = [
      {
        'name': 'Precious Eyo',
        'username': 'Precious_Eyo',
        'skills': 'UI/UX, Frontend',
        'photo': null,
      },
      {
        'name': 'John Smith',
        'username': 'johnsmith',
        'skills': 'UI/UX, Frontend',
        'photo': null,
      },
      {
        'name': 'Sarah Johnson',
        'username': 'sarah_j',
        'skills': 'Backend, Database',
        'photo': null,
      },
      {
        'name': 'Michael Brown',
        'username': 'mike.brown',
        'skills': 'Mobile Dev, Flutter',
        'photo': null,
      },
      {
        'name': 'Jessica Williams',
        'username': 'jesswilliams',
        'skills': 'Product Management',
        'photo': null,
      },
      {
        'name': 'David Miller',
        'username': 'davemiller',
        'skills': 'DevOps, Cloud',
        'photo': null,
      },
      {
        'name': 'Amanda Taylor',
        'username': 'amandatay',
        'skills': 'Data Science, ML',
        'photo': null,
      },
      {
        'name': 'Robert Davis',
        'username': 'robdavis',
        'skills': 'Frontend, React',
        'photo': null,
      },
      {
        'name': 'Jennifer Garcia',
        'username': 'jgarcia',
        'skills': 'UI Design, Graphics',
        'photo': null,
      },
      {
        'name': 'William Rodriguez',
        'username': 'willrod',
        'skills': 'Backend, API Design',
        'photo': null,
      },
    ];

    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredUsers = List.from(users);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search people by name or skills',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredUsers =
                              users
                                  .where(
                                    (user) =>
                                        user['name'].toLowerCase().contains(
                                          value.toLowerCase(),
                                        ) ||
                                        user['username'].toLowerCase().contains(
                                          value.toLowerCase(),
                                        ) ||
                                        user['skills'].toLowerCase().contains(
                                          value.toLowerCase(),
                                        ),
                                  )
                                  .toList();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                  // Results
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredUsers.length,
                      separatorBuilder:
                          (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE5E7EB),
                            indent: 72, // Indent to align with profile image
                            endIndent: 16,
                          ),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(
                              0xff5796FF,
                            ).withOpacity(0.2),
                            child:
                                user['photo'] == null
                                    ? Icon(
                                      Icons.person,
                                      color: const Color(
                                        0xff5796FF,
                                      ).withOpacity(0.7),
                                    )
                                    : null,
                          ),
                          title: Text(
                            user['name'],
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${user['username']}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF666666),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Skills: ${user['skills']}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF666666),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Insert mention at current cursor position in the description
                            _insertTextInController(
                              _descriptionController,
                              '@${user["username"]} ',
                            );
                            Navigator.pop(context); // Close bottom sheet
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Insert text at current cursor position in a specified text controller
  void _insertTextInController(TextEditingController controller, String text) {
    final TextSelection selection = controller.selection;
    final String currentText = controller.text;

    final String newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + text.length,
      ),
    );

    // Refresh UI to show formatting
    setState(() {});
  }

  // Build formatted text with styled hashtags and mentions
  Widget _buildFormattedText(String text) {
    // If text is empty, return an empty container
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    // Split text into parts by word boundaries
    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(r'\B#\w+|\B@\w+|\s+|[^\s#@]+');
    final Iterable<Match> matches = regex.allMatches(text);

    for (final Match match in matches) {
      final String part = match.group(0) ?? '';

      if (part.startsWith('#')) {
        // Hashtag styling
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold, // Bold hashtags
              fontSize: 16.0,
              color: Color(0xFF5796FF), // Blue color for hashtags
            ),
          ),
        );
      } else if (part.startsWith('@')) {
        // Mention styling
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold, // Bold mentions
              fontSize: 16.0,
              color: Color(0xFF5796FF), // Blue color for mentions
            ),
          ),
        );
      } else {
        // Regular text - make this transparent so the real text field shows through
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 16.0,
              color: Colors.transparent, // Transparent for normal text
            ),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          fontSize: 16.0,
          color: Colors.transparent, // Make default text transparent
        ),
        children: spans,
      ),
      overflow: TextOverflow.clip,
      maxLines: 4,
    );
  }

  // Get icon for selected visibility
  Widget _getVisibilityIcon() {
    IconData iconData;
    switch (_visibility) {
      case 'Public':
        iconData = Icons.public;
        break;
      case 'Verified accounts only':
        iconData = Icons.verified_user;
        break;
      case 'Accounts you follow':
        iconData = Icons.people;
        break;
      case 'Accounts you mention':
        iconData = Icons.alternate_email;
        break;
      default:
        iconData = Icons.public;
    }

    return Icon(iconData, size: 18, color: const Color(0xff333333));
  }

  // Generate a username handle from profile data
  String _getUserHandle(StudentProfileModel? profile) {
    if (profile == null) return '@user';

    // Use the username field if available
    if (profile.username != null && profile.username!.isNotEmpty) {
      return '@${profile.username}';
    }

    // Fallback to using the full name
    if (profile.fullName != null && profile.fullName!.isNotEmpty) {
      // Remove spaces and convert to lowercase
      String nameBased = profile.fullName!.toLowerCase().replaceAll(' ', '');
      return '@$nameBased';
    }

    // Default fallback
    return '@user';
  }

  // Helper to check if string is a URL
  bool _isUrl(String? str) {
    if (str == null) return false;
    return str.startsWith('http://') || str.startsWith('https://');
  }

  // Convert base64 string to image bytes
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

  void _submitProject() async {
    // Validate inputs
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a project title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Get teammates count from input
      int teammatesCount = 1; // Default to 1
      try {
        teammatesCount = int.parse(_teammatesController.text);
        if (teammatesCount < 1) teammatesCount = 1;
        if (teammatesCount > _maxTeammates) teammatesCount = _maxTeammates;
      } catch (e) {
        // If parsing fails, use default value
        print('Error parsing teammates count: $e');
      }

      // Combine skills from chips and any text in the controller
      final skillsText = _skills.join(', ');
      final currentSkill = _skillsController.text.trim();
      final finalSkills =
          currentSkill.isNotEmpty
              ? skillsText.isEmpty
                  ? currentSkill
                  : '$skillsText, $currentSkill'
              : skillsText;

      // Call the project creation service
      await _projectService.createProject(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        skills: finalSkills,
        teammatesCount: teammatesCount,
        visibility: _visibility,
      );

      // Show success message
      Get.snackbar(
        'Success',
        'Your project has been created!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Close the page after posting
      Get.back(result: true);
    } catch (e) {
      // Show error
      Get.snackbar(
        'Error',
        'Failed to create project: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Create project',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          _isPosting
              ? const Padding(
                padding: EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
              : ElevatedButton(
                onPressed: _submitProject,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      _titleController.text.trim().isEmpty
                          ? const Color(0xffA4A4A4)
                          : const Color(0xff5796FF),
                  minimumSize: const Size(30, 32),
                ),
                child: const Text(
                  'Create project',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 14,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
          const SizedBox(width: 14),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xffE5E7EB)),
          const SizedBox(height: 20),
          Obx(() {
            final profile = _profileController.studentProfile.value;
            return ListTile(
              leading: GestureDetector(
                onTap: () {
                  // Navigate to profile page when avatar is clicked
                  // Get.to(() => const ProfilePage());
                },
                child: CircleAvatar(
                  backgroundImage:
                      profile?.profilePhotoUrl != null
                          ? _isUrl(profile!.profilePhotoUrl)
                              ? NetworkImage(profile.profilePhotoUrl!)
                                  as ImageProvider
                              : MemoryImage(
                                _convertBase64ToImage(profile.profilePhotoUrl!),
                              )
                          : null,
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint(
                      'Error loading profile image in create project: $exception',
                    );
                  },
                  backgroundColor:
                      profile?.profilePhotoUrl == null
                          ? const Color(0xff5796FF).withOpacity(0.2)
                          : null,
                  child:
                      profile?.profilePhotoUrl == null
                          ? Icon(
                            Icons.person,
                            color: const Color(0xff5796FF).withOpacity(0.7),
                          )
                          : null,
                ),
              ),
              title: Row(
                children: [
                  Text(
                    profile?.fullName ?? 'Anonymous',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      height: 22 / 16,
                      letterSpacing: -0.41,
                      color: Color(0xff333333),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getUserHandle(profile),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 12.0,
                      height: 22 / 12,
                      letterSpacing: -0.41,
                      color: Color(0xFF606060),
                    ),
                  ),
                ],
              ),
              subtitle: GestureDetector(
                onTap: () => _showAudienceSelector(context),
                child: Container(
                  margin: const EdgeInsets.only(top: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getVisibilityIcon(),
                      const SizedBox(width: 8),
                      Text(
                        _visibility,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontSize: 14.0,
                          height: 1.0,
                          letterSpacing: 0.0,
                          color: Color(0xff333333),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Color(0xff333333),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Title
                  const Text(
                    'Project title',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Give your project a title',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF5796FF)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 24),

                  // Project Description
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Project description',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        '${_descriptionController.text.length}/$_maxDescriptionLength',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rich text description field with hashtag and mention support
                  Container(
                    height: 120, // Fixed height for 4 lines
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          // Normal text field for input
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            maxLength: _maxDescriptionLength,
                            decoration: InputDecoration(
                              hintText: 'Describe your project',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              counterText: '',
                            ),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          // Overlay for rich text formatting
                          if (_descriptionController.text.isNotEmpty)
                            IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: _buildFormattedText(
                                  _descriptionController.text,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Skills Required
                  const Text(
                    'Skills required',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Skills input field with chips inside
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Skills chips inside input box
                        if (_skills.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              top: 8,
                              right: 12,
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  _skills
                                      .map(
                                        (skill) => Chip(
                                          label: Text(
                                            skill,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: const VisualDensity(
                                            horizontal: -2,
                                            vertical: -2,
                                          ),
                                          backgroundColor: const Color(
                                            0xFFEBF5FF,
                                          ),
                                          deleteIconColor: const Color(
                                            0xFF5796FF,
                                          ),
                                          onDeleted: () => _removeSkill(skill),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        // Text input field
                        TextField(
                          controller: _skillsController,
                          decoration: InputDecoration(
                            hintText:
                                _skills.isEmpty
                                    ? 'Type skills, separate with commas'
                                    : 'Add more skills',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            border:
                                InputBorder
                                    .none, // No border since container has border
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Color(0xFF5796FF),
                              ),
                              onPressed: () {
                                if (_skillsController.text.trim().isNotEmpty) {
                                  _handleSkillInput(
                                    _skillsController.text.trim() + ',',
                                  );
                                }
                              },
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          onChanged: _handleSkillInput,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _handleSkillInput(value + ',');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      'Type a skill and add comma or space to add it as a tag',
                      style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Number of Team Members
                  const Text(
                    'Number of team mates',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _teammatesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'No. of team members needed',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF5796FF)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixText: '$_maxTeammates max',
                      suffixStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    onChanged: (value) {
                      // Limit to max teammates
                      if (value.isNotEmpty) {
                        int? teammates = int.tryParse(value);
                        if (teammates != null && teammates > _maxTeammates) {
                          _teammatesController.text = _maxTeammates.toString();
                          _teammatesController
                              .selection = TextSelection.fromPosition(
                            TextPosition(
                              offset: _teammatesController.text.length,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Shared toolbar widget
          PostCreationToolbar(
            isProject: true,
            onHashtagPressed: () {
              _showHashtagSelector(context);
            },
            onMentionPressed: () {
              _showMentionSelector(context);
            },
            onImagePressed: () {
              // TODO: Implement image attachment
            },
            onAddPressed: () {
              // TODO: Implement additional features
            },
          ),
        ],
      ),
    );
  }
}
