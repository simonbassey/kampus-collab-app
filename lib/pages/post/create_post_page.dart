import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:image_picker/image_picker.dart';
import '../../controllers/student_profile_controller.dart';
import '../../controllers/post_controller.dart';
import '../../services/post_creation_service.dart';
import '../../services/supabase_storage_service.dart';
import '../../services/supabase_service.dart';
import '../profile/profile_page.dart';
import '../../models/student_profile_model.dart';
import '../../widgets/post_creation_toolbar.dart';
import '../../utils/error_message_helper.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _postController = TextEditingController();
  final StudentProfileController _profileController =
      Get.find<StudentProfileController>();
  final PostCreationService _postService = PostCreationService();
  final SupabaseStorageService _storageService = SupabaseStorageService();
  final ImagePicker _imagePicker = ImagePicker();
  String _visibility = 'Everyone';
  bool _isPosting = false;
  List<File> _selectedImages = [];
  final int _maxImages = 4;

  @override
  void initState() {
    super.initState();
    // Ensure profile is loaded
    if (_profileController.studentProfile.value == null) {
      _profileController.fetchCurrentUserProfile();
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

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
                    'Who can see your post?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose who can see your post',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAudienceOption(
                    'Everyone',
                    Icons.public,
                    _visibility == 'Everyone',
                    () {
                      setState(() {
                        this.setState(() => _visibility = 'Everyone');
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
              Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
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
      'CampusLife',
      'StudentProjects',
      'ResearchOpportunities',
      'CareerAdvice',
      'StudyTips',
      'InternshipSearch',
      'GradSchool',
      'AcademicSuccess',
    ];

    final TextEditingController searchController = TextEditingController();
    List<String> filteredHashtags = List.from(trendingHashtags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6, // Reduced height
      ),
      isDismissible: true,
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
                            // Insert hashtag at current cursor position
                            _insertTextAtCursor('#${filteredHashtags[index]} ');
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
    // Example users to mention
    final List<Map<String, dynamic>> users = [
      {'name': 'Precious Eyo', 'username': 'Precious_Eyo', 'photo': null},
      {'name': 'John Smith', 'username': 'johnsmith', 'photo': null},
      {'name': 'Sarah Johnson', 'username': 'sarah_j', 'photo': null},
      {'name': 'Michael Brown', 'username': 'mike.brown', 'photo': null},
      {'name': 'Jessica Williams', 'username': 'jesswilliams', 'photo': null},
      {'name': 'David Miller', 'username': 'davemiller', 'photo': null},
      {'name': 'Amanda Taylor', 'username': 'amandatay', 'photo': null},
      {'name': 'Robert Davis', 'username': 'robdavis', 'photo': null},
      {'name': 'Jennifer Garcia', 'username': 'jgarcia', 'photo': null},
      {'name': 'William Rodriguez', 'username': 'willrod', 'photo': null},
    ];

    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredUsers = List.from(users);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6, // Reduced height
      ),
      isDismissible: true,
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
                        hintText: 'Search people',
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
                          subtitle: Text(
                            '@${user['username']}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            // Insert mention at current cursor position
                            _insertTextAtCursor('@${user['username']} ');
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

  // Insert text at current cursor position in the post text field
  void _insertTextAtCursor(String text) {
    final TextEditingController controller = _postController;
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

    // Refresh UI to show the formatted text
    setState(() {});
  }

  // Pick images from gallery or camera
  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) {
      // Show message that max images reached
      Get.snackbar(
        'Maximum Images',
        'You can only select up to $_maxImages images',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Show bottom sheet with options to pick image
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Get image from source
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // Remove image from selected images
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Build a custom rich text editor that only highlights hashtags and mentions
  Widget _buildRichTextEditor() {
    // Fixed height container with scrolling for content that exceeds height
    return Container(
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight:
            MediaQuery.of(context).size.height *
            0.4, // 40% of screen height max
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Text field for post content
            TextField(
              controller: _postController,
              maxLines: null, // Allow text to wrap
              minLines: 3, // At least show 3 lines
              decoration: const InputDecoration(
                hintText: "What's happening in your school?",
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 16.0,
                height: 22 / 16,
                letterSpacing: -0.41,
                color: Color(0xFF333333),
              ),
              onChanged: (text) {
                // Parse text for hashtags and mentions to update their styling
                _processPostText(text);
                setState(() {});
              },
              buildCounter:
                  (
                    _, {
                    required currentLength,
                    maxLength,
                    required isFocused,
                  }) => null,
            ),

            // Display selected images
            if (_selectedImages.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                height: 100.0,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          width: 100.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Process post text to apply bold styling to hashtags and mentions
  void _processPostText(String text) {
    // This method will be used to process the text and identify hashtags/mentions
    // In a real app, you would implement a more sophisticated approach to style the text
    // For this example, we're keeping it simple to modify the TextEditingController
    // Note: In a production app, you would use a specialized widget for rich text editing
  }

  // Get icon for selected visibility
  Widget _getVisibilityIcon(String visibility) {
    IconData iconData;
    switch (visibility) {
      case 'Everyone':
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

    // Try to create a handle from the email first
    if (profile.email.isNotEmpty) {
      // Extract username part from email (before the @)
      final username = profile.email.split('@').first;
      return '@$username';
    }

    // Fallback to using the full name if email is not available
    if (profile.fullName != null && profile.fullName!.isNotEmpty) {
      // Remove spaces and take first 10 chars
      String nameBased = profile.fullName!.replaceAll(' ', '');
      if (nameBased.length > 10) {
        nameBased = nameBased.substring(0, 10);
      }
      return '@$nameBased';
    }

    // Default fallback
    return '@user';
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

  void _submitPost() async {
    if (_postController.text.trim().isEmpty && _selectedImages.isEmpty) {
      // Don't allow empty posts without any content or images
      Get.snackbar(
        'Empty Post',
        'Please add some text or images to your post',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    List<String> uploadedImageUrls = [];

    try {
      // Upload images to Supabase BEFORE navigating (if any)
      if (_selectedImages.isNotEmpty) {
        print(
          'CreatePostPage: Uploading ${_selectedImages.length} images to Supabase',
        );

        // Check if Supabase is initialized
        if (!SupabaseService.isInitialized) {
          throw Exception(
            'Supabase is not initialized. Please configure Supabase in your app.',
          );
        }

        try {
          // Show in-place loading dialog on create post screen
          Get.dialog(
            WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF5796FF),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Uploading ${_selectedImages.length} image(s)...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please wait',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            barrierDismissible: false,
          );

          uploadedImageUrls = await _storageService.uploadPostImages(
            _selectedImages,
          );

          print(
            'CreatePostPage: Successfully uploaded ${uploadedImageUrls.length} images',
          );
          print('CreatePostPage: URLs: $uploadedImageUrls');

          // Close upload dialog
          Get.back();
        } catch (e) {
          // Close upload dialog if open
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          throw Exception('Failed to upload images: $e');
        }
      }

      // Navigate to feed AFTER successful upload
      Get.back(); // Close create post page
      Get.offAllNamed('/feed'); // Navigate to feed, clearing stack

      // Show creating post progress on feed (much faster now - just API call)
      Get.showSnackbar(
        GetSnackBar(
          message: 'Creating your post...',
          showProgressIndicator: true,
          progressIndicatorBackgroundColor: Colors.white,
          progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(
            Color(0xFF5796FF),
          ),
          duration: Duration(seconds: 10),
          isDismissible: false,
          backgroundColor: Colors.white,
          borderRadius: 0,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          messageText: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5796FF)),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Creating your post...',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          snackPosition: SnackPosition.TOP,
        ),
      );

      // Create post using our post creation service with image URLs
      await _postService.createPost(
        _postController.text,
        _visibility,
        imageUrls: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
      );

      // Dismiss progress snackbar
      Get.closeCurrentSnackbar();

      // Show success snackbar
      Get.showSnackbar(
        GetSnackBar(
          message: 'Post created successfully!',
          icon: Icon(Icons.check_circle, color: Colors.white),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          borderRadius: 0,
          margin: EdgeInsets.zero,
          snackPosition: SnackPosition.TOP,
        ),
      );

      // Reload posts on the feed (silently, without showing skeleton loader)
      try {
        final postController = Get.find<PostController>();
        await postController.loadPosts(showLoading: false);
      } catch (e) {
        print('Error reloading posts: $e');
      }
    } catch (e) {
      // Dismiss any dialogs or snackbars
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.closeCurrentSnackbar();

      // If images were uploaded but post creation failed, clean up
      if (uploadedImageUrls.isNotEmpty) {
        print('CreatePostPage: Cleaning up uploaded images due to error');
        try {
          await _storageService.deletePostImages(uploadedImageUrls);
        } catch (cleanupError) {
          print('CreatePostPage: Error cleaning up images: $cleanupError');
        }
      }

      // Clean error message before showing to user
      String cleanError = ErrorMessageHelper.cleanErrorMessage(e.toString());

      // Show error
      Get.showSnackbar(
        GetSnackBar(
          message: cleanError,
          icon: Icon(Icons.error, color: Colors.white),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.red,
          borderRadius: 0,
          margin: EdgeInsets.zero,
          snackPosition: SnackPosition.TOP,
        ),
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
        title: Text(
          'Create post',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 16,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 16),
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
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      _postController.text.trim().isEmpty
                          ? Color(0xffA4A4A4)
                          : Color(0xff5796FF),
                  minimumSize: Size(30, 32),
                ),
                child: Text(
                  'Post',
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
          SizedBox(width: 14),
        ],
      ),
      body: Column(
        children: [
          // Header divider
          const Divider(height: 1, color: Color(0xffE5E7EB)),
          const SizedBox(height: 20),

          // User profile info
          Obx(() {
            final profile = _profileController.studentProfile.value;
            return ListTile(
              leading: GestureDetector(
                onTap: () {
                  // Navigate to profile page when avatar is clicked
                  Get.to(() => const ProfilePage());
                },
                child: CircleAvatar(
                  backgroundImage:
                      profile?.profilePhotoUrl != null
                          ? MemoryImage(
                            _convertBase64ToImage(profile!.profilePhotoUrl!),
                          )
                          : null,
                  backgroundColor:
                      profile?.profilePhotoUrl == null
                          ? Color(0xff5796FF).withValues(alpha: 0.2)
                          : null,
                  child:
                      profile?.profilePhotoUrl == null
                          ? Icon(
                            Icons.person,
                            color: Color(0xff5796FF).withValues(alpha: 0.7),
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
                      _getVisibilityIcon(_visibility),
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

          // Content area - post text and images
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildRichTextEditor(),
            ),
          ),
          PostCreationToolbar(
            isProject: false,
            onHashtagPressed: () {
              _showHashtagSelector(context);
            },
            onMentionPressed: () {
              _showMentionSelector(context);
            },
            onImagePressed: () {
              _pickImages();
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
