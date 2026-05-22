class RatingItem {
  final String purchaseId;
  final String buyerId;
  final int score;
  final DateTime purchasedAt;

  const RatingItem({
    required this.purchaseId,
    required this.buyerId,
    required this.score,
    required this.purchasedAt,
  });
}

class UserRatings {
  final String userId;
  final double average;
  final int total;
  final List<RatingItem> items;

  const UserRatings({
    required this.userId,
    required this.average,
    required this.total,
    required this.items,
  });

  /// Distribución por estrellas (1-5)
  Map<int, int> get distribution {
    final map = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final item in items) {
      map[item.score] = (map[item.score] ?? 0) + 1;
    }
    return map;
  }
}