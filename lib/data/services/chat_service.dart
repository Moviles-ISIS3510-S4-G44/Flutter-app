import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';

class ChatService {
  final String baseUrl;

  ChatService({required this.baseUrl});

  Future<List<ChatConversation>> getConversations({
    required String accessToken,
  }) async {
    final uri = Uri.parse('$baseUrl/chat/conversations');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load conversations. Status: ${response.statusCode}. Body: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Expected a list of conversations but got: ${decoded.runtimeType}',
      );
    }

    return decoded
        .map((item) => ChatConversation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ChatConversation> createConversation({
    required String accessToken,
    required String listingId,
  }) async {
    final uri = Uri.parse('$baseUrl/chat/conversations');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'listing_id': listingId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to create conversation: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    return ChatConversation.fromJson(decoded);
  }
}
