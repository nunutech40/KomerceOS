import 'package:equatable/equatable.dart';
import '../../../../../core/domain/entities/create_qrcode_model.dart';

abstract class CreateQrcodeState extends Equatable {
  const CreateQrcodeState();

  @override
  List<Object?> get props => [];
}

class CreateQrcodeInitial extends CreateQrcodeState {}

class CreateQrcodeLoading extends CreateQrcodeState {}

class CreateQrcodeSuccess extends CreateQrcodeState {
  final CreateQrcodeModel data;

  const CreateQrcodeSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class CreateQrcodeFailed extends CreateQrcodeState {
  final String message;

  const CreateQrcodeFailed(this.message);

  @override
  List<Object?> get props => [message];
}
