import '../models/gentle_progress_data.dart';

/// Contract for retrieving gentle non-gamified presence and milestone progress.
abstract class GentleProgressRepository {
  Future<GentleProgressData> getProgressData();
}
