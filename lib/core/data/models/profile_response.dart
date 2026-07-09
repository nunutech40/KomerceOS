import 'package:equatable/equatable.dart';

import '../../domain/entities/profile_model.dart';

class ProfileResponse extends Equatable {
  final int? id;
  final int partnerId;
  final String? partnerNo;
  final String? fullname;
  final String? username;
  final String? email;
  final String? noTelp;
  final String? address;
  final String? joinDate;
  final String? bankName;
  final String? bankAccountNumber;
  final String bankOwnername;
  final String? createdAt;
  final String? updatedAt;
  final String? photoProfileUrl;
  final int? kmPoin;
  final String? accountStatus;
  final int? kompoin;
  final int? businessSectoreId;

  const ProfileResponse({
    required this.id,
    required this.partnerId,
    required this.partnerNo,
    required this.fullname,
    required this.username,
    required this.email,
    required this.noTelp,
    required this.address,
    required this.joinDate,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankOwnername,
    required this.photoProfileUrl,
    required this.kmPoin,
    required this.accountStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.kompoin,
    required this.businessSectoreId,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "partner_id": partnerId,
        "partner_no": partnerNo,
        "fullname": fullname,
        "username": username,
        "email": email,
        "no_telp": noTelp,
        "address": address,
        "join_date": joinDate,
        "bank_name": bankName,
        "bank_account_number": bankAccountNumber,
        "bank_owner_name": bankOwnername,
        "photo_profile_url": photoProfileUrl,
        "kmpoin": kmPoin,
        "account_status": accountStatus,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "kompoin": kompoin,
        "business_sector_id": businessSectoreId,
      };

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'],
      partnerId: json['partner_id'],
      partnerNo: json['partner_no'],
      fullname: json['fullname'],
      username: json['username'],
      email: json['email'],
      noTelp: json['no_telp'],
      address: json['address'],
      joinDate: json['join_date'],
      bankName: json['bank_name'],
      bankOwnername: json['bank_owner_name'],
      kmPoin: json['kmpoin'],
      accountStatus: json['account_status'],
      bankAccountNumber: json['bank_account_number'],
      photoProfileUrl: json['photo_profile_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      kompoin: json['kompoints'] ,
      businessSectoreId: json['business_sector_id'],
    );
  }

  ProfileModel toEntity() {
    return ProfileModel(
      id: id,
      partnerId: partnerId,
      partnerNo: partnerNo,
      fullname: fullname,
      username: username,
      email: email,
      noTelp: noTelp,
      address: address,
      joinDate: joinDate,
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankOwnerName: bankOwnername,
      photoProfileUrl: photoProfileUrl,
      kmPoin: kmPoin,
      accountStatus: accountStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      kompoin: kompoin ?? 0,
      businessSectoreId: businessSectoreId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        partnerId,
        partnerNo,
        fullname,
        username,
        email,
        noTelp,
        address,
        joinDate,
        bankName,
        bankAccountNumber,
        bankOwnername,
        photoProfileUrl,
        createdAt,
        updatedAt,
        kmPoin,
        accountStatus,
        kompoin,
        businessSectoreId
      ];
}
