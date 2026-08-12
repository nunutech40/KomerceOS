import 'package:equatable/equatable.dart';

class TeamMemberModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String avatarUrl;
  final String? role;
  final String? talentLead;
  final bool isVerified;
  final List<String> accessList;

  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.role,
    this.talentLead,
    this.isVerified = false,
    this.accessList = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        role,
        talentLead,
        isVerified,
        accessList,
      ];

  String get accessLabel => accessList.join(', ');
}
