import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocalExerciseRepo {
  static List<Map<String, dynamic>>? _cache;
  static Map<String, Map<String, dynamic>>? _byId;

  // ---------
  // Core load
  // ---------
  static Future<List<Map<String, dynamic>>> loadAll() async {
  if (_cache != null) return _cache!;

  final raw = await rootBundle.loadString('assets/data/exercises_gym.json'); // <-- see note below
  final decoded = jsonDecode(raw);

  late final List<dynamic> list;
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map && decoded['exercises'] is List) {
    list = decoded['exercises'] as List<dynamic>;
  } else {
    throw const FormatException('Unexpected JSON shape');
  }

  final mapped = <Map<String, dynamic>>[];

  for (final item in list) {
    final ex = Map<String, dynamic>.from(item as Map);

    // ✅ If already curated (FitDays-shaped), keep as-is (just normalize types)
    final alreadyFitDays = ex.containsKey('bodyPart') && ex.containsKey('target');

    if (alreadyFitDays) {
      mapped.add({
        "id": (ex["id"] ?? "").toString(),
        "name": (ex["name"] ?? "").toString(),
        "bodyPart": (ex["bodyPart"] ?? "").toString(),
        "target": (ex["target"] ?? "").toString(),
        "equipment": (ex["equipment"] ?? "").toString(),
        "gifUrl": (ex["gifUrl"] ?? "").toString(),
        "secondaryMuscles": (ex["secondaryMuscles"] is List)
            ? (ex["secondaryMuscles"] as List).map((e) => e.toString()).toList()
            : <String>[],
        "instructions": (ex["instructions"] is List)
            ? (ex["instructions"] as List).map((e) => e.toString()).toList()
            : <String>[],
      });
      continue;
    }

    // ✅ Otherwise: raw dataset mapping
    final id = (ex['id'] ?? ex['uuid'] ?? ex['name'] ?? '').toString();
    final name = (ex['name'] ?? '').toString();

    final primary = (ex['primaryMuscles'] is List)
        ? (ex['primaryMuscles'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final secondary = (ex['secondaryMuscles'] is List)
        ? (ex['secondaryMuscles'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final instructions = (ex['instructions'] is List)
        ? (ex['instructions'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final bodyPart = primary.isNotEmpty ? primary.first : "other";
    final equipment = (ex['equipment'] ?? '').toString();

    mapped.add({
      "id": id,
      "name": name,
      "bodyPart": bodyPart,
      "target": bodyPart,
      "equipment": equipment,
      "gifUrl": "",
      "secondaryMuscles": secondary,
      "instructions": instructions,
    });
  }

  _cache = mapped;

  // build index
  _byId = {
    for (final e in mapped) (e['id'] ?? '').toString(): e,
  };

  return _cache!;
}


  // -----------------------
  // Query helpers (OFFLINE)
  // -----------------------

  static Future<List<Map<String, dynamic>>> fetchExercisesByIds(
    List<String> ids,
  ) async {
    if (_byId == null) await loadAll();

    final out = <Map<String, dynamic>>[];
    for (final id in ids) {
      final ex = _byId![id.trim()];
      if (ex != null) out.add(ex);
    }
    return out;
  }

  static Future<List<Map<String, dynamic>>> searchByName(String query) async {
    final all = await loadAll();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;

    return all
        .where((e) =>
            (e['name'] ?? '').toString().toLowerCase().contains(q))
        .toList();
  }

  static Future<List<String>> bodyParts() async {
  final all = await loadAll();
  final parts = <String>{};

  for (final e in all) {
    final bp = (e['bodyPart'] ?? '').toString().trim();
    if (bp.isNotEmpty) parts.add(bp);
  }

  final list = parts.toList()..sort();
  return list;
}


  static Future<List<Map<String, dynamic>>> byBodyPart(
    String bodyPart,
  ) async {
    final all = await loadAll();
    return all
        .where((e) => (e['bodyPart'] ?? '') == bodyPart)
        .toList();
  }
}
