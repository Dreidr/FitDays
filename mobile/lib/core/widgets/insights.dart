import 'package:flutter/material.dart';

class InsightsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text("Insights / Rituals"),
      ),
    );
  }
}
