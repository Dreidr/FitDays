bool usesWeight(Map<String, dynamic> exercise) {
  final equipment =
      (exercise["equipment"] ?? "").toString().toLowerCase();

  return equipment != "body weight";
}