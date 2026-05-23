import 'package:marketplace_flutter_application/data/services/chat_service.dart';
import 'package:marketplace_flutter_application/data/storage/chat_local_storage.dart';
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';
import 'package:marketplace_flutter_application/models/chats/chat_message.dart';

class ChatRepository {
  final ChatService _chatService;
  final ChatLocalStorage _localStorage;

  ChatRepository({
    required ChatService chatService,
    ChatLocalStorage? localStorage,
  })  : _chatService = chatService,
        _localStorage = localStorage ?? ChatLocalStorage();

  /// Obtiene conversaciones: intenta online primero, fallback a caché
  Future<List<ChatConversation>> getConversations({
    required String accessToken,
  }) async {
    try {
      final conversations = await _chatService.getConversations(
        accessToken: accessToken,
      );

      // Guardar en caché después de obtener del API
      await _localStorage.saveConversations(
        conversations.map((c) => _conversationToJson(c)).toList(),
      );

      return conversations;
    } catch (e) {
      // Si falla, retorna desde caché
      final cachedData = await _localStorage.getConversations();
      return cachedData
          .map((json) => ChatConversation.fromJson(json))
          .toList();
    }
  }

  Future<ChatConversation> createConversation({
    required String accessToken,
    required String listingId,
  }) async {
    final conversation = await _chatService.createConversation(
      accessToken: accessToken,
      listingId: listingId,
    );

    // Actualizar caché con la nueva conversación
    final cached = await _localStorage.getConversations();
    cached.add(_conversationToJson(conversation));
    await _localStorage.saveConversations(cached);

    return conversation;
  }

  Future<ChatConversation> getConversation({
    required String accessToken,
    required String conversationId,
  }) async {
    try {
      final conversation = await _chatService.getConversation(
        accessToken: accessToken,
        conversationId: conversationId,
      );

      // Actualizar caché
      final cached = await _localStorage.getConversations();
      final index = cached.indexWhere((c) => c['id'] == conversationId);

      if (index >= 0) {
        cached[index] = _conversationToJson(conversation);
      } else {
        cached.add(_conversationToJson(conversation));
      }

      await _localStorage.saveConversations(cached);

      return conversation;
    } catch (e) {
      // Intenta obtener desde caché
      final cached = await _localStorage.getConversations();
      final cachedConv = cached.firstWhere(
        (c) => c['id'] == conversationId,
        orElse: () => throw Exception(
          'Conversation not found and offline: $e',
        ),
      );
      return ChatConversation.fromJson(cachedConv);
    }
  }

  /// Obtiene mensajes: intenta online primero, fallback a caché
  Future<List<ChatMessage>> getMessages({
    required String accessToken,
    required String conversationId,
  }) async {
    try {
      final messages = await _chatService.getMessages(
        accessToken: accessToken,
        conversationId: conversationId,
      );

      // Guardar en caché
      await _localStorage.saveMessages(
        conversationId,
        messages.map((m) => _messageToJson(m)).toList(),
      );

      return messages;
    } catch (e) {
      // Si falla, retorna desde caché
      final cachedData = await _localStorage.getMessages(conversationId);
      return cachedData.map((json) => ChatMessage.fromJson(json)).toList();
    }
  }

  /// Envía un mensaje: requiere conexión, pero guarda en caché también
  Future<ChatMessage> sendMessage({
    required String accessToken,
    required String conversationId,
    required String body,
  }) async {
    final message = await _chatService.sendMessage(
      accessToken: accessToken,
      conversationId: conversationId,
      body: body,
    );

    // Guardar en caché también
    final cached = await _localStorage.getMessages(conversationId);
    cached.add(_messageToJson(message));
    await _localStorage.saveMessages(conversationId, cached);

    return message;
  }

  /// Obtiene mensajes desde caché sin intentar conexión (para offline)
  Future<List<ChatMessage>> getCachedMessages(String conversationId) async {
    final cachedData = await _localStorage.getMessages(conversationId);
    return cachedData.map((json) => ChatMessage.fromJson(json)).toList();
  }

  /// Obtiene conversaciones desde caché sin intentar conexión (para offline)
  Future<List<ChatConversation>> getCachedConversations() async {
    final cachedData = await _localStorage.getConversations();
    return cachedData.map((json) => ChatConversation.fromJson(json)).toList();
  }

  // Helpers para convertir modelos a JSON
  static Map<String, dynamic> _conversationToJson(
    ChatConversation conversation,
  ) =>
      {
        'id': conversation.id,
        'listing_id': conversation.listingId,
        'buyer_id': conversation.buyerId,
        'seller_id': conversation.sellerId,
        'created_at': conversation.createdAt.toIso8601String(),
        'last_message_at': conversation.lastMessageAt.toIso8601String(),
        'other_user': {
          'id': conversation.otherUser.id,
          'name': conversation.otherUser.name,
        },
        'listing_title': conversation.listingTitle,
        'last_message_body': conversation.lastMessageBody,
      };

  static Map<String, dynamic> _messageToJson(ChatMessage message) => {
        'id': message.id,
        'conversation_id': message.conversationId,
        'sender_id': message.senderId,
        'body': message.body,
        'sent_at': message.sentAt.toIso8601String(),
      };
}