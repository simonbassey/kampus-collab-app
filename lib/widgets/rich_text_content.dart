import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class RichTextContent extends StatelessWidget {
  final String content;
  final TextStyle? style;
  final Function(String)? onUrlDetected;

  const RichTextContent({
    Key? key,
    required this.content,
    this.style,
    this.onUrlDetected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Detect URLs in content for preview
    _detectUrls(content);
    
    return RichText(
      text: TextSpan(
        style: style ?? const TextStyle(fontSize: 14.0, color: Colors.black87),
        children: _parseContent(content),
      ),
    );
  }

  void _detectUrls(String text) {
    final urlPattern = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    final matches = urlPattern.allMatches(text);
    
    if (matches.isNotEmpty && onUrlDetected != null) {
      // Notify parent widget about the first URL found
      final firstUrl = matches.first.group(0);
      if (firstUrl != null) {
        onUrlDetected!(firstUrl);
      }
    }
  }

  List<TextSpan> _parseContent(String text) {
    final List<TextSpan> spans = [];

    // Regular expression to match URLs, hashtags, and mentions
    final pattern = RegExp(
      r'(https?://[^\s]+|#\w+|@\w+)',
      caseSensitive: false,
    );
    final matches = pattern.allMatches(text);

    int currentPosition = 0;

    for (final match in matches) {
      // Add normal text before the match
      if (match.start > currentPosition) {
        spans.add(TextSpan(text: text.substring(currentPosition, match.start)));
      }

      final matchedText = match.group(0)!;
      
      // Check if it's a URL
      if (matchedText.startsWith('http://') || matchedText.startsWith('https://')) {
        // Handle URL
        spans.add(
          TextSpan(
            text: matchedText,
            style: const TextStyle(
              color: Color(0xFF5796FF),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.parse(matchedText);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
        );
      } else {
        // Handle hashtag or mention
        final isHashtag = matchedText.startsWith('#');
        final searchQuery = matchedText.substring(1); // Remove # or @

        spans.add(
          TextSpan(
            text: matchedText,
            style: const TextStyle(
              color: Color(0xFF5796FF),
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Navigate to search page with the query
                Get.toNamed(
                  '/feed-search',
                  arguments: {
                    'searchQuery': searchQuery,
                    'type': isHashtag ? 'hashtag' : 'mention',
                  },
                );
              },
          ),
        );
      }

      currentPosition = match.end;
    }

    // Add remaining text
    if (currentPosition < text.length) {
      spans.add(TextSpan(text: text.substring(currentPosition)));
    }

    return spans;
  }
}
