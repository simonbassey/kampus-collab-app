import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final bool isAsset;

  const ImageViewer({
    Key? key, 
    required this.imageUrl,
    this.isAsset = false,
  }) : super(key: key);

  static void show(BuildContext context, String imageUrl, {bool isAsset = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageViewer(imageUrl: imageUrl, isAsset: isAsset),
      ),
    );
  }

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  final double _minScale = 1.0;
  final double _maxScale = 4.0;
  double _currentScale = 1.0;

  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
      
    // Set preferred orientations to allow rotation for better viewing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    
    // Reset orientation when viewer is closed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;
    
    if (_currentScale == _minScale) {
      // Zoom in to where the user double-tapped
      final position = _doubleTapDetails!.localPosition;
      final Matrix4 newMatrix = Matrix4.identity()
        ..translate(-position.dx * (_maxScale - 1), -position.dy * (_maxScale - 1))
        ..scale(_maxScale);
      
      _animateMatrix(_transformationController.value, newMatrix);
      _currentScale = _maxScale;
    } else {
      // Reset to original size
      _animateMatrix(_transformationController.value, Matrix4.identity());
      _currentScale = _minScale;
    }
  }

  void _animateMatrix(Matrix4 from, Matrix4 to) {
    _animation = Matrix4Tween(begin: from, end: to).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: _minScale,
            maxScale: _maxScale,
            onInteractionUpdate: (details) {
              _currentScale = details.scale;
            },
            child: widget.isAsset
                ? Image.asset(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
