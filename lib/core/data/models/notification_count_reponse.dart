import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/feed_notif_count_model.dart';


class NotificationCountReponse extends Equatable {
  final int? count;

  const NotificationCountReponse({
    required this.count,
  });

  Map<String, dynamic> toJson() => {
        "count": count,
      };

  factory NotificationCountReponse.fromJson(Map<String, dynamic> json) {
    return NotificationCountReponse(
      count: json['count'],
    );
  }

  ModelFeedNotifCount toEntity() {
    return ModelFeedNotifCount(
      count: count,
    );
  }

  @override
  List<Object?> get props => [
        count,
      ];
}
