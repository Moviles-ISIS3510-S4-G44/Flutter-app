class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      body: json['body'] as String? ?? '',
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }
}