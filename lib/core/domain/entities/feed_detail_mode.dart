import 'package:equatable/equatable.dart';

class ModelDetailFeed extends Equatable {
  const ModelDetailFeed({
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

class Participant {
  Participant({
    required this.name,
  });

  final String? name;

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      name: json["name"],
    );
  }
}
