import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:inkstryq/widgets/custom_bottom_navbar.dart';
import '_widgets/feed_app_bar.dart';
import '_widgets/profile_setup_modal.dart';
import 'post_components/post_list.dart';
import 'post_components/post_composition.dart';
import '../../models/post_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<PostModel> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if profile needs setup - delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProfileSetupModal.show(context);
      _loadPosts();
    });
  }

  void _loadPosts() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading posts from API
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _posts.addAll([
          PostModel.mockText(),
          PostModel.mockImage(),
          PostModel.mockLink(),
          PostModel.mockText(),
        ]);
        _isLoading = false;
      });
    });
  }

  void _refreshPosts() {
    setState(() {
      _posts.clear();
    });
    _loadPosts();
  }

  void _handleNewPost(PostModel post) {
    setState(() {
      // Add the new post at the beginning of the list
      _posts.insert(0, post);
    });
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
              child: PostList(
                posts: _posts,
                isLoading: _isLoading,
                onRefresh: _refreshPosts,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
