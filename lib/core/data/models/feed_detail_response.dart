import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/feed_detail_mode.dart';

class ModelFeedDetailResponse extends Equatable {
  const ModelFeedDetailResponse({
    required this.id,
    required this.title,
    required this.visibility,
    required this.body,
    required this.image,
    required this.trainingCenterName,
    required this.publishedAt,
    required this.participants,
  });

  final int? id;
  final String? title;
  final String? visibility;
  final String? body;
  final String? image;
  final String? trainingCenterName;
  final String? publishedAt;
  final List<Participant> participants;

  ModelDetailFeed toEntity() {
    return ModelDetailFeed(
      id: id,
      title: title,
      visibility: visibility,
      body: body,
      image: image,
      trainingCenterName: trainingCenterName,
      publishedAt: publishedAt,
      participants: participants,
    );
  }

  factory ModelFeedDetailResponse.fromJson(Map<String, dynamic> json) {
    return ModelFeedDetailResponse(
      id: json["id"],
      title: json["title"],
      visibility: json["visibility"],
      body: json["body"],
      image: json["image"],
      trainingCenterName: json["training_center_name"],
      publishedAt: json["published_at"],
      participants: json["participants"] == null
          ? []
          : List<Participant>.from(
              json["participants"]!.map((x) => Participant.fromJson(x))),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        visibility,
        body,
        image,
        trainingCenterName,
        publishedAt,
        participants,
      ];
}
