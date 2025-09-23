import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import '../../../pages/profile/view_profile_page.dart';

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String userHandle;
  final String content;
  final DateTime createdAt;
  int likes;
  bool isLiked;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.userHandle,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
    this.replies = const [],
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  // Create a mock comment for testing
  factory CommentModel.mock({
    required String id,
    required String content,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id,
      userId: 'user_$id',
      userName: 'User $id',
      userAvatar: 'https://randomuser.me/api/portraits/men/$id.jpg',
      userHandle: '@user$id',
      content: content,
      createdAt: createdAt ?? DateTime.now().subtract(Duration(hours: int.parse(id))),
      likes: int.parse(id),
    );
  }
}

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final Function(CommentModel)? onReply;
  final bool showReplies;

  const CommentItem({
    Key? key,
    required this.comment,
    this.onReply,
    this.showReplies = false,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  late CommentModel comment;

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
  }

  void _navigateToUserProfile(BuildContext context) {
    // Create a mock post model from the comment data to pass to the profile screen
    final mockPost = PostModel(
      id: comment.id,
      userId: comment.userId,
      userName: comment.userName,
      userAvatar: comment.userAvatar,
      userHandle: comment.userHandle,
      userRole: 'User', // Default since comments may not have role info
      content: comment.content,
      createdAt: comment.createdAt,
      type: PostType.text,
    );
    
    ViewProfilePage.showProfile(context, mockPost);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _navigateToUserProfile(context),
                child: CircleAvatar(
                  radius: 16.0,
                  backgroundImage: NetworkImage(comment.userAvatar),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _navigateToUserProfile(context),
                          child: Text(
                            comment.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          comment.userHandle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.0,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          comment.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      comment.content,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleLike,
                          child: Row(
                            children: [
                              Icon(
                                comment.isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16.0,
                                color: comment.isLiked ? Colors.red : Colors.grey[600],
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                comment.likes.toString(),
                                style: TextStyle(
                                  color: comment.isLiked ? Colors.red : Colors.grey[600],
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        GestureDetector(
                          onTap: () {
                            if (widget.onReply != null) {
                              widget.onReply!(comment);
                            }
                          },
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Show replies if any
          if (widget.showReplies && comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: Column(
                children: comment.replies.map((reply) {
                  return CommentItem(
                    comment: reply,
                    onReply: widget.onReply,
                    showReplies: false, // Prevent deep nesting
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      if (comment.isLiked) {
        comment.likes--;
        comment.isLiked = false;
      } else {
        comment.likes++;
        comment.isLiked = true;
      }
    });
  }
}
