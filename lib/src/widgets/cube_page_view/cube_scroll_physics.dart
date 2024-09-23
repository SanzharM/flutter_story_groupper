import 'package:flutter/material.dart';

class CubeScrollPhysics extends ScrollPhysics {
  const CubeScrollPhysics({
    super.parent,
  });

  @override
  CubeScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CubeScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // This function modifies the drag behavior
    return offset / 1.5; // You can tweak this to adjust the drag speed
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Custom behavior at boundaries
    return super.applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // Ballistic simulation controls the snapping effect
    final Tolerance tolerance = toleranceFor(position);
    if ((velocity.abs() <= tolerance.velocity)) {
      return super.createBallisticSimulation(position, velocity);
    }

    return super.createBallisticSimulation(position, velocity);
  }
}
