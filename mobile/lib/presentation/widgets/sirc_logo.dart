import 'package:flutter/material.dart';

class SircLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const SircLogo({
    super.key,
    this.size = 52,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/icon/logosinfondo.png',
      width: showText ? size : size * 1.8,
      height: size,
      fit: BoxFit.contain,
    );

    if (!showText) return image;

    return image;
  }
}
