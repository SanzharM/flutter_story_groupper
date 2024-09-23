import 'package:flutter/material.dart';

class GestureWrapper extends StatelessWidget {
  const GestureWrapper({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.child,
  });

  final void Function() onPrevious;
  final void Function() onNext;
  final void Function() onLongPressStart;
  final void Function() onLongPressEnd;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (child != null) child!,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: onPrevious,
                onLongPressStart: (_) => onLongPressStart(),
                onLongPressEnd: (_) => onLongPressEnd(),
                child: SizedBox.expand(
                  child: ColoredBox(
                    color: Colors.white.withOpacity(0.01),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onNext,
                onLongPressStart: (_) => onLongPressStart(),
                onLongPressEnd: (_) => onLongPressEnd(),
                child: SizedBox.expand(
                  child: ColoredBox(
                    color: Colors.white.withOpacity(0.01),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
