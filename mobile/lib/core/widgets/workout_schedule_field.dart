import 'package:flutter/material.dart';

class WorkoutScheduleField extends StatelessWidget {
  const WorkoutScheduleField({
    super.key,
    required this.placeholder,
    required this.value,
    required this.onChanged,
  });

  final String placeholder;
  final List<String> value; // selected days
  final ValueChanged<List<String>> onChanged;

  static const _days = <String>[
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  @override
  Widget build(BuildContext context) {
    final display = value.isEmpty ? placeholder : value.join(", ");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final selected = await _openSchedulePicker(context, value);
            if (selected != null) onChanged(selected);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 52,
            decoration: BoxDecoration(
              color: value.isNotEmpty
                  ? const Color(0xFF4442D9).withOpacity(0.08) // selected
                  : Colors.white, // empty
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value.isNotEmpty
                    ? const Color(0xFF4442D9)
                    : Colors.black12,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      display,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: value.isEmpty ? Colors.black : Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<String>?> _openSchedulePicker(
    BuildContext context,
    List<String> current,
  ) {
    final initial = current.toList();

    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true, // allows taller sheets
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4 , // 👈 60% height (change this)
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return _WorkoutSchedulePicker(
            initialSelected: initial,
            scrollController: scrollController, // add param
          );
        },
      ),
    );
  }
}

class _WorkoutSchedulePicker extends StatefulWidget {
  const _WorkoutSchedulePicker({
    required this.initialSelected,
    required this.scrollController,
  });

  final List<String> initialSelected;
  final ScrollController scrollController;

  @override
  State<_WorkoutSchedulePicker> createState() => _WorkoutSchedulePickerState();
}

class _WorkoutSchedulePickerState extends State<_WorkoutSchedulePicker> {
  static const days = <String>["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  late final Set<String> selected = widget.initialSelected.toSet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Workout Schedule",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.pop(context, selected.toList()),
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
            ),

            // 🔹 Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController, // 👈 still works
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select your workout days",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: days.map((day) {
                        final isOn = selected.contains(day);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isOn) {
                                selected.remove(day);
                              } else {
                                selected.add(day);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isOn
                                  ? const Color(0xFF4442D9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isOn
                                    ? const Color(0xFF4442D9)
                                    : Colors.black12,
                              ),
                            ),
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isOn ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        _PresetButton(
                          text: "Mon–Fri",
                          onTap: () => setState(() {
                            selected
                              ..clear()
                              ..addAll(["Mon", "Tue", "Wed", "Thu", "Fri"]);
                          }),
                        ),
                        const SizedBox(width: 10),
                        _PresetButton(
                          text: "All days",
                          onTap: () => setState(() {
                            selected
                              ..clear()
                              ..addAll(days);
                          }),
                        ),
                        const SizedBox(width: 10),
                        _PresetButton(
                          text: "Clear",
                          onTap: () => setState(selected.clear),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
