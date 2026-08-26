import 'package:equatable/equatable.dart';

import '../../../../../../core/domain/entities/team_member_model.dart';

enum ListOfTeamStatus { initial, loading, success, failure }

class ListOfTeamState extends Equatable {
  final ListOfTeamStatus status;
  final List<TeamMemberModel> internalTeams;
  final List<TeamMemberModel> komtimTeams;
  final String errorMessage;

  const ListOfTeamState({
    this.status = ListOfTeamStatus.initial,
    this.internalTeams = const [],
    this.komtimTeams = const [],
    this.errorMessage = '',
  });

  ListOfTeamState copyWith({
    ListOfTeamStatus? status,
    List<TeamMemberModel>? internalTeams,
    List<TeamMemberModel>? komtimTeams,
    String? errorMessage,
  }) {
    return ListOfTeamState(
      status: status ?? this.status,
      internalTeams: internalTeams ?? this.internalTeams,
      komtimTeams: komtimTeams ?? this.komtimTeams,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, internalTeams, komtimTeams, errorMessage];
}
