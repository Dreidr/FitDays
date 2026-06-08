import 'package:flutter/material.dart';

void showTopToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) =>
        _TopToast(message: message, onDone: () => entry.remove()),
  );

  overlay.insert(entry);
}

class _TopToast extends StatefulWidget {
  const _TopToast({required this.message, required this.onDone});
  final String message;
  final VoidCallback onDone;

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast> {
  double _y = -20;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();

    // animate in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _y = 0;
        _opacity = 1;
      });

      // stay a bit, then animate out
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        setState(() {
          _y = -20;
          _opacity = 0;
        });
        Future.delayed(const Duration(milliseconds: 220), () {
          if (mounted) widget.onDone();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // 👈 key line: doesn't block taps behind it
      ignoring: true,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              offset: Offset(0, _y / 60), // tiny slide
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _opacity,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Stack(
                            alignment: Alignment.center,
                            children: const [
                              // spinning ring
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.green,
                                  ),
                                ),
                              ),

                              // center icon
                              Icon(
                                Icons.fitness_center, // or Icons.monitor_heart
                                size: 10,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 6),
                        Text(
                          widget.message,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
