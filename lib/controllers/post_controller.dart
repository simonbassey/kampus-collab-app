import 'package:get/get.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostController extends GetxController {
  final PostService _postService = PostService();
  
  // Observable lists and properties
  RxList<PostModel> posts = <PostModel>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;
  
  // Load all posts
  Future<void> loadPosts() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      // Try to fetch posts from API
      final fetchedPosts = await _postService.getPosts();
      
      // If we got no posts from API and we have no existing posts, add mock ones
      if (fetchedPosts.isEmpty && posts.isEmpty) {
        posts.value = [
          PostModel.mockText(),
          PostModel.mockImage(),
          PostModel.mockLink(),
        ];
        error.value = 'Using mock data - API unavailable';
      } else {
        // Otherwise use the fetched posts
        posts.value = fetchedPosts;
      }
    } catch (e) {
      error.value = e.toString();
      print('Error loading posts: $e');
      
      // If posts list is empty, add some mock posts for testing
      if (posts.isEmpty) {
        posts.value = [
          PostModel.mockText(),
          PostModel.mockImage(),
          PostModel.mockLink(),
        ];
      }
    } finally {
      isLoading.value = false;
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
      
      // Create a fallback post for UI consistency
      try {
        final fallbackPost = PostModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'local',
          userName: 'You',
          userAvatar: 'https://randomuser.me/api/portraits/people/1.jpg',
          userHandle: '@me',
          userRole: 'Student',
          content: content,
          images: mediaUrls ?? [],
          createdAt: DateTime.now(),
          type: contentType == 'Image' ? PostType.image : 
                contentType == 'Link' ? PostType.link : PostType.text,
        );
        
        // Add locally created post
        posts.insert(0, fallbackPost);
        return fallbackPost;
      } catch (innerE) {
        print('Error creating fallback post: $innerE');
        return null;
      }
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
