import 'package:equatable/equatable.dart';

abstract class ListOfTeamEvent extends Equatable {
  const ListOfTeamEvent();

  @override
  List<Object?> get props => [];
}

class FetchInternalTeamsEvent extends ListOfTeamEvent {
  final String search;
  const FetchInternalTeamsEvent({this.search = ''});

  @override
  List<Object?> get props => [search];
}

class FetchKomtimTeamsEvent extends ListOfTeamEvent {
  final String search;
  const FetchKomtimTeamsEvent({this.search = ''});

  @override
  List<Object?> get props => [search];
}
