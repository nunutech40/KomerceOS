part of 'home_page_bloc.dart';

@immutable
abstract class HomePageEvent extends Equatable {
  const HomePageEvent();

  @override
  List<Object?> get props => [];
}

class NextPressedButtonEvent extends HomePageEvent {
  const NextPressedButtonEvent();
}

class HomePageDidload extends HomePageEvent {
  const HomePageDidload();
}

class GetTalentResult extends HomePageEvent {
  const GetTalentResult();
}

class RefreshDataEvent extends HomePageEvent {
  const RefreshDataEvent();
}

class ClickTopUpButtonEvent extends HomePageEvent {
  final int nominal;

  const ClickTopUpButtonEvent({required this.nominal});

  @override
  List<Object?> get props => [nominal];
}

class LoadDataCecktransactionTopUpEvent extends HomePageEvent {
  final String typeCheckTrasaction;
  const LoadDataCecktransactionTopUpEvent({required this.typeCheckTrasaction});

  @override
  List<Object> get props => [typeCheckTrasaction];
}

class InvoviceListPageDidload extends HomePageEvent {
  final String? type;
  final int offset;
  final int limit;

  const InvoviceListPageDidload({
    this.type,
    required this.offset,
    required this.limit,
  });
}

class GetShoppingListEvent extends HomePageEvent {
  final int? offset;
  final int? limit;
  final String? keyword;
  final String? status;
  final String? startDate;
  final String? endDate;

  const GetShoppingListEvent({
    this.offset,
    this.limit,
    this.keyword,
    this.status,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [offset, limit, status, startDate, endDate];
}

class LogoutButtonPressedEvent extends HomePageEvent {
  const LogoutButtonPressedEvent();
}

class GetFeedEvent extends HomePageEvent {
  final String search;
  final int offset;
  final int limit;

  const GetFeedEvent({
    required this.search,
    required this.offset,
    required this.limit,
  });
  @override
  List<Object?> get props => [search, offset, limit];
}

class GetFeedDetailEvent extends HomePageEvent {
  final int id;

  const GetFeedDetailEvent({
    required this.id,
  });
  @override
  List<Object?> get props => [id];
}

class GetNotificationCountEvent extends HomePageEvent {
  const GetNotificationCountEvent({r});
  @override
  List<Object?> get props => [];
}

class GetTalentRecommendationEvent extends HomePageEvent {
  final int offset;
  final int limit;
  final String rating;
  final String businessSector;
  const GetTalentRecommendationEvent({
    required this.offset,
    required this.limit,
    required this.rating,
    required this.businessSector,
  });

  @override
  List<Object?> get props => [
        offset,
        limit,
        rating,
        businessSector,
      ];
}
