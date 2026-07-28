import 'package:equatable/equatable.dart';

class AplikasiItemEntity extends Equatable {
  final String key;
  final bool active;
  final bool verified;
  final bool learnMore;
  final String deepLink;
  final String status;
  final String logoUrl;

  const AplikasiItemEntity({
    required this.key,
    required this.active,
    required this.verified,
    required this.learnMore,
    required this.deepLink,
    required this.status,
    required this.logoUrl,
  });

  @override
  List<Object?> get props => [
        key,
        active,
        verified,
        learnMore,
        deepLink,
        status,
        logoUrl,
      ];
}
