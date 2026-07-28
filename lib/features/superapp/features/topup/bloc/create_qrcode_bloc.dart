import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/domain/usecases/create_qrcode_use_case.dart';
import 'create_qrcode_event.dart';
import 'create_qrcode_state.dart';

class CreateQrcodeBloc extends Bloc<CreateQrcodeEvent, CreateQrcodeState> {
  final CreateQrcodeUseCase useCase;

  CreateQrcodeBloc({required this.useCase}) : super(CreateQrcodeInitial()) {
    on<DoCreateQrcode>((event, emit) async {
      emit(CreateQrcodeLoading());
      final result = await useCase.execute(
        channelPay: event.channelPay,
        description: event.description,
        amount: event.amount,
        duration: event.duration,
      );

      result.fold(
        (failure) => emit(CreateQrcodeFailed(failure.message)),
        (data) => emit(CreateQrcodeSuccess(data)),
      );
    });
  }
}
