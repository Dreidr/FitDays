import 'package:mobile/core/models/user_profile.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/workout/models/day_plan.dart';

enum PlayState { ready, restDay, notSetup, notGenerated }

class PlayStateResult {
  final PlayState state;
  final String? workoutId; // only when ready or notGenerated on workout day
  final DayPlan? plan;     // today’s plan (if applicable)

  const PlayStateResult({
    required this.state,
    this.workoutId,
    this.plan,
  });
}

class PlayStateResolver {
  static String _dayLabel(DateTime date) {
    const labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return labels[date.weekday - 1];
  }

  /// Deterministic workout id for "Option A" (today/tomorrow/day+2)
  static String workoutIdFor(DateTime day, DayPlan plan) {
    final d = DateTime(day.year, day.month, day.day);
    final yyyy = d.year.toString();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final slug = plan.title.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
    return "$yyyy-$mm-${dd}_$slug";
  }

  /// You pass in "todayPlan" (you already have this for the banners).
  static PlayStateResult resolveForToday({
    required UserProfile? profile,
    required DayPlan todayPlan,
    DateTime? now,
  }) {
    if (profile == null) {
      return const PlayStateResult(state: PlayState.notSetup);
    }

    final t = now ?? DateTime.now();
    final todayLabel = _dayLabel(t);

    final isWorkoutDay = profile.workoutDays.contains(todayLabel);
    if (!isWorkoutDay) {
      return PlayStateResult(state: PlayState.restDay, plan: todayPlan);
    }

    final id = workoutIdFor(t, todayPlan);
    final saved = LocalStorageService.getSavedWorkoutById(id);

    if (saved != null) {
      return PlayStateResult(state: PlayState.ready, workoutId: id, plan: todayPlan);
    }

    // Edge case: workout day but not generated yet
    return PlayStateResult(state: PlayState.notGenerated, workoutId: id, plan: todayPlan);
  }
}
