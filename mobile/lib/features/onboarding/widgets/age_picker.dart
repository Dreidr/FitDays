import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AgePickerField extends StatelessWidget {
  const AgePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.showBorder = true, // 👈 default ON
    this.isSelected = false,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final bool showBorder;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await _showAgePicker(context, value ?? 25);
        if (selected != null) onChanged(selected);
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4442D9).withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: showBorder
              ? Border.all(
                  color: isSelected ? const Color(0xFF4442D9) : Colors.black12,
                )
              : null,
        ),

        child: Row(
          children: [
            const Text(
              "Age",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              value?.toString() ?? "Select",
              style: TextStyle(
                fontSize: 16,
                color: value == null ? Colors.black38 : Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Future<int?> _showAgePicker(BuildContext context, int initial) {
    final controller = FixedExtentScrollController(initialItem: initial - 18);

    int temp = initial;

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 10, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // grabber
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),

                  Row(
                    children: [
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Age",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, temp),
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4442D9),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ListWheelScrollView.useDelegate(
                          controller: controller,
                          itemExtent: 44,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            HapticFeedback.selectionClick();

                            modalSetState(() {
                              temp = 18 + index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 63,
                            builder: (_, index) {
                              final age = 18 + index;
                              final selectedAge = temp;
                              final distance = (age - selectedAge).abs();
                              double opacity;
                              double fontSize;
                              FontWeight fontWeight;

                              if (distance == 0) {
                                opacity = 1.0;
                                fontSize = 20;
                                fontWeight = FontWeight.w500;
                              } else if (distance == 1) {
                                opacity = 0.65;
                                fontSize = 20;
                                fontWeight = FontWeight.w500;
                              } else if (distance == 2) {
                                opacity = 0.35;
                                fontSize = 18;
                                fontWeight = FontWeight.w500;
                              } else {
                                opacity = 0.15;
                                fontSize = 16;
                                fontWeight = FontWeight.w500;
                              }
                              return Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 120),
                                  curve: Curves.easeOut,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: fontWeight,
                                    color: Colors.black.withValues(
                                      alpha: opacity,
                                    ),
                                  ),
                                  child: Text(age.toString()),
                                ),
                              );
                            },
                          ),
                        ),

                        // 👇 selection highlight
                        IgnorePointer(
                          child: Container(
                            height: 44,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
