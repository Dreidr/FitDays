  import 'dart:convert';
  import 'package:flutter/services.dart' show rootBundle;

  String titleCase(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;

          return word
              .split('-')
              .map(
                (part) => part.isEmpty
                    ? part
                    : part[0].toUpperCase() + part.substring(1).toLowerCase(),
              )
              .join('-');
        })
        .join(' ');
  }

  class LocalExerciseRepo {
    static List<Map<String, dynamic>>? _cache;
    static Map<String, Map<String, dynamic>>? _byId;

    // ---------
    // Core load
    // ---------
    static Future<List<Map<String, dynamic>>> loadAll() async {
      if (_cache != null) return _cache!;

      final raw = await rootBundle.loadString('assets/data/exercises.json');
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
        final alreadyFitDays =
            ex.containsKey('bodyPart') && ex.containsKey('target');

        if (alreadyFitDays) {
          mapped.add({
            "id": (ex["id"] ?? "").toString(),
            "name": titleCase((ex["name"] ?? "").toString()),
            "bodyPart": (ex["bodyPart"] ?? "").toString(),
            "target": (ex["target"] ?? "").toString(),
            "equipment": (ex["equipment"] ?? "").toString(),
            "videoPath": "assets/videos/${ex['id']}.mp4",
            "category": (ex["category"] ?? "strength").toString(), // ✅ ADD THIS
            "difficulty": (ex["difficulty"] ?? "").toString(),
            "description": (ex["description"] ?? "").toString(),
            "secondaryMuscles": (ex["secondaryMuscles"] is List)
                ? (ex["secondaryMuscles"] as List)
                      .map((e) => e.toString())
                      .toList()
                : <String>[],
            "instructions": (ex["instructions"] is List)
                ? (ex["instructions"] as List).map((e) => e.toString()).toList()
                : <String>[],
          });
          continue;
        }

        // ✅ Otherwise: raw dataset mapping
        final id = (ex['id'] ?? ex['uuid'] ?? ex['name'] ?? '').toString();
        final name = titleCase((ex['name'] ?? '').toString());

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
        final category = (ex['category'] ?? '').toString();

        mapped.add({
          "id": id,
          "name": name,
          "bodyPart": bodyPart,
          "target": bodyPart,
          "equipment": equipment,
          "gifUrl": "",
          "category": category, // ✅ ADD THIS
          "secondaryMuscles": secondary,
          "instructions": instructions,
        });
      }

      _cache = mapped;

      // build index
      _byId = {for (final e in mapped) (e['id'] ?? '').toString(): e};

      return _cache!;
    }

    // -----------------------
    // Query helpers (OFFLINE)
    // -----------------------

    static Future<List<Map<String, dynamic>>> fetchExercisesByIds(
      List<String> ids,
    ) async {
      final exercises = await loadAll();
      final warmups = await loadWarmups();

      final all = [...exercises, ...warmups];

      final byId = <String, Map<String, dynamic>>{
        for (final e in all) (e["id"] ?? "").toString().trim(): e,
      };

      final out = <Map<String, dynamic>>[];

      for (final id in ids) {
        final ex = byId[id.trim()];
        if (ex != null) out.add(ex);
      }

      return out;
    }

    static Future<List<Map<String, dynamic>>> searchByName(String query) async {
      final all = await loadAll();
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return all;

      return all
          .where((e) => (e['name'] ?? '').toString().toLowerCase().contains(q))
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

    static Future<List<Map<String, dynamic>>> byBodyPart(String bodyPart) async {
      final all = await loadAll();
      return all.where((e) => (e['bodyPart'] ?? '') == bodyPart).toList();
    }

    static Future<Map<String, dynamic>?> getById(String id) async {
      if (_byId == null) {
        await loadAll();
      }

      return _byId?[id];
    }

    static List<Map<String, dynamic>>? _warmups;

    static Map<String, dynamic> normalizeWarmup(Map<String, dynamic> ex) {
      ex['name'] = titleCase((ex['name'] ?? '').toString());
      ex['bodyPart'] = titleCase((ex['bodyPart'] ?? '').toString());
      ex['equipment'] = titleCase((ex['equipment'] ?? '').toString());
      ex['target'] = titleCase((ex['target'] ?? '').toString());

      return ex;
    }

    static Future<List<Map<String, dynamic>>> loadWarmups() async {
      if (_warmups != null) return _warmups!;

      final jsonString = await rootBundle.loadString('assets/data/warmups.json');

      final decoded = jsonDecode(jsonString);

      _warmups = List<Map<String, dynamic>>.from(
        decoded,
      ).map(normalizeWarmup).toList();

      // ✅ add warmups into the shared lookup map
      _byId ??= {};

      for (final ex in _warmups!) {
        final id = (ex["id"] ?? "").toString().trim();

        if (id.isNotEmpty) {
          _byId![id] = ex;
        }
      }

      return _warmups!;
    }
  }
