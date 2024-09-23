import 'dart:math' as math show pi;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'cube_scroll_physics.dart';
export 'cube_scroll_physics.dart';

class CubePageView extends StatelessWidget {
  const CubePageView.builder({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    required this.controller,
    this.physics = const CubeScrollPhysics(),
    this.pageSnapping = true,
    this.onPageChanged,
    required this.itemBuilder,
    this.findChildIndexCallback,
    required this.itemCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
  }) : builderConstructor = true;

  final bool allowImplicitScrolling;
  final String? restorationId;
  final Axis scrollDirection;
  final bool reverse;
  final PageController controller;
  final ScrollPhysics? physics;
  final bool pageSnapping;
  final ValueChanged<int>? onPageChanged;
  final NullableIndexedWidgetBuilder itemBuilder;
  final ChildIndexGetter? findChildIndexCallback;
  final int? itemCount;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final ScrollBehavior? scrollBehavior;
  final bool padEnds;
  final bool builderConstructor;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      allowImplicitScrolling: allowImplicitScrolling,
      restorationId: restorationId,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      physics: physics,
      pageSnapping: pageSnapping,
      onPageChanged: onPageChanged,
      itemCount: itemCount,
      findChildIndexCallback: findChildIndexCallback,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            // Current position of the page
            double value = 1.0;
            if (controller.position.haveDimensions) {
              value = controller.page! - index;
              value = (value).clamp(-1, 1);
            }

            // Calculate rotation

            double rotationY = value * math.pi / 2;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective adjustment
                ..rotateY(rotationY),
              child: itemBuilder(context, index),
            );
          },
        );
      },
      dragStartBehavior: dragStartBehavior,
      clipBehavior: clipBehavior,
      scrollBehavior: scrollBehavior,
      padEnds: padEnds,
    );
  }
}
