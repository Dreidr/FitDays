class ActiveWorkoutSession {
  final String workoutId;
  final String dayLabel;
  final String title;
  final int exerciseIndex;
  final int setIndex;
  final int elapsedSeconds;
  final bool isResting;
  final int restLeft;
  final int warmupCount;
  final DateTime updatedAt;

  const ActiveWorkoutSession({
    required this.workoutId,
    required this.dayLabel,
    required this.title,
    required this.exerciseIndex,
    required this.setIndex,
    required this.elapsedSeconds,
    required this.isResting,
    required this.restLeft,
    required this.warmupCount,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'dayLabel': dayLabel,
      'title': title,
      'exerciseIndex': exerciseIndex,
      'setIndex': setIndex,
      'elapsedSeconds': elapsedSeconds,
      'isResting': isResting,
      'restLeft': restLeft,
      'warmupCount': warmupCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ActiveWorkoutSession.fromJson(Map<String, dynamic> json) {
    return ActiveWorkoutSession(
      workoutId: json['workoutId'] as String,
      dayLabel: json['dayLabel'] as String,
      title: json['title'] as String,
      exerciseIndex: json['exerciseIndex'] as int,
      setIndex: json['setIndex'] as int,
      elapsedSeconds: json['elapsedSeconds'] as int,
      isResting: json['isResting'] as bool,
      restLeft: json['restLeft'] as int,
      warmupCount: json['warmupCount'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  ActiveWorkoutSession copyWith({
    int? exerciseIndex,
    int? setIndex,
    int? elapsedSeconds,
    bool? isResting,
    int? restLeft,
    DateTime? updatedAt,
  }) {
    return ActiveWorkoutSession(
      workoutId: workoutId,
      dayLabel: dayLabel,
      title: title,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      setIndex: setIndex ?? this.setIndex,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isResting: isResting ?? this.isResting,
      restLeft: restLeft ?? this.restLeft,
      warmupCount: warmupCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}