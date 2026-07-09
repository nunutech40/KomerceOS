import 'package:equatable/equatable.dart';

class TalentsModel extends Equatable {
  List<TalentLeaderModel>? talentLeaders; // Change to a list
  List<TalentsDataModel>? talents;

  TalentsModel({this.talentLeaders, this.talents});

  List<TalentsDataModel>? mapLeadersToTalents() {
    if (talentLeaders == null) return null;
    return talentLeaders!
        .map((leader) => TalentsDataModel(talentName: leader.staffName))
        .toList();
  }

  @override
  List<Object?> get props => [talentLeaders, talents];
}

class TalentLeaderModel extends Equatable {
  int? staffId;
  String? staffName;
  String? phoneNumber;
  bool? isChecked;
  int rating;
  String? evaluation;
  bool? isValidEvaluation;

  TalentLeaderModel({
    this.staffId,
    this.staffName,
    this.phoneNumber,
    this.isChecked,
    this.rating = 0,
    this.evaluation,
    this.isValidEvaluation = false,
  });

  @override
  List<Object?> get props => [
        staffId,
        staffName,
        phoneNumber,
        isChecked,
        rating,
        evaluation,
        isValidEvaluation
      ];
}

class TalentsUnhireDataModel extends Equatable {
  int? jobAssigneeId;
  int? talentId;
  String? reasonQuit;

  TalentsUnhireDataModel({
    this.jobAssigneeId,
    this.talentId,
    this.reasonQuit,
  });

  @override
  List<Object?> get props => [jobAssigneeId, talentId, reasonQuit];
}

class TalentsDataModel extends Equatable {
  int? jobAssigneeId;
  int? talentId;
  String? talentName;
  bool? isChecked;
  int rating;
  String? hiredDate;
  String? duration;
  bool? isSelected;
  String? evaluation;
  bool? isValidEvaluation;

  TalentsDataModel(
      {this.jobAssigneeId,
      this.talentId,
      this.talentName,
      this.rating = 0,
      this.isChecked = false,
      this.hiredDate,
      this.duration,
      this.evaluation,
      this.isSelected = false,
      this.isValidEvaluation = false});

  @override
  List<Object?> get props => [
        jobAssigneeId,
        talentId,
        talentName,
        isChecked,
        rating,
        hiredDate,
        duration,
        isSelected,
        evaluation,
        isValidEvaluation
      ];
}

class TalentsSelectedDataModel extends Equatable {
  int? jobAssigneeId;
  int? talentId;
  String? talentName;
  bool? isChecked;
  int rating;
  String? hiredDate;
  String? duration;
  bool? isSelected;
  String? reason;

  TalentsSelectedDataModel(
      {this.jobAssigneeId,
      this.talentId,
      this.talentName,
      this.rating = 0,
      this.isChecked = false,
      this.hiredDate,
      this.duration,
      this.isSelected,
      this.reason = ''});

  @override
  List<Object?> get props => [
        jobAssigneeId,
        talentId,
        talentName,
        isChecked,
        rating,
        hiredDate,
        duration,
        isSelected,
        reason,
      ];
}
