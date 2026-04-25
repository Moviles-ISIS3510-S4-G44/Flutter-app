class ChatUserSummary {
  final String id;
  final String name;

  ChatUserSummary({
    required this.id,
    required this.name,
  });

  factory ChatUserSummary.fromJson(Map<String, dynamic> json) {
    return ChatUserSummary(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown user',
    );
  }
}