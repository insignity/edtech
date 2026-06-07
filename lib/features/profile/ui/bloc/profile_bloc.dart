import 'package:edtech/features/profile/data/profile_repository.dart';
import 'package:edtech/features/profile/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await repository.fetchProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
