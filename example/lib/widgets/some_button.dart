import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SomeButton extends StatelessWidget {
  const SomeButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.maxFinite,
      child: CupertinoButton(
        pressedOpacity: 0.75,
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        color: Theme.of(context).primaryColor,
        onPressed: onPressed,
        child: Text(
          'More details',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.apply(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
