import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/core/domain/entities/check_bill_model.dart';
import 'package:komtim_partner/core/domain/usecases/check_bill_use_case.dart';

part 'check_bill_event.dart';
part 'check_bill_state.dart';

class CheckBillBloc extends Bloc<CheckBillEvent, CheckBillState> {
  final CheckBillUseCase checkBillUseCase;

  CheckBillBloc({required this.checkBillUseCase}) : super(CheckBillInitial()) {
    on<FetchCheckBillEvent>(_onFetch);
  }

  void _onFetch(FetchCheckBillEvent event, Emitter<CheckBillState> emit) async {
    try {
      emit(CheckBillLoading());
      final result = await checkBillUseCase.call();
      result.fold(
        (failure) => emit(CheckBillError(failure.message)),
        (data) => emit(CheckBillLoaded(data)),
      );
    } catch (e) {
      emit(CheckBillError(e.toString()));
    }
  }
}
