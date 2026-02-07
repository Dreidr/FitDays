import 'package:flutter/material.dart';
import 'package:mobile/features/workout/services/play_state.dart';

class PlayShortcutIcon extends StatelessWidget {
  final PlayState state;

  const PlayShortcutIcon({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isRest = state == PlayState.restDay;
    final isNotSetup = state == PlayState.notSetup;

    // Base icon (muted on rest day)
    final icon = Icon(
      Icons.play_arrow_rounded,
      size: 28,
      color: isRest ? Colors.black.withOpacity(0.35) : Colors.black87,
    );

    // Badge (top-right)
    Widget? badge;
    if (isRest) {
      badge = _Badge(text: "Zz");
    } else if (isNotSetup) {
      badge = const _Badge(text: "!");
    }

    if (badge == null) return icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -2,
          top: -6,
          child: badge,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
