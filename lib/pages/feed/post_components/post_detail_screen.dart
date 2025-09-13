import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import 'post_base.dart';
import 'text_post.dart';
import 'image_post.dart';
import 'link_post.dart';
import 'comment_item.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  static void show(BuildContext context, PostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostModel post;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  final List<CommentModel> _comments = [];
  CommentModel? _replyingTo;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    _loadComments();
  }
  
  void _loadComments() {
    // Mock comments data
    _comments.addAll([
      CommentModel.mock(
        id: '1',
        content: 'Great post! Thanks for sharing.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommentModel.mock(
        id: '2',
        content: 'I agree with this. Very insightful!',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CommentModel.mock(
        id: '3',
        content: 'This is exactly what I needed. Keep up the good work!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ]);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(
              post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: post.isBookmarked ? Theme.of(context).primaryColor : null,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showPostOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPost(),
                  const Divider(height: 1),
                  _buildCommentsList(),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPost() {
    switch (post.type) {
      case PostType.text:
        return TextPost(post: post);
      case PostType.image:
        return ImagePost(post: post);
      case PostType.link:
        return LinkPost(post: post);
      default:
        return TextPost(post: post);
    }
  }

  Widget _buildCommentsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '(${_comments.length})',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (_replyingTo != null)
                GestureDetector(
                  onTap: () => setState(() => _replyingTo = null),
                  child: Text(
                    'Cancel Reply',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (_replyingTo != null) ...[  
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingTo!.userName}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16.0),
                    onPressed: () => setState(() => _replyingTo = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16.0),
          // Comments list
          ..._comments.map((comment) => CommentItem(
            comment: comment,
            onReply: (comment) {
              setState(() {
                _replyingTo = comment;
                // Focus the comment input
                FocusScope.of(context).requestFocus(FocusNode());
              });
            },
            showReplies: true,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16.0,
            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: _isSubmittingComment
                ? const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : Icon(
                    Icons.send,
                    color: Theme.of(context).primaryColor,
                  ),
            onPressed: _isSubmittingComment ? null : _submitComment,
          ),
        ],
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      post.isBookmarked = !post.isBookmarked;
    });
    
    if (post.isBookmarked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post saved to bookmarks')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post removed from bookmarks')),
      );
    }
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing post...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post reported')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block user'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User blocked')),
                );
              },
            ),
            if (post.userId == '1') // Assuming '1' is the current user's ID
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete post'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted')),
                  );
                  // Navigate back after deletion
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _submitComment() {
    final commentText = _commentController.text.trim();
    
    if (commentText.isEmpty) {
      return;
    }
    
    setState(() {
      _isSubmittingComment = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      final newComment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1', // Current user ID
        userName: 'Current User',
        userAvatar: 'https://randomuser.me/api/portraits/men/1.jpg',
        userHandle: '@user',
        content: commentText,
        createdAt: DateTime.now(),
      );

      setState(() {
        _isSubmittingComment = false;
        post.comments++;
        _commentController.clear();
        
        if (_replyingTo != null) {
          // Add as a reply to the selected comment
          final commentIndex = _comments.indexOf(_replyingTo!);
          if (commentIndex != -1) {
            _comments[commentIndex].replies.add(newComment);
          }
          _replyingTo = null;
        } else {
          // Add as a new top-level comment
          _comments.insert(0, newComment);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added')),
      );
    });
  }
}
