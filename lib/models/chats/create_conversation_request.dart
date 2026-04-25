class CreateConversationRequest {
  final String listingId;

  CreateConversationRequest({required this.listingId});

  Map<String, dynamic> toJson() => {
        'listing_id': listingId,
      };
}