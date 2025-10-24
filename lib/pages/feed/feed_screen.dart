import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkstryq/widgets/custom_bottom_navbar.dart';
import '_widgets/feed_app_bar.dart';
import '_widgets/profile_setup_modal.dart';
import '_widgets/school_people_section.dart';
import '_widgets/post_skeleton_loader.dart';
import 'post_components/text_post.dart';
import 'post_components/image_post.dart';
import 'post_components/link_post.dart';
import '../../models/post_model.dart';
import '../../controllers/post_controller.dart';
import '../indox/inbox_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  // Use GetX controller for posts
  late PostController _postController;

  // Animation controller for arrow
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  // For local state
  List<PostModel> get _posts => _postController.posts;

  // Calculate strategic position for SchoolPeopleSection
  int _getSchoolPeopleSectionPosition() {
    final totalPosts = _posts.length;

    // Strategic placement based on number of posts:
    // 1-2 posts: after post 1 (index 0)
    // 3-5 posts: after post 2 (index 1)
    // 6-8 posts: after post 3 (index 2)
    // 9+ posts: after post 4 (index 3)

    if (totalPosts <= 2) {
      return 1; // After first post
    } else if (totalPosts <= 5) {
      return 2; // After second post
    } else if (totalPosts <= 8) {
      return 3; // After third post
    } else {
      return 4; // After fourth post
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize post controller
    _postController = Get.put(PostController());

    // Initialize arrow animation
    _arrowAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Check if profile needs setup - delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProfileSetupModal.show(context);
      _loadPosts();
    });
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    await _postController.loadPosts();
  }

  Future<void> _refreshPosts() async {
    await _postController.loadPosts();
  }

  Widget _buildPostByType(PostModel post) {
    // Build the appropriate post widget based on post type
    switch (post.type) {
      case PostType.text:
        return TextPost(post: post);
      case PostType.image:
        return ImagePost(post: post);
      case PostType.link:
        return LinkPost(post: post);
    }
  }

  Widget _buildLoadingState() {
    return const PostSkeletonLoaderList(itemCount: 4);
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.post_add_outlined, size: 80, color: Colors.grey[300]),
              SizedBox(height: 24),
              Text(
                'No Posts Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Be the first to share something with your campus community!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              SizedBox(height: 48),
              TextButton.icon(
                onPressed: _refreshPosts,
                icon: Icon(Icons.refresh, color: Color(0xFF5796FF)),
                label: Text(
                  'Refresh',
                  style: TextStyle(
                    color: Color(0xFF5796FF),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SizedBox(height: 80),
              // Visual separator
              Container(height: 1, width: 200, color: Colors.grey[100]),
              SizedBox(height: 32),
              Text(
                'Tap the + button to create your first post',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5796FF),
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 16),
              // Animated arrow pointing down to the FAB
              AnimatedBuilder(
                animation: _arrowAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _arrowAnimation.value),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      size: 48,
                      color: Color(0xFF5796FF),
                    ),
                  );
                },
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _postController.error.value.contains('API error')
                      ? 'Unable to connect to the server. Please check your internet connection.'
                      : _postController.error.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _refreshPosts,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5796FF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Get.to(() => const InboxScreen());
          }
        },
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const FeedAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPosts,
                color: Color(0xFF5796FF),
                backgroundColor: Colors.white,
                displacement: 40.0,
                strokeWidth: 3.0,
                // Use Obx for reactive UI updates
                child: Obx(() {
                  // Loading state (only show when no posts exist yet)
                  if (_postController.isLoading.value &&
                      _postController.posts.isEmpty) {
                    return _buildLoadingState();
                  }

                  // Error state
                  if (_postController.error.value.isNotEmpty &&
                      _postController.posts.isEmpty) {
                    return _buildErrorState();
                  }

                  // Empty state
                  if (_postController.posts.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Posts list with strategically placed SchoolPeopleSection
                  return ListView.builder(
                    itemCount:
                        _posts.length +
                        2, // +2 for SchoolPeopleSection and bottom padding
                    itemBuilder: (context, index) {
                      final schoolPeoplePosition =
                          _getSchoolPeopleSectionPosition();

                      // Show School People Section at strategic position
                      if (index == schoolPeoplePosition) {
                        return const SchoolPeopleSection();
                      }

                      // Bottom padding at the end
                      if (index == _posts.length + 1) {
                        return const SizedBox(height: 40);
                      }

                      // Calculate actual post index
                      // If we're before the school people section, use index as-is
                      // If we're after it, subtract 1 to account for the section
                      final postIndex =
                          index > schoolPeoplePosition ? index - 1 : index;

                      // Make sure we're within bounds
                      if (postIndex >= _posts.length) {
                        return const SizedBox.shrink();
                      }

                      // Build post with divider
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: _buildPostByType(_posts[postIndex]),
                          ),
                          // Add divider after each post (except before SchoolPeopleSection and after last post)
                          if (index != schoolPeoplePosition - 1 &&
                              postIndex < _posts.length - 1)
                            const Divider(
                              color: Color(0xFFF0F0F0),
                              height: 1,
                              thickness: 1,
                            ),
                        ],
                      );
                    },
                  );
                }), // Close the Obx
              ),
            ),
          ],
        ),
      ),
    );
  }
}
