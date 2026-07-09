part of 'history_page_bloc.dart';

@immutable
abstract class HistoryPageEvent extends Equatable {
  const HistoryPageEvent();

  @override
  List<Object?> get props => [];
}

class RefreshDataEvent extends HistoryPageEvent {
  const RefreshDataEvent();
}

class TransactionHistoryLoad extends HistoryPageEvent {
  final String? type;
  final int offset;
  final int limit;

  const TransactionHistoryLoad({
    this.type,
    required this.offset,
    required this.limit,
  });

  @override
  List<Object?> get props => [
        type,
        offset,
        limit,
      ];
}

class TransactionNeedProcessHistoryLoad extends HistoryPageEvent {
  const TransactionNeedProcessHistoryLoad();

  @override
  List<Object?> get props => [];
}

class ClearHistory extends HistoryPageEvent {
  const ClearHistory();

  @override
  List<Object?> get props => [];
}

class LoadDataDetailTopUpEvent extends HistoryPageEvent {
  const LoadDataDetailTopUpEvent({required this.id});

  final int id;

  @override
  List<Object> get props => [id];
}

class HomePageDidload extends HistoryPageEvent {
  const HomePageDidload();
}
