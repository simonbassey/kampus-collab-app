import 'dart:convert';
import '../services/api_service.dart';

class CommentService {
  final ApiService _apiService = ApiService();

  // Get comments for a post
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await _apiService.get('/api/posts/$postId/comments');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] is List) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        } else {
          throw Exception('Invalid data format for comments');
        }
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting comments: $e');
      throw Exception('Failed to load comments: $e');
    }
  }

  // Add a comment to a post
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final body = json.encode({
        'content': content,
        'parentId': parentCommentId,
      });

      final response = await _apiService.post(
        '/api/posts/$postId/comments',
        body,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception('Failed to add comment: Invalid response data');
        }
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  // Like a comment
  Future<bool> likeComment(String postId, String commentId) async {
    try {
      final response = await _apiService.post(
        '/api/posts/$postId/comments/$commentId/like',
        null,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error liking comment: $e');
      return false;
    }
  }

  // Unlike a comment
  Future<bool> unlikeComment(String postId, String commentId) async {
    try {
      final response = await _apiService.delete('/api/posts/$postId/comments/$commentId/like');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error unliking comment: $e');
      return false;
    }
  }
  
  // Delete a comment
  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      final response = await _apiService.delete('/api/posts/$postId/comments/$commentId');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }
}
