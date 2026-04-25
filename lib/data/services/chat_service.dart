import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';
import 'package:marketplace_flutter_application/models/chats/chat_message.dart';

class ChatService {
  final String baseUrl;

  ChatService({
    required this.baseUrl,
  });

  Future<List<ChatConversation>> getConversations({
    required String accessToken,
  }) async {
    final uri = Uri.parse('$baseUrl/chat/conversations');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load conversations. Status: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;

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
      body: jsonEncode({
        'listing_id': listingId,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to create conversation. Status: ${response.statusCode}',
      );
    }

    return ChatConversation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<ChatConversation> getConversation({
    required String accessToken,
    required String conversationId,
  }) async {
    final uri = Uri.parse('$baseUrl/chat/conversations/$conversationId');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load conversation. Status: ${response.statusCode}',
      );
    }

    return ChatConversation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<ChatMessage>> getMessages({
    required String accessToken,
    required String conversationId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/chat/conversations/$conversationId/messages',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load messages. Status: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;

    return decoded
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage({
    required String accessToken,
    required String conversationId,
    required String body,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/chat/conversations/$conversationId/messages',
    );

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'body': body,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to send message. Status: ${response.statusCode}',
      );
    }

    return ChatMessage.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}