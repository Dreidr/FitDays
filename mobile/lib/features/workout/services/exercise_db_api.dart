import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ExerciseDbApi {
  static const String host = 'exercisedb.p.rapidapi.com';

  // ⚠️ TEMP only. Move to dart-define / env later.
  static const String apiKey =
      'ac7f5d3b47mshf297bd078c23839p1224f0jsnf7a65920327d';

  static Map<String, String> get _headers => {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': host,
      };

  // ------------------------------
  // Image cache (prevents reload)
  // ------------------------------
  static final Map<String, Future<Uint8List>> _imageFutureCache = {};

  static Future<Uint8List> fetchImageBytes({
    required String exerciseId,
    String resolution = '180',
  }) {
    final cacheKey = '$exerciseId@$resolution';

    return _imageFutureCache.putIfAbsent(cacheKey, () async {
      final uri = Uri.https(host, '/image', {
        'resolution': resolution,
        'exerciseId': exerciseId,
      });

      final res = await http.get(uri, headers: _headers);

      if (res.statusCode != 200) {
        _imageFutureCache.remove(cacheKey); // allow retry
        throw Exception('Image load failed: ${res.statusCode} ${res.body}');
      }

      return res.bodyBytes;
    });
  }

  // ------------------------------
  // Core JSON GET helper (safe)
  // ------------------------------
 static Future<dynamic> _getJson(
  String path, {
  Map<String, String>? query,
}) async {
  final uri = Uri.https(host, path, query);

  final res = await http
      .get(uri, headers: _headers)
      .timeout(const Duration(seconds: 20));

  if (res.statusCode == 429) {
    throw Exception('QUOTA_EXCEEDED');
  }

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception('HTTP ${res.statusCode} $path: ${res.body}');
  }

  return jsonDecode(res.body);
}


  // ------------------------------
  // Safe casting helpers
  // ------------------------------
  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    throw const FormatException('Expected JSON object');
  }

  static List<dynamic> _asList(dynamic v) {
    if (v is List) return v;
    throw const FormatException('Expected JSON list');
  }

  // ------------------------------
  // Fetch exercise by ID
  // ------------------------------
  static Future<Map<String, dynamic>> fetchExerciseById(String id) async {
    final decoded = await _getJson('/exercises/exercise/$id');
    return _asMap(decoded);
  }

  static Future<List<Map<String, dynamic>>> fetchExercisesByIds(
    List<String> ids,
  ) async {
    final cleaned = <String>[];
    final seen = <String>{};

    for (final id in ids) {
      final v = id.trim();
      if (v.isEmpty) continue;
      if (seen.add(v)) cleaned.add(v);
    }

    final futures = cleaned.map(fetchExerciseById).toList();
    return Future.wait(futures);
  }

  // ------------------------------
  // ✅ NEW: get all body parts (this fixes your “only 3 types” problem)
  // ------------------------------
  static Future<List<String>> fetchBodyParts() async {
    final decoded = await _getJson('/exercises/bodyPartList');
    final list = _asList(decoded);
    return list.map((e) => e.toString()).toList();
  }

  // ------------------------------
  // ✅ NEW: exercises by body part (returns MANY exercises)
  // ------------------------------
  static Future<List<Map<String, dynamic>>> fetchExercisesByBodyPart(
    String bodyPart, {
    int? limit,
    int? offset,
  }) async {
    final query = <String, String>{};
    if (limit != null) query['limit'] = '$limit';
    if (offset != null) query['offset'] = '$offset';

    final decoded = await _getJson('/exercises/bodyPart/$bodyPart', query: query);
    final list = _asList(decoded);
    return list.map((e) => _asMap(e)).toList();
  }

  // ------------------------------
  // ✅ NEW: fetch all exercises (pagination)
  // ------------------------------
  static Future<List<Map<String, dynamic>>> fetchAllExercises({
    int limit = 50,
    int offset = 0,
  }) async {
    final decoded = await _getJson('/exercises', query: {
      'limit': '$limit',
      'offset': '$offset',
    });

    final list = _asList(decoded);
    return list.map((e) => _asMap(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> searchByName(
  String name, {
  int limit = 30,
  int offset = 0,
}) async {
  final q = name.trim();
  if (q.isEmpty) return [];

  final decoded = await _getJson('/exercises/name/$q', query: {
    'limit': '$limit',
    'offset': '$offset',
  });

  final list = _asList(decoded);
  return list.map((e) => _asMap(e)).toList();
}
}

