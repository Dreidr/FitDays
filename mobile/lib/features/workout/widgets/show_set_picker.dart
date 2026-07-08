import 'package:flutter/material.dart';
import 'package:mobile/core/models/exercise_set.dart';
import 'package:flutter/services.dart';

Future<ExerciseSet?> showSetPicker({
  required BuildContext context,
  required String exerciseName,
  required ExerciseSet initial,
}) {
  int reps = initial.reps;
  double weight = initial.weightKg;

  final repsController = FixedExtentScrollController(initialItem: reps - 1);
  final weightValues = List.generate(121, (i) => i * 2.5);

  final weightController = FixedExtentScrollController(
    initialItem: weightValues.indexOf(weight),
  );
  return showModalBottomSheet<ExerciseSet>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, modalSetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Grabber
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    exerciseName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ListWheelScrollView.useDelegate(
                                controller: repsController,
                                itemExtent: 44,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  modalSetState(() {
                                    reps = index + 1;
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 30,
                                  builder: (_, index) {
                                    final distance = (index - (reps - 1)).abs();

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
                                        duration: const Duration(
                                          milliseconds: 120,
                                        ),
                                        curve: Curves.easeOut,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: fontWeight,
                                          color: Colors.black.withValues(
                                            alpha: opacity,
                                          ),
                                        ),
                                        child: Text("${index + 1} reps"),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              IgnorePointer(
                                child: Container(
                                  height: 44,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ListWheelScrollView.useDelegate(
                                controller: weightController,
                                itemExtent: 44,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  HapticFeedback.selectionClick();

                                  modalSetState(() {
                                    weight = weightValues[index];
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: weightValues.length,

                                  builder: (_, index) {
                                    final selectedIndex = weightValues.indexOf(
                                      weight,
                                    );
                                    final distance = (index - selectedIndex)
                                        .abs();

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
                                        duration: const Duration(
                                          milliseconds: 120,
                                        ),
                                        curve: Curves.easeOut,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: fontWeight,
                                          color: Colors.black.withValues(
                                            alpha: opacity,
                                          ),
                                        ),
                                        child: Text(
                                          "${weightValues[index]} kg",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              IgnorePointer(
                                child: Container(
                                  height: 44,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
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
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: const Color(0xFF4442D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          ExerciseSet(reps: reps, weightKg: weight),
                        );
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
