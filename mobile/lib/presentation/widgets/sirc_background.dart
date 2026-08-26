import 'package:flutter/material.dart';

import '../theme/sirc_theme.dart';

class SircBackground extends StatelessWidget {
  final Widget child;

  const SircBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8FBFF),
                  Color(0xFFEFF7FF),
                  Color(0xFFF7FAFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        const Positioned(
          top: -90,
          right: -70,
          child: _Blob(size: 230, color: Color(0xFFD7ECFF)),
        ),
        const Positioned(
          top: 130,
          left: -95,
          child: _Blob(size: 210, color: Color(0xFFE1F1FF)),
        ),
        const Positioned(
          bottom: 140,
          right: -105,
          child: _Blob(size: 260, color: Color(0xFFDCEBFF)),
        ),
        Positioned(
          bottom: -80,
          left: -50,
          child: Transform.rotate(
            angle: -0.35,
            child: Container(
              width: 210,
              height: 150,
              decoration: BoxDecoration(
                color: SircColors.blueLight.withOpacity(0.10),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
