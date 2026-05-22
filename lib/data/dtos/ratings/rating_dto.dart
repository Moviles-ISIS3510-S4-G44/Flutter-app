class RatingItemDto {
  final String purchaseId;
  final String buyerId;
  final int score;
  final DateTime purchasedAt;

  RatingItemDto({
    required this.purchaseId,
    required this.buyerId,
    required this.score,
    required this.purchasedAt,
  });

  factory RatingItemDto.fromJson(Map<String, dynamic> json) {
    return RatingItemDto(
      purchaseId: json['purchase_id'] as String,
      buyerId: json['buyer_id'] as String,
      score: json['score'] as int,
      purchasedAt: DateTime.parse(json['purchased_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'purchase_id': purchaseId,
        'buyer_id': buyerId,
        'score': score,
        'purchased_at': purchasedAt.toIso8601String(),
      };
}

class UserRatingsDto {
  final String userId;
  final double average;
  final int total;
  final List<RatingItemDto> ratings;

  UserRatingsDto({
    required this.userId,
    required this.average,
    required this.total,
    required this.ratings,
  });

  factory UserRatingsDto.fromJson(Map<String, dynamic> json) {
    return UserRatingsDto(
      userId: json['user_id'] as String,
      average: (json['average'] as num).toDouble(),
      total: json['total'] as int,
      ratings: (json['ratings'] as List<dynamic>)
          .map((e) => RatingItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'average': average,
        'total': total,
        'ratings': ratings.map((r) => r.toJson()).toList(),
      };
}