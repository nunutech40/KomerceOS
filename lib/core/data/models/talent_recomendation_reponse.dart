import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';

// Response class untuk parsing JSON
class TalentRecommendationResponse extends Equatable {
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

  const TalentRecommendationResponse({
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

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "nick_name": nickName,
        "skill_id": skillId,
        "skill_name": skillName,
        "experience": experience,
        "industry_name": industryName,
        "closing_rate": closingRate,
        "platform_name": platformName,
        "rate": rate,
        "rate_count": rateCount,
        "photo_url": photoUrl,
        "is_wishlist": isWishlist,
        "status": status,
        "wishlist_count": wishlistCount,
        "is_unavailable": isUnavailable,
      };

  factory TalentRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return TalentRecommendationResponse(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      nickName: json['nick_name'] ?? '',
      skillId: json['skill_id'],
      skillName: json['skill_name'] ?? '',
      experience: json['experience'] ?? '',
      industryName: json['industry_name'] ?? '',
      closingRate: json['closing_rate'] ?? 0,
      platformName: json['platform_name'] ?? '',
      rate: json['rate'] ?? 0,
      rateCount: json['rate_count'] ?? 0,
      photoUrl: json['photo_url'] ?? '',
      isWishlist: json['is_wishlist'] ?? false,
      status: json['status'] ?? '',
      wishlistCount: json['wishlist_count'] ?? 0,
      isUnavailable: json['is_unavailable'] ?? false,
    );
  }

  TalentRecommendationModel toEntity() {
    return TalentRecommendationModel(
      id: id,
      fullName: fullName,
      nickName: nickName,
      skillId: skillId,
      skillName: skillName,
      experience: experience,
      industryName: industryName,
      closingRate: closingRate,
      platformName: platformName,
      rate: rate,
      rateCount: rateCount,
      photoUrl: photoUrl,
      isWishlist: isWishlist,
      status: status,
      wishlistCount: wishlistCount,
      isUnavailable: isUnavailable,
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
