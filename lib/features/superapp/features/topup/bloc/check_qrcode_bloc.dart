import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/domain/usecases/check_qrcode_use_case.dart';
import 'check_qrcode_event.dart';
import 'check_qrcode_state.dart';

class CheckQrcodeBloc extends Bloc<CheckQrcodeEvent, CheckQrcodeState> {
  final CheckQrcodeUseCase useCase;

  CheckQrcodeBloc({required this.useCase}) : super(CheckQrcodeInitial()) {
    on<DoCheckQrcode>(_onCheckQrcode);
  }

  Future<void> _onCheckQrcode(
      DoCheckQrcode event, Emitter<CheckQrcodeState> emit) async {
    emit(CheckQrcodeLoading());
    final result = await useCase.execute(event.qrId);

    result.fold(
      (failure) {
        emit(CheckQrcodeFailed(failure.message));
      },
      (data) {
        emit(CheckQrcodeSuccess(data));
      },
    );
  }
}
