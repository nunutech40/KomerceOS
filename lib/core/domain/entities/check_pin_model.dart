import 'package:equatable/equatable.dart';

class ChekPinModel extends Equatable {
  bool isExist;

  ChekPinModel({
    required this.isExist,
  });

  @override
  List<Object?> get props => [
        isExist,
      ];
}
