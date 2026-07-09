import 'package:equatable/equatable.dart';

class AttendanceModel extends Equatable {
  int? id;
  String? fullName;
  int? roleId;
  int? officeId;
  String? officeName;
  String? checkInDatetime;
  String? checkOutDatetime;
  String? checkInPhotoUrl;
  String? checkOutPhotoUrl;
  String? workMode;
  String? createdAt;
  String? updatedAt;

  AttendanceModel({
    this.id,
    this.fullName,
    this.roleId,
    this.officeId,
    this.officeName,
    this.checkInDatetime,
    this.checkOutDatetime,
    this.checkInPhotoUrl,
    this.checkOutPhotoUrl,
    this.workMode,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        roleId,
        officeId,
        officeName,
        checkInDatetime,
        checkOutDatetime,
        checkInPhotoUrl,
        checkOutPhotoUrl,
        workMode,
        createdAt,
        updatedAt,
      ];
}

class AttendanceFailModel extends Equatable {
  int? id;
  String? fullName;
  int? roleId;
  int? officeId;
  String? officeName;
  String? description;
  String? ticketFile;
  String? createdAt;
  String? updatedAt;

  AttendanceFailModel({
    this.id,
    this.fullName,
    this.roleId,
    this.officeId,
    this.officeName,
    this.description,
    this.ticketFile,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        roleId,
        officeId,
        officeName,
        description,
        ticketFile,
        createdAt,
        updatedAt,
      ];
}

class AttendanceAbsenceModel extends Equatable {
  int? number;
  String? fullName;
  String? absenceDate;

  AttendanceAbsenceModel({
    this.number,
    this.fullName,
    this.absenceDate,
  });

  @override
  List<Object?> get props => [
        number,
        fullName,
        absenceDate,
      ];
}
