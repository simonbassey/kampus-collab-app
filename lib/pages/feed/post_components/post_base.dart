import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../models/post_model.dart';
import 'post_detail_screen.dart';
import '../../../pages/profile/view_profile_page.dart';

class PostBase extends StatefulWidget {
  final PostModel post;
  final Widget? contentWidget;
  final bool isInDetailScreen;

  const PostBase({
    Key? key,
    required this.post,
    this.contentWidget,
    this.isInDetailScreen = false,
  }) : super(key: key);

  @override
  State<PostBase> createState() => _PostBaseState();
}

class _PostBaseState extends State<PostBase> {
  late PostModel post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Only navigate to detail screen if not already in detail screen
        if (!widget.isInDetailScreen) {
          PostDetailScreen.show(context, post);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(left: 55.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                      if (widget.contentWidget != null) ...[
                        const SizedBox(height: 12.0),
                        widget.contentWidget!,
                      ],
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            _buildInteractionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _navigateToUserProfile(),
          child: CircleAvatar(
            radius: 20.0,
            backgroundImage: NetworkImage(post.userAvatar),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToUserProfile(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        color: Color(0xff333333),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      post.userHandle,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        color: Color(0xff333333),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _formatPostTime(post.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12.0),
                    ),
                    const SizedBox(width: 16.0),
                    // University logo
                    if (post.universityLogo != null) ...[
                      _buildUniversityLogo(),
                      const SizedBox(width: 4.0),
                    ],
                    // University name (role)
                    Text(
                      post.userRole,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        IconButton(
          icon: const Icon(Icons.more_horiz),
          color: const Color(0xff28303F),
          onPressed: _showPostOptions,
          splashRadius: 20.0,
        ),
      ],
    );
  }

  Widget _buildInteractionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _wrapWithContainer(
          _buildInteractionButton(
            post.isLiked ? Icons.favorite : Icons.favorite_border,
            post.likes.toString(),
            iconColor: post.isLiked ? Colors.red : null,
            onTap: _handleLike,
          ),
        ),
        SizedBox(width: 20),
        _wrapWithContainer(
          _buildInteractionButton(
            Icons.comment_outlined,
            post.comments.toString(),
            onTap: _handleComment,
          ),
        ),
        SizedBox(width: 20),
        _wrapWithContainer(
          _buildInteractionButton(
            Icons.share_outlined,
            post.shares.toString(),
            onTap: _handleShare,
          ),
        ),
      ],
    );
  }

  Widget _wrapWithContainer(Widget child) {
    return Container(
      width: 85,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: const Color(0xffF0F0F0).withValues(alpha: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: child,
      ),
    );
  }

  void _handleLike() {
    setState(() {
      if (post.isLiked) {
        post.likes--;
        post.isLiked = false;
      } else {
        post.likes++;
        post.isLiked = true;
      }
    });
  }

  void _handleComment() {
    // Navigate to post details screen where comments can be made
    // Set focusCommentInput to true to trigger keyboard automatically
    if (!widget.isInDetailScreen) {
      PostDetailScreen.show(context, post, focusCommentInput: true);
    }
  }

  void _handleShare() {
    // Show share options
    setState(() {
      post.shares++;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post shared!')));
  }

  void _handleBookmark() {
    setState(() {
      post.isBookmarked = !post.isBookmarked;
    });

    if (post.isBookmarked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post saved to bookmarks')));
    }
  }

  void _navigateToUserProfile() {
    // Navigate to the user profile screen
    ViewProfilePage.showProfile(context, post);
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('View ${post.userName}\'s profile'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToUserProfile();
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
                      // Here you would call a callback to delete the post from the list
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String count, {
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon, size: 20.0, color: iconColor),
            onPressed: onTap,
            splashRadius: 20.0,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 2.0),
          Text(
            count,
            style: TextStyle(
              color: iconColor ?? Colors.grey[600],
              fontSize: 14.0,
            ),
          ),
          const SizedBox(width: 2.0), // Add space at the end as well
        ],
      ),
    );
  }

  Widget _buildUniversityLogo() {
    return SizedBox(
      width: 16,
      height: 16,
      child: Builder(
        builder: (context) {
          try {
            // Check if the logo is SVG or regular image
            if (post.universityLogo!.endsWith('.svg')) {
              return SvgPicture.asset(
                post.universityLogo!,
                width: 16,
                height: 16,
                placeholderBuilder:
                    (context) =>
                        Icon(Icons.school, size: 16, color: Colors.grey[600]),
              );
            } else {
              return Image.asset(
                post.universityLogo!,
                width: 16,
                height: 16,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.school, size: 16, color: Colors.grey[600]);
                },
              );
            }
          } catch (e) {
            // Fallback to a default icon if anything goes wrong
            return Icon(Icons.school, size: 16, color: Colors.grey[600]);
          }
        },
      ),
    );
  }

  String _formatPostTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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
}
