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

  TalentRecommendationModel copyWith({
    int? id,
    String? fullName,
    String? nickName,
    int? skillId,
    String? skillName,
    String? experience,
    String? industryName,
    int? closingRate,
    String? platformName,
    num? rate,
    int? rateCount,
    String? photoUrl,
    bool? isWishlist,
    String? status,
    int? wishlistCount,
    bool? isUnavailable,
  }) {
    return TalentRecommendationModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nickName: nickName ?? this.nickName,
      skillId: skillId ?? this.skillId,
      skillName: skillName ?? this.skillName,
      experience: experience ?? this.experience,
      industryName: industryName ?? this.industryName,
      closingRate: closingRate ?? this.closingRate,
      platformName: platformName ?? this.platformName,
      rate: rate ?? this.rate,
      rateCount: rateCount ?? this.rateCount,
      photoUrl: photoUrl ?? this.photoUrl,
      isWishlist: isWishlist ?? this.isWishlist,
      status: status ?? this.status,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      isUnavailable: isUnavailable ?? this.isUnavailable,
    );
  }

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
