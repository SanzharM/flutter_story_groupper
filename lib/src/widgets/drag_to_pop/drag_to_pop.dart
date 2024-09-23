import 'dart:math' as math;

import 'package:flutter/material.dart';

class DragToPop extends StatefulWidget {
  final Widget child;

  final void Function()? onDragStart;
  final void Function()? onDragEnd;

  const DragToPop({
    super.key,
    required this.child,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<DragToPop> createState() => _DragToPopState();
}

class _DragToPopState extends State<DragToPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addStatusListener(_onAnimationEnd);

  late Animation<Offset> _animation = Tween<Offset>(
    begin: Offset.zero,
    end: Offset.zero,
  ).animate(_animationController);

  Offset? _dragOffset;
  Offset? _previousPosition;

  @override
  void dispose() {
    _animationController.removeStatusListener(_onAnimationEnd);
    _animationController.dispose();
    super.dispose();
  }

  void _onAnimationEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animationController.reset();
      setState(() {
        _dragOffset = null;
        _previousPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, Widget? child) {
        Offset finalOffset = _dragOffset ?? const Offset(0.0, 0.0);
        if (_animation.status == AnimationStatus.forward) {
          finalOffset = _animation.value;
        }

        final scale = finalOffset.distance == 0.0
            ? 1.0
            : math.min(
                1.0 - (finalOffset.dy / 3000).abs(),
                1.0 - (finalOffset.dx / 1200).abs(),
              );

        return Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: finalOffset,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onScaleStart: _onDragStart,
        onScaleUpdate: _onDragUpdate,
        onScaleEnd: _onOverScrollDragEnd,
        child: widget.child,
      ),
    );
  }

  void _onDragStart(ScaleStartDetails scaleDetails) {
    _previousPosition = scaleDetails.focalPoint;
    widget.onDragStart?.call();
  }

  void _onDragUpdate(ScaleUpdateDetails scaleUpdateDetails) {
    // if (_previousPosition == null) {
    //   _previousPosition = scaleUpdateDetails.focalPoint;
    //   return;
    // }

    final currentPosition = scaleUpdateDetails.focalPoint;
    final previousPosition = _previousPosition!;

    final newX =
        (_dragOffset?.dx ?? 0.0) + (currentPosition.dx - previousPosition.dx);
    final newY =
        (_dragOffset?.dy ?? 0.0) + (currentPosition.dy - previousPosition.dy);
    _previousPosition = currentPosition;

    setState(() {
      _dragOffset = Offset(newX, newY);
    });
  }

  void _onOverScrollDragEnd(ScaleEndDetails? scaleEndDetails) {
    widget.onDragEnd?.call();
    if (_dragOffset == null) return;
    final dragOffset = _dragOffset!;

    final screenSize = MediaQuery.of(context).size;

    if (scaleEndDetails != null) {
      if (dragOffset.dy.abs() >= screenSize.height / 2 ||
          dragOffset.dx.abs() >= screenSize.width / 1.1) {
        Navigator.of(context).pop();
        return;
      }

      final velocity = scaleEndDetails.velocity.pixelsPerSecond;
      final velocityY = velocity.dy;
      final velocityX = velocity.dx;

      if (velocityY.abs() > 500.0 || velocityX.abs() > 400.0) {
        Navigator.of(context).pop();
        return;
      }
    }

    setState(() {
      _animation = Tween<Offset>(
        begin: Offset(dragOffset.dx, dragOffset.dy),
        end: const Offset(0.0, 0.0),
      ).animate(_animationController);
    });

    _animationController.forward();
  }
}

Future<void> pushDragable({
  required BuildContext context,
  required Widget child,
  bool fullscreenDialog = false,
  RouteSettings? settings,
  Duration transitionDuration = const Duration(milliseconds: 200),
  Duration reverseTransitionDuration = const Duration(milliseconds: 450),
  Color? barrierColor,
  String? barrierLabel,
  bool barrierDismissible = false,
  bool maintainState = true,
  void Function()? onDragStart,
  void Function()? onDragEnd,
}) async =>
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        fullscreenDialog: fullscreenDialog,
        opaque: false,
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          secondaryAnimation,
          Widget child,
        ) {
          if (animation.status == AnimationStatus.reverse ||
              animation.status == AnimationStatus.dismissed) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0),
                end: const Offset(0.0, 0.0),
              ).animate(animation),
              child: child,
            );
          }

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1),
              end: const Offset(0.0, 0.0),
            ).animate(animation),
            child: child,
          );
        },
        pageBuilder: (_, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(animation),
            child: Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              child: DragToPop(
                onDragStart: onDragStart,
                onDragEnd: onDragEnd,
                child: child,
              ),
            ),
          );
        },
        maintainState: maintainState,
        barrierColor: Colors.transparent,
        barrierLabel: barrierLabel,
        barrierDismissible: barrierDismissible,
        settings: settings,
      ),
    );
