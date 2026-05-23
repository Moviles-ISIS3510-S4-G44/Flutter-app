class IntentFilters {
  final double? minPrice;
  final double? maxPrice;
  final String? category;
  final String? condition;

  const IntentFilters({
    this.minPrice,
    this.maxPrice,
    this.category,
    this.condition,
  });

  static const empty = IntentFilters();

  bool get isEmpty =>
      minPrice == null && maxPrice == null && category == null && condition == null;

  IntentFilters copyWith({
    double? minPrice,
    double? maxPrice,
    String? category,
    String? condition,
  }) {
    return IntentFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      category: category ?? this.category,
      condition: condition ?? this.condition,
    );
  }
}

