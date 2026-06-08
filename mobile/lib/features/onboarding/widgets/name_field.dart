import 'package:flutter/material.dart';

class ProfileNameField extends StatelessWidget {
  const ProfileNameField({
    super.key,
    required this.value,
    required this.onChanged,
    this.showBorder = true, // 👈 default ON
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: (value?.trim().isNotEmpty == true)
            ? const Color(0xFF4442D9).withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: showBorder
            ? Border.all(
                color: (value?.trim().isNotEmpty == true)
                    ? const Color(0xFF4442D9)
                    : Colors.black12,
              )
            : null,
      ),
      child: Row(
        children: [
          const Text(
            "Name",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 200,
            child: TextFormField(
              initialValue: value,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: "Your name",
                hintStyle: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
