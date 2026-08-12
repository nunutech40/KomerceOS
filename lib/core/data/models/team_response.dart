import 'package:equatable/equatable.dart';

import '../../domain/entities/team_member_model.dart';

class TeamResponse extends Equatable {
  final int? userId;
  final String? fullName;
  final String? email;
  final String? role;
  final String? talentLead;
  final bool? isEmailVerif;
  final List<String>? accessMenu;

  const TeamResponse({
    this.userId,
    this.fullName,
    this.email,
    this.role,
    this.talentLead,
    this.isEmailVerif,
    this.accessMenu,
  });

  factory TeamResponse.fromJson(Map<String, dynamic> json) {
    return TeamResponse(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      talentLead: json['talent_lead']?.toString(),
      isEmailVerif: json['is_email_verif'] == true ||
          json['is_email_verif'] == 'true' ||
          json['is_email_verif'] == 1,
      accessMenu: (json['access_menu'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'role': role,
      'talent_lead': talentLead,
      'is_email_verif': isEmailVerif,
      'access_menu': accessMenu,
    };
  }

  TeamMemberModel toEntity() {
    return TeamMemberModel(
      id: userId ?? 0,
      name: fullName ?? '-',
      email: email ?? '',
      avatarUrl: '', // Avatar not provided by API
      role: role,
      talentLead: talentLead,
      isVerified: isEmailVerif ?? false,
      accessList: accessMenu ?? [],
    );
  }

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        role,
        talentLead,
        isEmailVerif,
        accessMenu,
      ];
}
