import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/attendance_model.dart';

class AttendanceResponse extends Equatable {
  final int? id;
  final String? fullName;
  final int? roleId;
  final int? officeId;
  final String? officeName;
  final String? checkInDatetime;
  final String? checkOutDatetime;
  final String? checkInPhotoUrl;
  final String? checkOutPhotoUrl;
  final String? workMode;
  final String? createdAt;
  final String? updatedAt;
  const AttendanceResponse({
    required this.id,
    required this.fullName,
    required this.roleId,
    required this.officeId,
    required this.officeName,
    required this.checkInDatetime,
    required this.checkOutDatetime,
    required this.checkInPhotoUrl,
    required this.checkOutPhotoUrl,
    required this.workMode,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "role_id": roleId,
        "office_id": officeId,
        "office_name": officeName,
        "check_in_datetime": checkInDatetime,
        "check_out_datetime": checkOutDatetime,
        "check_in_photo_url": checkInPhotoUrl,
        "check_out_photo_url": checkOutPhotoUrl,
        "work_mode": workMode,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      id: json['id'],
      fullName: json['full_name'],
      roleId: json['role_id'],
      officeId: json['office_id'],
      officeName: json['office_name'],
      checkInDatetime: json['check_in_datetime'],
      checkOutDatetime: json['check_out_datetime'],
      checkInPhotoUrl: json['check_in_photo_url'],
      checkOutPhotoUrl: json['check_out_photo_url'],
      workMode: json['work_mode'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  AttendanceModel toEntity() {
    return AttendanceModel(
      id: id,
      fullName: fullName,
      roleId: roleId,
      officeId: officeId,
      officeName: officeName,
      checkInDatetime: checkInDatetime,
      checkOutDatetime: checkOutDatetime,
      checkInPhotoUrl: checkInPhotoUrl,
      checkOutPhotoUrl: checkOutPhotoUrl,
      workMode: workMode,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

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

class AttendanceFailResponse extends Equatable {
  final int? id;
  final String? fullName;
  final int? roleId;
  final int? officeId;
  final String? officeName;
  final String? description;
  final String? ticketFile;
  final String? createdAt;
  final String? updatedAt;
  const AttendanceFailResponse({
    required this.id,
    required this.fullName,
    required this.roleId,
    required this.officeId,
    required this.officeName,
    required this.description,
    required this.ticketFile,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "role_id": roleId,
        "office_id": officeId,
        "office_name": officeName,
        "description": description,
        "ticket_file": ticketFile,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };

  factory AttendanceFailResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceFailResponse(
      id: json['id'],
      fullName: json['full_name'],
      roleId: json['role_id'],
      officeId: json['office_id'],
      officeName: json['office_name'],
      description: json['description'],
      ticketFile: json['ticket_file'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  AttendanceFailModel toEntity() {
    return AttendanceFailModel(
      id: id,
      fullName: fullName,
      roleId: roleId,
      officeId: officeId,
      officeName: officeName,
      description: description,
      ticketFile: ticketFile,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

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

class AttendanceAbsenceResponse extends Equatable {
  final int? number;
  final String? fullName;
  final String? absenceDate;
  const AttendanceAbsenceResponse({
    required this.number,
    required this.fullName,
    required this.absenceDate,
  });

  Map<String, dynamic> toJson() => {
        "number": number,
        "full_name": fullName,
        "absence_date": absenceDate,
      };

  factory AttendanceAbsenceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceAbsenceResponse(
      number: json['number'],
      fullName: json['full_name'],
      absenceDate: json['absence_date'],
    );
  }

  AttendanceAbsenceModel toEntity() {
    return AttendanceAbsenceModel(
      number: number,
      fullName: fullName,
      absenceDate: absenceDate,
    );
  }

  @override
  List<Object?> get props => [
        number,
        fullName,
        absenceDate,
      ];
}
