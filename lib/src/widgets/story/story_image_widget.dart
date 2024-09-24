import 'package:flutter/material.dart';

class StoryImageWidget extends StatefulWidget {
  const StoryImageWidget({
    super.key,
    this.heroTag,
    this.url,
    this.alignment = Alignment.topCenter,
    this.fit = BoxFit.contain,
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(20.0)),
    this.imageLoader,
    this.onLoaded,
    this.onError,
    this.errorLoader,
  });

  final String? heroTag;
  final String? url;
  final Alignment alignment;
  final BoxFit fit;
  final Size? size;
  final BorderRadius borderRadius;
  final Widget? imageLoader;
  final void Function()? onLoaded;
  final Widget? errorLoader;
  final void Function(Object? object)? onError;

  @override
  State<StoryImageWidget> createState() => _StoryImageWidgetState();
}

class _StoryImageWidgetState extends State<StoryImageWidget> {
  late final ImageStreamListener _imageStreamListener;
  late final NetworkImage _imageProvider;
  ImageStream? _imageStream;
  bool _isLoading = true;

  @override
  void initState() {
    _imageProvider = NetworkImage(widget.url ?? '');
    _imageStreamListener = ImageStreamListener(
      (image, synchronousCall) {
        _isLoading = false;
        widget.onLoaded?.call();
      },
    );
    _imageStream = _imageProvider.resolve(const ImageConfiguration())
      ..addListener(_imageStreamListener);
    super.initState();
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageStreamListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isLoading
            ? widget.imageLoader ??
                Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
            : ClipRRect(
                borderRadius: widget.borderRadius,
                child: Hero(
                  tag: widget.heroTag ?? DateTime.now().microsecondsSinceEpoch,
                  child: Image(
                    alignment: Alignment.topCenter,
                    image: _imageProvider,
                    fit: widget.fit,
                    height: widget.size?.height,
                    width: widget.size?.width,
                    errorBuilder: (context, error, stackTrace) {
                      return widget.errorLoader ??
                          Text(
                            error.toString(),
                          );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
