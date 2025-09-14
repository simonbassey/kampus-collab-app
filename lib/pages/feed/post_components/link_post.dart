import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import 'post_base.dart';
import 'image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPost extends StatelessWidget {
  final PostModel post;
  final BuildContext? contextOverride;
  final bool isInDetailScreen;
  final GlobalKey _contextHolder = GlobalKey();
  
   LinkPost({
    Key? key,
    required this.post,
    this.contextOverride,
    this.isInDetailScreen = false,
  }) : super(key: key);
  
  BuildContext _getContext() {
    // This is a workaround to access context for showing dialogs from a stateless widget
    if (contextOverride != null) return contextOverride!;
    final context = _contextHolder.currentContext;
    if (context == null) throw Exception('Context is not available');
    return context;
  }

  @override
  Widget build(BuildContext context) {
    return PostBase(
      post: post,
      contentWidget: _buildLinkPreview(),
      isInDetailScreen: isInDetailScreen,
    );
  }

  Widget _buildLinkPreview() {
    if (post.link == null || post.link!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      key: _contextHolder,
      child: _buildLinkContent(),
    );
  }
  
  Widget _buildLinkContent() {
    if (post.link == null || post.link!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Link Preview Image (optional)
          if (post.images.isNotEmpty)
            GestureDetector(
              onTap: () {
                ImageViewer.show(
                  _getContext(),
                  post.images.first,
                  isAsset: true,
                );
              },
              child: Image.asset(
                post.images.first,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          
          // Link Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Link Domain
                Text(
                  _extractDomain(post.link!),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Link Title
                Text(
                  _generateLinkTitle(post.link!),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Link Description (optional)
                Text(
                  'Preview of link content would appear here. This is a placeholder for the actual link preview that would be fetched from the URL metadata.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Link URL
                GestureDetector(
                  onTap: () => _launchURL(post.link!),
                  child: Text(
                    post.link!,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to extract domain from URL
  String _extractDomain(String url) {
    Uri? uri;
    try {
      uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url.split('/')[0];
    }
  }

  // Helper method to generate a title for the link
  String _generateLinkTitle(String url) {
    // In a real app, this would be fetched from the link metadata
    return 'Title of the linked content';
  }
  
  // Launch URL in browser
  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      
      // Try to launch URL
      final bool canLaunch = await canLaunchUrl(url);
      
      if (canLaunch) {
        // Only attempt to launch if canLaunch returns true
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Show error if URL can't be launched
        _showError('Cannot open this URL');
      }
    } catch (e) {
      // Handle platform exceptions (common in simulators)
      if (e.toString().contains('PlatformException') && 
          e.toString().contains('channel-error')) {
        _showError('Cannot open URLs in simulator environment');
      } else {
        _showError('Could not open the link: ${e.toString()}');
      }
    }
  }
  
  void _showError(String message) {
    if (_contextHolder.currentContext != null) {
      ScaffoldMessenger.of(_getContext()).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
