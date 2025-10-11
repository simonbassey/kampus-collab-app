import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../controllers/auth_controller.dart';

class PostService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Get all posts - handle paginated API response
  Future<List<PostModel>> getPosts({int page = 0, int pageSize = 20}) async {
    try {
      print('Fetching posts from API...');
      final response = await _apiService.get(
        '/api/posts?page=$page&pageSize=$pageSize',
      );

      print('GET Posts Response Status: ${response.statusCode}');
      print('GET Posts Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Handle paginated response format: {"posts": [], "totalCount": 0, "page": 0, "pageSize": 20, "hasMore": false}
        if (data is Map && data['posts'] is List) {
          List<dynamic> postsList = data['posts'] as List;

          print('Found ${postsList.length} posts from API');
          print('Total count: ${data['totalCount']}');
          print('Has more: ${data['hasMore']}');

          if (postsList.isEmpty) {
            print('No posts available from API');
            return [];
          }

          // Convert to PostModel objects
          return postsList
              .map((postJson) => PostModel.fromJson(postJson))
              .toList();
        }
        // Fallback: Handle other response formats
        else if (data is List) {
          // If the API returns a direct list
          return data.map((postJson) => PostModel.fromJson(postJson)).toList();
        } else if (data is Map && data['data'] is List) {
          // If the API returns a wrapper object with 'data' field containing posts
          List<dynamic> postsList = data['data'] as List;
          return postsList
              .map((postJson) => PostModel.fromJson(postJson))
              .toList();
        } else {
          // If no valid data format, return empty list instead of throwing
          print(
            'Invalid or empty response format for posts: ${data.runtimeType}',
          );
          return [];
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - token expired or invalid
        print('401 Unauthorized: Logging out user...');
        _handleUnauthorized();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        // No posts found - empty list instead of error
        print('No posts found (404)');
        return [];
      } else {
        print('Failed to load posts: Status code ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting posts: $e');
      // Return empty list to allow mock data fallback
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
      final Map<String, dynamic> requestBody = {
        'content': content,
        'contentType': contentType,
        'mediaUrls': mediaUrls ?? [],
        'audience': audience,
        'postType': postType,
      };

      // Only include parentId if it's not null and not 0 (for replies/comments)
      if (parentId != null && parentId != 0) {
        requestBody['parentId'] = parentId;
      }

      print('Creating post with body: ${json.encode(requestBody)}');
      final body = json.encode(requestBody);

      final response = await _apiService.post('/api/posts', body);

      print('POST Create Response Status: ${response.statusCode}');
      print('POST Create Response Body: ${response.body}');

      if (response.statusCode == 401) {
        // Unauthorized - token expired or invalid
        print('401 Unauthorized: Logging out user...');
        _handleUnauthorized();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        // Try to parse the response
        if (response.body.isEmpty) {
          print('Warning: Empty response body from post creation');
          throw Exception('Empty response from server');
        }

        final dynamic data = json.decode(response.body);
        Map<String, dynamic> postData;

        // Handle different response formats
        if (data is Map && data['data'] != null) {
          postData = Map<String, dynamic>.from(data['data'] as Map);
          print('Post created successfully - extracted from data field');
        } else if (data is Map) {
          postData = Map<String, dynamic>.from(data);
          print('Post created successfully - using direct map');
        } else {
          print('Unexpected response format: ${data.runtimeType}');
          throw Exception('Unexpected response format');
        }

        return PostModel.fromJson(postData);
      } else {
        print('Failed to create post: Status code ${response.statusCode}');
        print('Error response: ${response.body}');
        throw Exception(
          'Failed to create post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating post: $e');
      rethrow; // Re-throw to let the controller handle it
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

  // Handle 401 Unauthorized - logout user
  void _handleUnauthorized() {
    try {
      // Get AuthController and logout
      final authController = Get.find<AuthController>();

      // Show message to user
      Get.snackbar(
        'Session Expired',
        'Your session has expired. Please log in again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF5252),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
      );

      // Logout user (this will redirect to login screen)
      authController.logout();
    } catch (e) {
      print('Error handling unauthorized: $e');
      // If AuthController not found, clear token and navigate to login directly
      _authService.clearToken();
      Get.offAllNamed('/login');
    }
  }
}
