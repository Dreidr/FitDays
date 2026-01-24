import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseDbApi {
  static const String host = 'exercisedb.p.rapidapi.com';
  static const String apiKey = 'ac7f5d3b47mshf297bd078c23839p1224f0jsnf7a65920327d'; // TEMP

  // ------------------------------
  // Image cache (prevents reload)
  // ------------------------------
  static final Map<String, Future<Uint8List>> _imageFutureCache = {};

  /// Fetch exercise animation/image
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

      final res = await http.get(
        uri,
        headers: {
          'X-RapidAPI-Key': apiKey,
          'X-RapidAPI-Host': host,
        },
      );

      if (res.statusCode != 200) {
        _imageFutureCache.remove(cacheKey); // allow retry
        throw Exception('Image load failed: ${res.statusCode}');
      }

      return res.bodyBytes;
    });
  }

  // ------------------------------
  // Fetch exercise by ID
  // ------------------------------
  static Future<Map<String, dynamic>> fetchExerciseById(String id) async {
    final uri = Uri.https(host, '/exercises/exercise/$id');

    final res = await http.get(
      uri,
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': host,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('ExerciseById failed: ${res.statusCode}');
    }

    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  static Future<List<Map<String, dynamic>>> fetchExercisesByIds(
  List<String> ids,
) async {
  // small quality: remove empty ids + duplicates but keep order
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

}
