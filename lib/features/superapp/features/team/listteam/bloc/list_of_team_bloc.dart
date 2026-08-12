import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/domain/usecases/get_internal_teams_use_case.dart';
import '../../../../../../core/domain/usecases/get_komtim_teams_use_case.dart';
import 'list_of_team_event.dart';
import 'list_of_team_state.dart';

class ListOfTeamBloc extends Bloc<ListOfTeamEvent, ListOfTeamState> {
  final GetInternalTeamsUseCase getInternalTeamsUseCase;
  final GetKomtimTeamsUseCase getKomtimTeamsUseCase;

  ListOfTeamBloc({
    required this.getInternalTeamsUseCase,
    required this.getKomtimTeamsUseCase,
  }) : super(const ListOfTeamState()) {
    on<FetchInternalTeamsEvent>(_onFetchInternalTeams);
    on<FetchKomtimTeamsEvent>(_onFetchKomtimTeams);
  }

  Future<void> _onFetchInternalTeams(
    FetchInternalTeamsEvent event,
    Emitter<ListOfTeamState> emit,
  ) async {
    emit(state.copyWith(status: ListOfTeamStatus.loading));
    final result = await getInternalTeamsUseCase(event.search);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ListOfTeamStatus.failure,
        errorMessage: failure.message,
      )),
      (teams) => emit(state.copyWith(
        status: ListOfTeamStatus.success,
        internalTeams: teams,
      )),
    );
  }

  Future<void> _onFetchKomtimTeams(
    FetchKomtimTeamsEvent event,
    Emitter<ListOfTeamState> emit,
  ) async {
    emit(state.copyWith(status: ListOfTeamStatus.loading));
    final result = await getKomtimTeamsUseCase(event.search);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ListOfTeamStatus.failure,
        errorMessage: failure.message,
      )),
      (teams) => emit(state.copyWith(
        status: ListOfTeamStatus.success,
        komtimTeams: teams,
      )),
    );
  }
}
