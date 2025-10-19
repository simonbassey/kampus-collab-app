import 'package:get/get.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostController extends GetxController {
  final PostService _postService = PostService();

  // Observable lists and properties
  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PostModel> userPosts = <PostModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingUserPosts = false.obs;
  RxString error = ''.obs;

  // Load all posts
  Future<void> loadPosts({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    error.value = '';

    try {
      print('PostController: Loading posts...');
      // Try to fetch posts from API
      final fetchedPosts = await _postService.getPosts();

      print(
        'PostController: Received ${fetchedPosts.length} posts from service',
      );

      // Update posts list with fetched data (even if empty)
      posts.value = fetchedPosts;

      if (fetchedPosts.isEmpty) {
        print('PostController: No posts available - showing empty feed');
        error.value = ''; // Clear error since API call was successful
      } else {
        print(
          'PostController: Successfully loaded ${fetchedPosts.length} posts',
        );
      }
    } catch (e) {
      error.value = 'API error: $e';
      print('PostController: Error loading posts: $e');
      // Don't add mock data - let the UI show error state
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  // Load user-specific posts
  Future<void> loadUserPosts(String userId) async {
    isLoadingUserPosts.value = true;
    error.value = '';

    try {
      print('PostController: Loading posts for user: $userId...');

      // Fetch all posts and filter by userId
      final allPosts = await _postService.getPosts();
      final filteredPosts =
          allPosts.where((post) => post.userId == userId).toList();

      print(
        'PostController: Found ${filteredPosts.length} posts for user $userId',
      );

      // Update userPosts list
      userPosts.value = filteredPosts;

      if (filteredPosts.isEmpty) {
        print('PostController: No posts found for this user');
        error.value = '';
      } else {
        print(
          'PostController: Successfully loaded ${filteredPosts.length} user posts',
        );
      }
    } catch (e) {
      error.value = 'Error loading user posts: $e';
      print('PostController: Error loading user posts: $e');
    } finally {
      isLoadingUserPosts.value = false;
    }
  }

  // Create a new post
  Future<PostModel?> createPost({
    required String content,
    String contentType = 'Text',
    List<String>? mediaUrls,
    String audience = 'Public',
    int? parentId,
    String postType = 'Original',
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      // Our PostService will always return something - either from API or locally created
      final newPost = await _postService.createPost(
        content: content,
        contentType: contentType,
        mediaUrls: mediaUrls,
        audience: audience,
        parentId: parentId,
        postType: postType,
      );

      // Add to existing posts at the beginning
      posts.insert(0, newPost);

      return newPost;
    } catch (e) {
      error.value = e.toString();
      print('Error creating post: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get a specific post
  Future<PostModel?> getPostById(int postId) async {
    isLoading.value = true;
    error.value = '';

    try {
      final post = await _postService.getPostById(postId);
      return post;
    } catch (e) {
      error.value = e.toString();
      print('Error getting post: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Like a post
  Future<bool> likePost(String postId) async {
    try {
      final success = await _postService.likePost(postId);

      if (success) {
        // Update the post in our list
        final index = posts.indexWhere((post) => post.id == postId);
        if (index != -1) {
          final updatedPost = posts[index];
          updatedPost.likes++;
          updatedPost.isLiked = true;
          posts[index] = updatedPost; // Trigger UI update
        }
      }

      return success;
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  // Unlike a post
  Future<bool> unlikePost(String postId) async {
    try {
      final success = await _postService.unlikePost(postId);

      if (success) {
        // Update the post in our list
        final index = posts.indexWhere((post) => post.id == postId);
        if (index != -1) {
          final updatedPost = posts[index];
          updatedPost.likes--;
          updatedPost.isLiked = false;
          posts[index] = updatedPost; // Trigger UI update
        }
      }

      return success;
    } catch (e) {
      print('Error unliking post: $e');
      return false;
    }
  }

  // Bookmark a post
  Future<bool> bookmarkPost(String postId) async {
    try {
      final success = await _postService.bookmarkPost(postId);

      if (success) {
        // Update the post in our list
        final index = posts.indexWhere((post) => post.id == postId);
        if (index != -1) {
          final updatedPost = posts[index];
          updatedPost.isBookmarked = true;
          posts[index] = updatedPost; // Trigger UI update
        }
      }

      return success;
    } catch (e) {
      print('Error bookmarking post: $e');
      return false;
    }
  }

  // Unbookmark a post
  Future<bool> unbookmarkPost(String postId) async {
    try {
      final success = await _postService.unbookmarkPost(postId);

      if (success) {
        // Update the post in our list
        final index = posts.indexWhere((post) => post.id == postId);
        if (index != -1) {
          final updatedPost = posts[index];
          updatedPost.isBookmarked = false;
          posts[index] = updatedPost; // Trigger UI update
        }
      }

      return success;
    } catch (e) {
      print('Error unbookmarking post: $e');
      return false;
    }
  }
}
