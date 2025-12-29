import 'package:flutter/material.dart';

class SlideFade extends StatefulWidget {
  const SlideFade({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.offset = const Offset(0, 0.15),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;

  // ✅ edit these to change the effect
  final Duration delay;
  final Duration duration;
  final Offset offset; // (0, 0.15) = slide up from below
  final Curve curve;

  @override
  State<SlideFade> createState() => _SlideFadeState();
}

class _SlideFadeState extends State<SlideFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fade = CurvedAnimation(parent: _controller, curve: widget.curve);

    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant SlideFade oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If you change duration/curve/offset in code while running,
    // easiest is Hot Restart. This keeps it simple.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
