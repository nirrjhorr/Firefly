import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activities/presentation/providers/activity_providers.dart';
import '../../../journaling/data/repositories/journal_repository_impl.dart';
import '../../../loneliness_comfort/presentation/controllers/loneliness_comfort_controller.dart';
import '../../data/repositories/gentle_progress_repository_impl.dart';
import '../../domain/models/gentle_progress_data.dart';
import '../../domain/repositories/gentle_progress_repository.dart';

/// Provider for [GentleProgressRepository], wired to available feature DAOs.
final gentleProgressRepositoryProvider = Provider<GentleProgressRepository>((ref) {
  final journalDao = ref.watch(journalDaoProvider);
  final lonelinessDao = ref.watch(lonelinessComfortDaoProvider);
  final activitiesDao = ref.watch(activitiesDaoProvider);

  return GentleProgressRepositoryImpl(
    journalDao: journalDao,
    lonelinessDao: lonelinessDao,
    activitiesDao: activitiesDao,
  );
});

/// Riverpod FutureProvider / StateNotifier for gentle progress data.
final gentleProgressControllerProvider =
    StateNotifierProvider<GentleProgressController, AsyncValue<GentleProgressData>>(
        (ref) {
  final repo = ref.watch(gentleProgressRepositoryProvider);
  return GentleProgressController(repo);
});

/// Controller managing asynchronous loading and refresh of gentle progress state.
class GentleProgressController
    extends StateNotifier<AsyncValue<GentleProgressData>> {
  GentleProgressController(this._repository)
      : super(const AsyncValue.loading()) {
    refresh();
  }

  final GentleProgressRepository _repository;

  Future<void> refresh() async {
    try {
      final data = await _repository.getProgressData();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
