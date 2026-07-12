import 'package:edtech/features/profile/data/profile_repository.dart';
import 'package:edtech/features/profile/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<DeleteAccount>(_onDeleteAccount);
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

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<ProfileState> emit,
  ) async {
    final previous = state;
    emit(ProfileDeleting());
    try {
      await repository.deleteAccount();
      emit(ProfileDeleted());
    } catch (e) {
      emit(ProfileDeleteError(e.toString()));
      // restore profile view so the user isn't stuck on an error state
      if (previous is ProfileLoaded) emit(previous);
    }
  }
}
