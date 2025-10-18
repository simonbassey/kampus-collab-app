import 'package:flutter/material.dart';

/// A wrapper widget for displaying network images with proper error and loading handling
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? placeholderColor;
  final IconData? placeholderIcon;
  final double? placeholderIconSize;

  const SafeNetworkImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
    this.placeholderIcon,
    this.placeholderIconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return placeholder ??
            Container(
              width: width,
              height: height,
              color: placeholderColor ?? const Color(0xFFEEF5FF),
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: const Color(0xFF5796FF),
                  strokeWidth: 2,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: placeholderColor ?? const Color(0xFFEEF5FF),
              child: Center(
                child: Icon(
                  placeholderIcon ?? Icons.broken_image,
                  size: placeholderIconSize ?? 40,
                  color: Colors.grey[400],
                ),
              ),
            );
      },
    );
  }
}

/// A circular avatar widget that safely displays network images with fallback
class SafeNetworkAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final IconData fallbackIcon;
  final Color? fallbackIconColor;
  final double? fallbackIconSize;

  const SafeNetworkAvatar({
    Key? key,
    this.imageUrl,
    this.radius = 20.0,
    this.backgroundColor,
    this.fallbackIcon = Icons.person,
    this.fallbackIconColor,
    this.fallbackIconSize,
  }) : super(key: key);

  @override
  State<SafeNetworkAvatar> createState() => _SafeNetworkAvatarState();
}

class _SafeNetworkAvatarState extends State<SafeNetworkAvatar> {
  bool _hasError = false;

  @override
  void didUpdateWidget(SafeNetworkAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset error state if URL changes
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _hasError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValidUrl =
        widget.imageUrl != null && widget.imageUrl!.isNotEmpty && !_hasError;

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? const Color(0xFFEEF5FF),
      backgroundImage: hasValidUrl ? NetworkImage(widget.imageUrl!) : null,
      onBackgroundImageError:
          hasValidUrl
              ? (exception, stackTrace) {
                // Log the error and update state to show fallback
                debugPrint('Error loading avatar image: $exception');
                if (mounted) {
                  setState(() {
                    _hasError = true;
                  });
                }
              }
              : null,
      child:
          !hasValidUrl
              ? Icon(
                widget.fallbackIcon,
                size: widget.fallbackIconSize ?? widget.radius,
                color: widget.fallbackIconColor ?? const Color(0xFF5796FF),
              )
              : null,
    );
  }
}
