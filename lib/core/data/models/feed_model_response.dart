import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/feed_model.dart';

class ModelFeedResponse extends Equatable {
  const ModelFeedResponse({
    required this.id,
    required this.title,
    required this.visibility,
    required this.image,
    required this.trainingCenterName,
    required this.publishedAt,
    required this.participants,
  });

  final int? id;
  final String? title;
  final String? visibility;
  final String? image;
  final String? trainingCenterName;
  final String? publishedAt;
  final List<Participant> participants;

  ModelFeed toEntity() {
    return ModelFeed(
      id: id,
      title: title,
      visibility: visibility,
      image: image,
      trainingCenterName: trainingCenterName,
      publishedAt: publishedAt,
      participants: participants,
    );
  }

  factory ModelFeedResponse.fromJson(Map<String, dynamic> json) {
    return ModelFeedResponse(
      id: json["id"],
      title: json["title"],
      visibility: json["visibility"],
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
        image,
        trainingCenterName,
        publishedAt,
        participants,
      ];
}
