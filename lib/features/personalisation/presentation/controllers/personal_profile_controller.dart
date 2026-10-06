import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/daos/activities_dao.dart';
import '../../data/repositories/personalisation_repository_impl.dart';
import '../../domain/models/personal_regulation_profile.dart';
import '../../domain/repositories/personalisation_repository.dart';

final activitiesDaoProvider = Provider<ActivitiesDao>((ref) {
  // In pure app context, default in-memory or drift DAO is wired via bootstrap
  return InMemoryActivitiesDao();
});

final personalisationRepositoryProvider = Provider<PersonalisationRepository>((ref) {
  final dao = ref.watch(activitiesDaoProvider);
  return PersonalisationRepositoryImpl(dao);
});

class PersonalProfileState {
  const PersonalProfileState({
    required this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  final PersonalRegulationProfile profile;
  final bool isLoading;
  final String? errorMessage;

  PersonalProfileState copyWith({
    PersonalRegulationProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PersonalProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PersonalProfileController extends StateNotifier<PersonalProfileState> {
  PersonalProfileController(this._repository)
      : super(PersonalProfileState(profile: PersonalRegulationProfile.empty())) {
    loadProfile();
  }

  final PersonalisationRepository _repository;

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> clearHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.clearHistory();
      final freshProfile = await _repository.getProfile();
      state = state.copyWith(profile: freshProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final personalProfileControllerProvider =
    StateNotifierProvider<PersonalProfileController, PersonalProfileState>((ref) {
  final repo = ref.watch(personalisationRepositoryProvider);
  return PersonalProfileController(repo);
});
