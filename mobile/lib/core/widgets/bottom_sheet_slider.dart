import 'package:flutter/material.dart';

class BottomSheetSlider extends StatelessWidget {
  final String placeholder;
  final String unit;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final double initialValue = 0; // or whatever your default is

  const BottomSheetSlider({
    super.key,
    required this.placeholder,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final selected = await showModalBottomSheet<double>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _SliderSheet(
            title: placeholder,
            unit: unit,
            startValue: value,
            min: min,
            max: max,
            divisions: divisions,
          ),
        );

        if (selected != null) onChanged(selected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 52,
        decoration: BoxDecoration(
          color: value != initialValue
              ? const Color(0xFF4442D9).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (value != null && value != initialValue)
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
                  placeholder,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "${value.toStringAsFixed(1)} $unit",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderSheet extends StatefulWidget {
  final String title;
  final String unit;
  final double startValue;
  final double min;
  final double max;
  final int divisions;

  const _SliderSheet({
    required this.title,
    required this.unit,
    required this.startValue,
    required this.min,
    required this.max,
    required this.divisions,
  });

  @override
  State<_SliderSheet> createState() => _SliderSheetState();
}

class _SliderSheetState extends State<_SliderSheet> {
  late double temp;

  @override
  void initState() {
    super.initState();
    temp = widget.startValue;
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF4442D9);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header row
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 4,
                    ), // space before title
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, temp),
                  child: Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800, // <- heavier DONE
                      color: purple,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // big value
            Text(
              "${temp.toStringAsFixed(1)} ${widget.unit}",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 14),

            // slider theme (FitDays vibe)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: purple,
                inactiveTrackColor: purple.withOpacity(0.2),
                trackHeight: 6,
                thumbColor: purple,
                overlayColor: purple.withOpacity(0.15),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Slider(
                value: temp.clamp(widget.min, widget.max),
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                onChanged: (v) => setState(() => temp = v),
              ),
            ),

            const SizedBox(height: 8),

            // range hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.min.toStringAsFixed(0)} ${widget.unit}",
                  style: const TextStyle(color: Colors.black45),
                ),
                Text(
                  "${widget.max.toStringAsFixed(0)} ${widget.unit}",
                  style: const TextStyle(color: Colors.black45),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
