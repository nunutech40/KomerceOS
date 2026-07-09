import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/domain/entities/feed_detail_mode.dart';
import 'package:komtim_partner/core/domain/entities/feed_model.dart';
import 'package:komtim_partner/core/domain/entities/feed_notif_count_model.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/core/domain/entities/topup_kompoin_model.dart';
import 'package:komtim_partner/core/domain/entities/transaction_history_model.dart';
import 'package:komtim_partner/core/domain/usecases/do_logout_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_feed_detail_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_feed_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_profile_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_push_notif_count_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_telant_recomendation_usec_ase.dart';
import 'package:komtim_partner/core/domain/usecases/topup_ceck_transaction_use_case.dart';
import 'package:meta/meta.dart';

import '../../../common/enum_status.dart';
import '../../../common/failure.dart';
import '../../../core/domain/entities/check_pin_model.dart';
import '../../../core/domain/entities/invoices_model.dart';
import '../../../core/domain/entities/profile_model.dart';
import '../../../core/domain/entities/shopping_list_model.dart';
import '../../../core/domain/usecases/check_pin_use_case.dart';
import '../../../core/domain/usecases/get_invoices_use_case.dart';
import '../../../core/domain/usecases/get_shopping_list_use_case.dart';
import '../../../core/domain/usecases/get_talent_use_case.dart';
import '../../../core/domain/usecases/topup_kompoin_use_case.dart';

part 'home_page_event.dart';
part 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc({
    required this.getProfileUseCase,
    required this.getTalensUseCase,
    required this.checkPinUseCase,
    required this.topupKompoinUseCase,
    required this.topUpCeckTransactionUseCase,
    required this.getInvoiceUseCase,
    required this.getShoppingListUseCase,
    required this.doLogoutUseCase,
    required this.getFeedUseCase,
    required this.getFeedDetailUseCase,
    required this.getNotifCountUseCase,
    required this.getTalentRecommendationUseCase,
  }) : super(const HomePageState()) {
    on<HomePageDidload>(_handleHomePageDidload);
    on<ClickTopUpButtonEvent>(_handleTopUpAction);
    on<RefreshDataEvent>(_refresStateAndEvent);
    on<GetTalentResult>(_handleGetTalentResult);
    on<LoadDataCecktransactionTopUpEvent>(_handleToUpLoadCeckTransactionEvent);
    on<InvoviceListPageDidload>(_handleCheckNotifPage);
    on<GetShoppingListEvent>(_getShoppingList);
    on<LogoutButtonPressedEvent>(_handleButtonLogout);
    on<GetFeedEvent>(_handleFeed);
    on<GetFeedDetailEvent>(_handleFeedDetail);
    on<GetNotificationCountEvent>(_handleNotificationCount);
    on<GetTalentRecommendationEvent>(_handleTalentRecomendation);
  }

  final GetProfileUseCase getProfileUseCase;
  final GetTalensUseCase getTalensUseCase;
  final TopupKompoinUseCase topupKompoinUseCase;
  final CheckPinUseCase checkPinUseCase;
  final TopUpCeckUseCase topUpCeckTransactionUseCase;
  final GetInvoiceUseCase getInvoiceUseCase;
  final GetShoppingListUseCase getShoppingListUseCase;
  final DoLogoutUseCase doLogoutUseCase;
  final GetFeedUseCase getFeedUseCase;
  final GetFeedDetailUseCase getFeedDetailUseCase;
  final GetNotifCountUseCase getNotifCountUseCase;
  final GetTalentRecommendationUseCase getTalentRecommendationUseCase;

  Future<void> _refresStateAndEvent(
    RefreshDataEvent event,
    Emitter<HomePageState> emit,
  ) async {
    emit(const HomePageState());
  }

  Future<void> _handleHomePageDidload(
    HomePageDidload event,
    Emitter<HomePageState> emit,
  ) async {
    emit(
        state.copyWith(status: RequestStatus.loading, operation: 'getProfile'));
    // await Future.delayed(const Duration(seconds: 10));
    final profileResult = await getProfileUseCase.execute();

    await profileResult.fold(
      (failure) async {
        // debugPrint('Error fetching profile: ${failure.message}');
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (profileData) async {
        emit(state.copyWith(
          message: 'Success',
          operation: 'getProfile',
          status: RequestStatus.success,
          profileData: profileData,
        ));
      },
    );
  }

  Future<void> _handleGetTalentResult(
    GetTalentResult event,
    Emitter<HomePageState> emit,
  ) async {
    emit(
        state.copyWith(status: RequestStatus.loading, operation: 'getTalents'));
    final talentsResult = await getTalensUseCase.execute();

    await talentsResult.fold(
      (failure) async {
        emit(state.copyWith(
          message: failure.message,
          status: RequestStatus.failure,
        ));
      },
      (talentsData) async {
        emit(state.copyWith(
            message: 'Success',
            operation: 'getTalents',
            status: RequestStatus.success,
            talentData: talentsData));
      },
    );
  }

  Future<void> _handleTopUpAction(
    ClickTopUpButtonEvent event,
    Emitter<HomePageState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'topUp'));

    final topUpResult = await topupKompoinUseCase.execute(event.nominal);

    topUpResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (topUpData) {
        emit(state.copyWith(
          message: 'Success',
          operation: 'topUp',
          status: RequestStatus.success,
          topUpData: topUpData,
        ));
      },
    );
  }

  Future<void> _handleToUpLoadCeckTransactionEvent(
    LoadDataCecktransactionTopUpEvent event,
    Emitter<HomePageState> emit,
  ) async {
    // Emit the loading state first
    emit(state.copyWith(statusCheckTopup: RequestStatus.loading));
    // await Future.delayed(const Duration(seconds: 2));
    final result =
        await topUpCeckTransactionUseCase.execute(event.typeCheckTrasaction);
    result.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message,
              statusCheckTopup: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, statusCheckTopup: RequestStatus.empty));
        }
      },
      (transcationCeckData) {
        emit(state.copyWith(
            message: 'Success',
            statusCheckTopup: RequestStatus.success,
            dataResponseCeckData: transcationCeckData));
      },
    );
  }

  Future<void> _handleCheckNotifPage(
    InvoviceListPageDidload event,
    Emitter<HomePageState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));
    final invoicesResult =
        await getInvoiceUseCase.execute(event.type, event.offset, event.limit);

    invoicesResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (invoicesData) {
        emit(state.copyWith(
            message: 'Success',
            checkinvoice: true,
            status: RequestStatus.success,
            invoicesData: invoicesData));
      },
    );
  }

  Future<void> _getShoppingList(
    GetShoppingListEvent event,
    Emitter<HomePageState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'getShoppingList'));

    final shoppingResult = await getShoppingListUseCase.execute(
        event.offset,
        event.limit,
        event.status,
        event.startDate,
        event.endDate,
        event.keyword);

    shoppingResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (shoppingList) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            shoppingList: shoppingList));
      },
    );
  }

  Future<void> _handleButtonLogout(
    LogoutButtonPressedEvent event,
    Emitter<HomePageState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.loading,
      operation: 'logoutState',
    ));

    final result = await doLogoutUseCase.execute();

    result.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (logoutData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        )); // Reset profile data on logout
      },
    );
  }

  Future<void> _handleFeed(
    GetFeedEvent event,
    Emitter<HomePageState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading, operation: 'feedList'));

    final feedResult = await getFeedUseCase.execute(
      event.search,
      event.limit,
      event.offset,
    );

    feedResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (feedList) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            feedList: feedList));
      },
    );
  }

  Future<void> _handleFeedDetail(
    GetFeedDetailEvent event,
    Emitter<HomePageState> emit,
  ) async {
    emit(
        state.copyWith(status: RequestStatus.loading, operation: 'feedDetail'));

    final feedDetailResult = await getFeedDetailUseCase.execute(
      event.id,
    );

    feedDetailResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (feedDetail) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            feedDetail: feedDetail));
      },
    );
  }

  Future<void> _handleNotificationCount(
    GetNotificationCountEvent event,
    Emitter<HomePageState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.loading,
    ));

    final feedDetailResult = await getNotifCountUseCase.execute();

    feedDetailResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (data) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            notificationCount: data));
      },
    );
  }

  Future<void> _handleTalentRecomendation(
    GetTalentRecommendationEvent event,
    Emitter<HomePageState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'getTalentRecommendation'));

    final talentRecommendationResult =
        await getTalentRecommendationUseCase.call(
      offset: event.offset,
      limit: event.limit,
      rating: event.rating,
      businessSector: event.businessSector,
    );

    talentRecommendationResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (talentRecommendationData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            talentRecommendationData: talentRecommendationData));
      },
    );
  }
}
