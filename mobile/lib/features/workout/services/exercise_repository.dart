import 'package:mobile/features/workout/services/local_exercise_repo.dart';
import 'package:mobile/features/workout/services/exercise_db_api.dart';

class ExerciseRepository {
  // Toggle later (settings / remote config)
  static bool useApi = false;

  static Future<List<Map<String, dynamic>>> byIds(List<String> ids) async {
    if (useApi) {
      return ExerciseDbApi.fetchExercisesByIds(ids);
    }
    return LocalExerciseRepo.fetchExercisesByIds(ids);
  }
}
