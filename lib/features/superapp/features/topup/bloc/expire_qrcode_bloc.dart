import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/usecases/expire_qrcode_use_case.dart';

part 'expire_qrcode_event.dart';
part 'expire_qrcode_state.dart';

class ExpireQrcodeBloc extends Bloc<ExpireQrcodeEvent, ExpireQrcodeState> {
  final ExpireQrcodeUseCase expireQrcodeUseCase;

  ExpireQrcodeBloc({required this.expireQrcodeUseCase}) : super(ExpireQrcodeInitial()) {
    on<FetchExpireQrcodeEvent>(_onFetch);
  }

  void _onFetch(FetchExpireQrcodeEvent event, Emitter<ExpireQrcodeState> emit) async {
    try {
      emit(ExpireQrcodeLoading());
      final result = await expireQrcodeUseCase.call(event.qrId);
      result.fold(
        (failure) => emit(ExpireQrcodeError(failure)),
        (_) => emit(ExpireQrcodeSuccess()),
      );
    } catch (e) {
      emit(ExpireQrcodeError(UnknownFailure(e.toString())));
    }
  }
}
