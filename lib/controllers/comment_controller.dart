import 'package:get/get.dart';
import '../services/comment_service.dart';
import '../pages/feed/post_components/comment_item.dart';

class CommentController extends GetxController {
  final CommentService _commentService = CommentService();
  
  // Observable lists and properties
  RxList<CommentModel> comments = <CommentModel>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;
  RxString currentPostId = ''.obs;
  
  // Load comments for a post
  Future<void> loadComments(String postId) async {
    isLoading.value = true;
    error.value = '';
    currentPostId.value = postId;
    
    try {
      final fetchedComments = await _commentService.getComments(postId);
      
      // Map API response to CommentModel objects
      final List<CommentModel> parsedComments = fetchedComments.map((commentJson) {
        final replies = commentJson['replies'] != null 
            ? (commentJson['replies'] as List)
                .map((reply) => _parseCommentData(reply, postId))
                .toList()
            : <CommentModel>[];
                
        return _parseCommentData(commentJson, postId, replies: replies);
      }).toList();
      
      comments.value = parsedComments;
    } catch (e) {
      error.value = e.toString();
      print('Error loading comments: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Helper method to parse comment data
  CommentModel _parseCommentData(Map<String, dynamic> data, String postId, {List<CommentModel>? replies}) {
    return CommentModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userAvatar: data['userAvatar'] ?? 'https://via.placeholder.com/150',
      userHandle: data['userHandle'] ?? '@user',
      content: data['content'] ?? '',
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
      likes: data['likesCount'] ?? 0,
      replies: replies ?? [],
    );
  }
  
  // Add a comment to the current post
  Future<CommentModel?> addComment({
    required String content,
    String? parentCommentId,
  }) async {
    if (currentPostId.isEmpty) {
      error.value = 'No active post selected';
      return null;
    }
    
    isLoading.value = true;
    error.value = '';
    
    try {
      final commentData = await _commentService.addComment(
        postId: currentPostId.value,
        content: content,
        parentCommentId: parentCommentId,
      );
      
      // Create a new comment model
      final newComment = _parseCommentData(commentData, currentPostId.value);
      
      // Add to the comments list appropriately
      if (parentCommentId == null) {
        // Add as a top-level comment
        comments.insert(0, newComment);
      } else {
        // Find the parent comment and add as a reply
        final parentIndex = comments.indexWhere((c) => c.id == parentCommentId);
        if (parentIndex != -1) {
          comments[parentIndex].replies.add(newComment);
          // Create a new list to trigger reactivity
          comments.refresh();
        }
      }
      
      return newComment;
    } catch (e) {
      error.value = e.toString();
      print('Error adding comment: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Like a comment
  Future<bool> likeComment(String commentId) async {
    try {
      final success = await _commentService.likeComment(
        currentPostId.value,
        commentId,
      );
      
      if (success) {
        _updateCommentLikeStatus(commentId, true);
      }
      
      return success;
    } catch (e) {
      print('Error liking comment: $e');
      return false;
    }
  }
  
  // Unlike a comment
  Future<bool> unlikeComment(String commentId) async {
    try {
      final success = await _commentService.unlikeComment(
        currentPostId.value,
        commentId,
      );
      
      if (success) {
        _updateCommentLikeStatus(commentId, false);
      }
      
      return success;
    } catch (e) {
      print('Error unliking comment: $e');
      return false;
    }
  }
  
  // Helper method to update like status in local comments list
  void _updateCommentLikeStatus(String commentId, bool isLiked) {
    // Search in top-level comments
    final index = comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      final comment = comments[index];
      if (isLiked && !comment.isLiked) {
        comment.likes++;
        comment.isLiked = true;
      } else if (!isLiked && comment.isLiked) {
        comment.likes--;
        comment.isLiked = false;
      }
      comments.refresh();
      return;
    }
    
    // Search in replies if not found at top level
    for (final comment in comments) {
      final replyIndex = comment.replies.indexWhere((r) => r.id == commentId);
      if (replyIndex != -1) {
        final reply = comment.replies[replyIndex];
        if (isLiked && !reply.isLiked) {
          reply.likes++;
          reply.isLiked = true;
        } else if (!isLiked && reply.isLiked) {
          reply.likes--;
          reply.isLiked = false;
        }
        comments.refresh();
        return;
      }
    }
  }
  
  // Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      final success = await _commentService.deleteComment(
        currentPostId.value,
        commentId,
      );
      
      if (success) {
        // Remove from local list
        comments.removeWhere((c) => c.id == commentId);
        
        // Check in replies as well
        for (final comment in comments) {
          comment.replies.removeWhere((r) => r.id == commentId);
        }
        
        comments.refresh();
      }
      
      return success;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }
}
