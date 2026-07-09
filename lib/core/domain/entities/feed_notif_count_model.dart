import 'package:equatable/equatable.dart';

class ModelFeedNotifCount extends Equatable {
  const ModelFeedNotifCount({
    required this.count,
  });

  final int? count;

  @override
  List<Object?> get props => [
        count,
      ];
}
