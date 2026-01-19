import 'package:flutter/material.dart';
import 'package:mobile/core/services/local_storage_services.dart';

class InsightsCard extends StatelessWidget {
  const InsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Insights / Rituals"),

          const SizedBox(height: 12),

          // ⚠️ TEMP DEV BUTTON — REMOVE BEFORE RELEASE
          TextButton(
            onPressed: () async {
              await LocalStorageService.clearAll();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Local storage cleared")),
              );
            },
            child: const Text(
              "DEV: Reset App",
              style: TextStyle(
                fontSize: 12,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
