import 'package:marketplace_flutter_application/data/services/chat_service.dart';
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';

class ChatRepository {
  final ChatService _chatService;

  ChatRepository({required ChatService chatService})
    : _chatService = chatService;

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
}
