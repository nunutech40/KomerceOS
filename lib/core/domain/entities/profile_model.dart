import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  int? id;
  int partnerId;
  String? partnerNo;
  String? fullname;
  String? username;
  String? email;
  String? noTelp;
  String? address;
  String? joinDate;
  String? bankName;
  String? bankAccountNumber;
  String? photoProfileUrl;
  String? bankOwnerName;
  String? createdAt;
  String? updatedAt;
  int? kmPoin;
  String? accountStatus;
  int? kompoin;
  int? businessSectoreId;

  ProfileModel(
      {this.id,
      required this.partnerId,
      this.partnerNo,
      this.fullname,
      this.username,
      this.email,
      this.noTelp,
      this.address,
      this.joinDate,
      this.bankName,
      this.bankAccountNumber,
      this.bankOwnerName,
      this.photoProfileUrl,
      this.createdAt,
      this.updatedAt,
      this.kmPoin,
      this.accountStatus,
      this.kompoin,
      this.businessSectoreId
      });

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
        bankOwnerName,
        photoProfileUrl,
        createdAt,
        updatedAt,
        kmPoin,
        accountStatus,
        kompoin,
        businessSectoreId,
      ];
}
