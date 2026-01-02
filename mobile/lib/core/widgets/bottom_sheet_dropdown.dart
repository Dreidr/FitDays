import 'package:flutter/material.dart';

class BottomSheetDropdown extends StatelessWidget {
  const BottomSheetDropdown({
    super.key,
    required this.placeholder,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon = Icons.chevron_right,
    this.showBorder = true, // 👈 default ON
  });

  final String placeholder;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final selected = await _showPicker(context);
            if (selected != null) onChanged(selected);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: (value?.isNotEmpty == true)
                  ? const Color(0xFF4442D9).withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: showBorder
                  ? Border.all(
                      color: (value?.isNotEmpty == true)
                          ? const Color(0xFF4442D9)
                          : Colors.black12,
                    )
                  : null,
            ),

            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _showPicker(BuildContext context) async {
    String? temp = value;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
        
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // top grabber
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        temp ?? placeholder,
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4442D9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // options
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final item = options[index];
                      final isSelected = item == temp;

                      return InkWell(
                        onTap: () {
                          temp = item;
                          (context as Element).markNeedsBuild();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 24,
                              ), // left spacer (balances check)

                              Expanded(
                                child: Center(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 56,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Color(0xFF4442D9),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
        );
      },
    );
  }
}
