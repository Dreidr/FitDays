import 'package:flutter/material.dart';
import 'package:mobile/core/services/local_storage_services.dart';

class WorkoutCompletionService {
  static Set<DateTime> getCompletedDates() {
    return LocalStorageService.getCompletedDays()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  static bool isCompleted(DateTime date) {
    return getCompletedDates().contains(
      DateUtils.dateOnly(date),
    );
  }
}