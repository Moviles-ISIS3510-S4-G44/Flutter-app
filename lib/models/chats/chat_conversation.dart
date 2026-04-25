import 'chat_user_summary.dart';

class ChatConversation {
  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final ChatUserSummary otherUser;
  final String listingTitle;
  final String lastMessageBody;

  ChatConversation({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
    required this.lastMessageAt,
    required this.otherUser,
    required this.listingTitle,
    required this.lastMessageBody,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      otherUser: ChatUserSummary.fromJson(
        json['other_user'] as Map<String, dynamic>,
      ),
      listingTitle: json['listing_title'] as String? ?? 'Untitled listing',
      lastMessageBody: json['last_message_body'] as String? ?? '',
    );
  }
}