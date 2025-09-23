import 'dart:convert';
import '../models/post_model.dart';
import '../services/api_service.dart';

class PostService {
  final ApiService _apiService = ApiService();

  // Get all posts - handle both potential API response formats
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _apiService.get('/api/posts');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> postsList;

        // Handle different potential API response formats
        if (data is List) {
          // If the API returns a direct list
          postsList = data;
        } else if (data is Map && data['data'] is List) {
          // If the API returns a wrapper object with 'data' field containing posts
          postsList = data['data'] as List;
        } else if (data is Map) {
          // If API returns a single post as an object
          postsList = [data];
        } else {
          // If no valid data format, return empty list instead of throwing
          print('Invalid or empty response format for posts');
          return [];
        }

        // Convert to PostModel objects
        return postsList
            .map((postJson) => PostModel.fromJson(postJson))
            .toList();
      } else if (response.statusCode == 404) {
        // No posts found - empty list instead of error
        return [];
      } else {
        print('Failed to load posts: Status code ${response.statusCode}');
        throw Exception('Failed to load posts: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting posts: $e');
      // For now, we'll return an empty list instead of throwing an exception
      // This allows the app to function with mock data when API is unavailable
      return [];
    }
  }

  // Get a specific post by ID
  Future<PostModel> getPostById(int postId) async {
    try {
      final response = await _apiService.get('/api/posts/$postId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null) {
          return PostModel.fromJson(data['data']);
        } else {
          throw Exception('Post not found');
        }
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting post: $e');
      throw Exception('Failed to load post: $e');
    }
  }

  // Create a new post with simplified API structure
  Future<PostModel> createPost({
    required String content,
    String contentType = 'Text',
    List<String>? mediaUrls,
    String audience = 'Public',
    int? parentId,
    String postType = 'Original',
  }) async {
    try {
      // Prepare request body according to simplified API structure
      final body = json.encode({
        'content': content,
        'contentType': contentType,
        'mediaUrls': mediaUrls ?? [],
        'audience': audience,
        'parentId': parentId ?? 0,
        'postType': postType,
      });

      final response = await _apiService.post('/api/posts', body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Try to parse the response
        final dynamic data = json.decode(response.body);
        Map<String, dynamic> postData;

        // Handle different response formats
        if (data is Map && data['data'] != null) {
          postData = Map<String, dynamic>.from(data['data'] as Map);
        } else if (data is Map) {
          postData = Map<String, dynamic>.from(data);
        } else {
          // If we can't parse the response, create a local post object
          postData = {
            'content': content,
            'contentType': contentType,
            'mediaUrls': mediaUrls ?? [],
            'audience': audience,
            'parentId': parentId ?? 0,
            'postType': postType,
            // Add a timestamp as ID
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
          };
        }

        return PostModel.fromJson(postData);
      } else {
        print('Failed to create post: Status code ${response.statusCode}');

        // Create a local post with the provided content for UI consistency
        final localPostData = {
          'content': content,
          'contentType': contentType,
          'mediaUrls': mediaUrls ?? [],
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
        };

        return PostModel.fromJson(localPostData);
      }
    } catch (e) {
      print('Error creating post: $e');

      // Create a local post with the provided content for UI consistency
      final localPostData = {
        'content': content,
        'contentType': contentType,
        'mediaUrls': mediaUrls ?? [],
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      return PostModel.fromJson(localPostData);
    }
  }

  // Like a post
  Future<bool> likePost(String postId) async {
    try {
      final response = await _apiService.post('/api/posts/$postId/like', null);

      return response.statusCode == 200;
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  // Unlike a post
  Future<bool> unlikePost(String postId) async {
    try {
      final response = await _apiService.delete('/api/posts/$postId/like');

      return response.statusCode == 200;
    } catch (e) {
      print('Error unliking post: $e');
      return false;
    }
  }

  // Bookmark a post
  Future<bool> bookmarkPost(String postId) async {
    try {
      final response = await _apiService.post(
        '/api/posts/$postId/bookmark',
        null,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error bookmarking post: $e');
      return false;
    }
  }

  // Remove bookmark
  Future<bool> unbookmarkPost(String postId) async {
    try {
      final response = await _apiService.delete('/api/posts/$postId/bookmark');

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing bookmark: $e');
      return false;
    }
  }
}
