import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A wrapper around SvgPicture that handles errors gracefully
class SafeSvg extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Widget Function(BuildContext)? errorBuilder;

  const SafeSvg({
    Key? key,
    required this.assetName,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.errorBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      color: color,
      placeholderBuilder: (BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorBuilder: (context, exception, stackTrace) {
        // Log the error
        debugPrint('Error loading SVG: $assetName - $exception');
        
        // Use custom error builder if provided or fallback to a simple icon
        return errorBuilder != null 
            ? errorBuilder!(context) 
            : Icon(
                Icons.broken_image,
                size: width ?? 24,
                color: color ?? Colors.grey,
              );
      },
    );
  }
  
  /// Static method for loading an SVG asset safely
  static Widget asset(
    String assetName, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    Widget Function(BuildContext)? errorBuilder,
  }) {
    return SafeSvg(
      assetName: assetName,
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: errorBuilder,
    );
  }
}
