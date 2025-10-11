import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLinkPreview extends StatelessWidget {
  final String url;

  const UrlLinkPreview({
    Key? key,
    required this.url,
  }) : super(key: key);

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return 'Link';
    }
  }

  String _cleanUrl(String url) {
    // Remove protocol and trailing slash for display
    String clean = url.replaceFirst(RegExp(r'https?://'), '');
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    // Truncate if too long
    if (clean.length > 50) {
      clean = '${clean.substring(0, 47)}...';
    }
    return clean;
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: Container(
        margin: const EdgeInsets.only(top: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FA),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: const Color(0xFFE1E8ED),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Link icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5796FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: const Icon(
                Icons.link,
                color: Color(0xFF5796FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12.0),
            // URL info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _extractDomain(url),
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _cleanUrl(url),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // External link icon
            const Icon(
              Icons.open_in_new,
              color: Color(0xFF5796FF),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

