import 'package:marketplace_flutter_application/data/services/chat_service.dart';
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';
import 'package:marketplace_flutter_application/models/chats/chat_message.dart';

class ChatRepository {
  final ChatService _chatService;

  ChatRepository({
    required ChatService chatService,
  }) : _chatService = chatService;

  Future<List<ChatConversation>> getConversations({
    required String accessToken,
  }) {
    return _chatService.getConversations(accessToken: accessToken);
  }

  Future<ChatConversation> createConversation({
    required String accessToken,
    required String listingId,
  }) {
    return _chatService.createConversation(
      accessToken: accessToken,
      listingId: listingId,
    );
  }

  Future<ChatConversation> getConversation({
    required String accessToken,
    required String conversationId,
  }) {
    return _chatService.getConversation(
      accessToken: accessToken,
      conversationId: conversationId,
    );
  }

  Future<List<ChatMessage>> getMessages({
    required String accessToken,
    required String conversationId,
  }) {
    return _chatService.getMessages(
      accessToken: accessToken,
      conversationId: conversationId,
    );
  }

  Future<ChatMessage> sendMessage({
    required String accessToken,
    required String conversationId,
    required String body,
  }) {
    return _chatService.sendMessage(
      accessToken: accessToken,
      conversationId: conversationId,
      body: body,
    );
  }
}