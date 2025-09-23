import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:inkstryq/widgets/custom_bottom_navbar.dart';
import '_widgets/feed_app_bar.dart';
import '_widgets/profile_setup_modal.dart';
import '_widgets/school_people_section.dart';
import 'post_components/post_composition.dart';
import 'post_components/text_post.dart';
import 'post_components/image_post.dart';
import 'post_components/link_post.dart';
import '../../models/post_model.dart';
import '../../controllers/post_controller.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Use GetX controller for posts
  late PostController _postController;
  
  // For local state
  List<PostModel> get _posts => _postController.posts;

  @override
  void initState() {
    super.initState();
    
    // Initialize post controller
    _postController = Get.put(PostController());
    
    // Check if profile needs setup - delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProfileSetupModal.show(context);
      _loadPosts();
    });
  }

  void _loadPosts() async {
    try {
      // Use the actual API endpoint
      await _postController.loadPosts();
      
      // If no posts are returned from API, add some mock posts for testing
      if (_posts.isEmpty) {
        // Add mock posts for testing until the API returns actual data
        _postController.posts.addAll([
          PostModel.mockText(),
          PostModel.mockImage(),
          PostModel.mockLink(),
          PostModel.mockText(),
        ]);
      }
    } catch (error) {
      print('Error loading posts: $error');
      
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load posts: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _refreshPosts() async {
    _postController.posts.clear();
    _loadPosts();
  }

  // Handle creating a new post
  void _handleNewPost(PostModel post) async {
    try {
      // Use the API to create the post
      final newPost = await _postController.createPost(
        content: post.content,
        contentType: post.type == PostType.image ? 'Image' : 
                    post.type == PostType.link ? 'Link' : 'Text',
        mediaUrls: post.images,
      );
      
      // If API call fails, fall back to adding the local post
      if (newPost == null) {
        _postController.posts.insert(0, post);
      }
    } catch (error) {
      // In case of error, add the post locally anyway
      _postController.posts.insert(0, post);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post saved locally. Could not sync with server: $error')),
      );
    }
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

    // This is technically unreachable, but we need it to satisfy the compiler
    // since we're not using an exhaustive switch with enum
    return TextPost(post: post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {},
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const FeedAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refreshPosts();
                },
                // Use Obx for reactive UI updates
                child: Obx(() {
                  if (_postController.isLoading.value && _postController.posts.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return ListView(
                          children: [
                            // First post (if available)
                            if (_posts.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: _buildPostByType(_posts[0]),
                              ),

                            // People in your school section after first post
                            const SchoolPeopleSection(),

                            // Rest of the posts
                            SizedBox(
                              // Calculate height to fit the rest of the screen
                              height:
                                  MediaQuery.of(context).size.height -
                                  (kToolbarHeight + // AppBar
                                      MediaQuery.of(
                                        context,
                                      ).padding.top + // Status bar
                                      kBottomNavigationBarHeight + // Bottom nav
                                      400), // School people section + first post + margins
                              child:
                                  _posts.length <= 1
                                      ? Center(
                                        child: Text('No more posts to display'),
                                      )
                                      : ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                        itemCount: _posts.length - 1,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        separatorBuilder:
                                            (context, index) => Divider(
                                              color: const Color(0xFFF0F0F0),
                                              height: 1,
                                              thickness: 1,
                                            ),
                                        itemBuilder: (context, index) {
                                          // Add +1 to index since we're skipping the first post
                                          return _buildPostByType(
                                            _posts[index + 1],
                                          );
                                        },
                                      ),
                            ),
                          ],
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
