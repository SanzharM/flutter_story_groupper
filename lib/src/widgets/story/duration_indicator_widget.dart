import 'package:flutter/material.dart';

class DurationIndicatorWidget extends StatelessWidget {
  const DurationIndicatorWidget({
    super.key,
    required this.itemCount,
    required this.activeIndex,
    required this.itemValue,
    required this.itemMaxValue,
    this.activeColor,
    this.inactiveColor,
    this.height,
    this.spaceBetween,
    this.borderRadius = const BorderRadius.all(Radius.circular(10.0)),
  });

  final int itemCount;
  final int activeIndex;
  final int itemValue;
  final int itemMaxValue;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? height;
  final double? spaceBetween;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final double height = this.height ?? 4.0;
    final double spaceBetween = this.spaceBetween ?? 4.0;
    final Color activeColor = this.activeColor ?? Colors.white;
    final Color inactiveColor = this.inactiveColor ?? Colors.white54;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        double itemWidth = maxWidth / itemCount;
        if (itemCount == 2) {
          itemWidth -= spaceBetween;
        } else if (itemCount > 3) {
          itemWidth -= spaceBetween * 2;
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: height,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (int i = 0; i < itemCount; i++) ...[
                Expanded(
                  child: _IndicatorItemWidget(
                    borderRadius: borderRadius,
                    itemValue: itemValue,
                    itemMaxValue: itemMaxValue,
                    itemWidth: itemWidth,
                    activeIndex: activeIndex,
                    index: i,
                    inactiveColor: inactiveColor,
                    activeColor: activeColor,
                  ),
                ),
                if (i + 1 < itemCount) ...[
                  SizedBox(width: spaceBetween),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _IndicatorItemWidget extends StatelessWidget {
  const _IndicatorItemWidget({
    required this.itemValue,
    required this.itemMaxValue,
    required this.itemWidth,
    required this.index,
    required this.activeIndex,
    required this.inactiveColor,
    required this.activeColor,
    required this.borderRadius,
  });

  final int itemValue;
  final int itemMaxValue;
  final double itemWidth;
  final int index;
  final int activeIndex;
  final Color inactiveColor;
  final Color activeColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    // itemValue = X
    // itemMaxValue = 100
    double indicatorFillPercentage = itemValue * 100 / itemMaxValue;
    double indicatorWidth = indicatorFillPercentage * itemWidth / 100;
    if (indicatorWidth.isNegative) {
      indicatorWidth = 0;
    }
    return SizedBox(
      height: double.maxFinite,
      width: itemWidth,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            ColoredBox(
              color: inactiveColor,
              child: const SizedBox.expand(),
            ),
            if (index < activeIndex)
              ColoredBox(
                color: activeColor,
                child: const SizedBox.expand(),
              )
            else if (index == activeIndex)
              RepaintBoundary(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: double.maxFinite,
                  width: indicatorWidth,
                  color: activeColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
