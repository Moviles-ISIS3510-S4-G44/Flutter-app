class InteractionDto {
  final String id;
  final String userId;
  final String listingId;
  final int interactionCount;
  final DateTime lastInteractionAt;

  const InteractionDto({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.interactionCount,
    required this.lastInteractionAt,
  });

  factory InteractionDto.fromJson(Map<String, dynamic> json) {
    return InteractionDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      listingId: json['listing_id'] as String,
      interactionCount: json['interaction_count'] as int,
      lastInteractionAt: DateTime.parse(json['last_interaction_at'] as String),
    );
  }
}