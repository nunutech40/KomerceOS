import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/core/domain/entities/business_sector_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_business_sector_use_case.dart';

part 'business_sector_event.dart';
part 'business_sector_state.dart';

/// BLoC untuk memuat daftar Business Sector dari API.
/// Digunakan di [TalentFilterSheet] sebagai opsi dropdown "Industri".
class BusinessSectorBloc
    extends Bloc<BusinessSectorEvent, BusinessSectorState> {
  final GetBusinessSectorUseCase getBusinessSectorUseCase;

  BusinessSectorBloc({required this.getBusinessSectorUseCase})
      : super(BusinessSectorInitial()) {
    on<FetchBusinessSectorEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchBusinessSectorEvent event,
    Emitter<BusinessSectorState> emit,
  ) async {
    emit(BusinessSectorLoading());
    final result = await getBusinessSectorUseCase.call();
    result.fold(
      (failure) => emit(BusinessSectorError(failure.message)),
      (sectors) => emit(BusinessSectorLoaded(sectors)),
    );
  }
}
