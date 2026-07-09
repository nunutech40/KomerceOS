// Model class untuk domain layer
import 'package:equatable/equatable.dart';

class TalentRecommendationModel extends Equatable {
  final int id;
  final String fullName;
  final String nickName;
  final int skillId;
  final String skillName;
  final String experience;
  final String industryName;
  final int closingRate;
  final String platformName;
  final num rate;
  final int rateCount;
  final String photoUrl;
  final bool isWishlist;
  final String status;
  final int wishlistCount;
  final bool isUnavailable;

  const TalentRecommendationModel({
    required this.id,
    required this.fullName,
    required this.nickName,
    required this.skillId,
    required this.skillName,
    required this.experience,
    required this.industryName,
    required this.closingRate,
    required this.platformName,
    required this.rate,
    required this.rateCount,
    required this.photoUrl,
    required this.isWishlist,
    required this.status,
    required this.wishlistCount,
    required this.isUnavailable,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        nickName,
        skillId,
        skillName,
        experience,
        industryName,
        closingRate,
        platformName,
        rate,
        rateCount,
        photoUrl,
        isWishlist,
        status,
        wishlistCount,
        isUnavailable,
      ];
}
