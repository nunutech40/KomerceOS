import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';

class TalentsResponse extends Equatable {
  final List<TalentLeadersData>? talentLeaders;
  final List<TalentsData>? talents;

  const TalentsResponse({required this.talentLeaders, required this.talents});

  Map<String, dynamic> toJson() => {
        "talent_leader": talentLeaders?.map((item) => item.toJson()).toList(),
        "talents": talents?.map((item) => item.toJson()).toList(),
      };

  factory TalentsResponse.fromJson(Map<String, dynamic> json) {
    return TalentsResponse(
      talentLeaders: (json['talent_leader'] as List<dynamic>)
          .map((item) => TalentLeadersData.fromJson(item))
          .toList(),
      talents: (json['talents'] as List<dynamic>)
          .map((item) => TalentsData.fromJson(item))
          .toList(),
    );
  }

  TalentsModel toEntity() {
    return TalentsModel(
      talentLeaders: talentLeaders
          ?.map((item) => item.toEntity())
          .toList(), // Map each item to entity
      talents: talents
          ?.map((item) => item.toEntity())
          .toList(), // Map each item to entity
    );
  }

  @override
  List<Object?> get props => [talentLeaders, talents];
}

class TalentLeadersData extends Equatable {
  final int staffId;
  final String staffName;
  final String phoneNumber;

  const TalentLeadersData(
      {required this.staffId,
      required this.staffName,
      required this.phoneNumber});

  Map<String, dynamic> toJson() => {
        "staff_id": staffId,
        "staff_name": staffName,
        "phone_number": phoneNumber,
      };

  factory TalentLeadersData.fromJson(Map<String, dynamic> json) {
    return TalentLeadersData(
      staffId: json['staff_id'],
      staffName: json['staff_name'],
      phoneNumber: json['phone_number'],
    );
  }

  TalentLeaderModel toEntity() {
    return TalentLeaderModel(
      staffId: staffId,
      staffName: staffName,
      phoneNumber: phoneNumber,
    );
  }

  @override
  List<Object?> get props => [staffId, staffName, phoneNumber];
}

class TalentsData extends Equatable {
  final int jobAssigneeId;
  final int talentId;
  final String talentName;
  final String hiredDate;
  final String duration;

  const TalentsData(
      {required this.jobAssigneeId,
      required this.talentId,
      required this.talentName,
      required this.hiredDate,
      required this.duration});

  Map<String, dynamic> toJson() => {
        "job_assignee_id": jobAssigneeId,
        "talent_id": talentId,
        "talent_name": talentName,
        "hired_date": hiredDate,
        "duration": duration,
      };

  factory TalentsData.fromJson(Map<String, dynamic> json) {
    return TalentsData(
      jobAssigneeId: json['job_assignee_id'],
      talentId: json['talent_id'],
      talentName: json['talent_name'],
      hiredDate: json['hired_date'],
      duration: json['duration'],
    );
  }

  TalentsDataModel toEntity() {
    return TalentsDataModel(
      jobAssigneeId: jobAssigneeId,
      talentId: talentId,
      talentName: talentName,
      hiredDate: hiredDate,
      duration: duration,
    );
  }

  @override
  List<Object?> get props =>
      [jobAssigneeId, talentId, talentName, hiredDate, duration];
}

class TalentsSelectedData extends Equatable {
  final int jobAssigneeId;
  final int talentId;
  final String talentName;
  final String hiredDate;
  final String duration;
  final bool isSelected;
  final String reason;

  const TalentsSelectedData({
    required this.jobAssigneeId,
    required this.talentId,
    required this.talentName,
    required this.hiredDate,
    required this.duration,
    required this.isSelected,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        "job_assignee_id": jobAssigneeId,
        "talent_id": talentId,
        "talent_name": talentName,
        "hired_date": hiredDate,
        "duration": duration,
        "isSelected": isSelected,
        "reason": reason,
      };

  factory TalentsSelectedData.fromJson(Map<String, dynamic> json) {
    return TalentsSelectedData(
      jobAssigneeId: json['job_assignee_id'],
      talentId: json['talent_id'],
      talentName: json['talent_name'],
      hiredDate: json['hired_date'],
      duration: json['duration'],
      isSelected: json['isSelected'],
      reason: json['reason'],
    );
  }

  TalentsSelectedDataModel toEntity() {
    return TalentsSelectedDataModel(
      jobAssigneeId: jobAssigneeId,
      talentId: talentId,
      talentName: talentName,
      hiredDate: hiredDate,
      duration: duration,
      isSelected: isSelected,
      reason: reason,
    );
  }

  @override
  List<Object?> get props => [
        jobAssigneeId,
        talentId,
        talentName,
        hiredDate,
        duration,
        isSelected,
        reason
      ];
}
