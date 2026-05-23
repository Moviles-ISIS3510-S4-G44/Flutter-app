import 'package:marketplace_flutter_application/data/services/chat_service.dart';
import 'package:marketplace_flutter_application/data/storage/chat_local_storage.dart';
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';
import 'package:marketplace_flutter_application/models/chats/chat_message.dart';

class ChatRepository {
  final ChatService _chatService;
  final ChatLocalStorage _localStorage;

  // Cache en memoria para evitar deserializaciones repetidas
  List<ChatConversation>? _conversationsCache;
  Map<String, List<ChatMessage>> _messagesCache = {};

  ChatRepository({
    required ChatService chatService,
    ChatLocalStorage? localStorage,
  })  : _chatService = chatService,
        _localStorage = localStorage ?? ChatLocalStorage();

  /// Obtiene conversaciones: intenta online primero, fallback a caché
  /// Usa caché en memoria cuando está disponible
  Future<List<ChatConversation>> getConversations({
    required String accessToken,
  }) async {
    try {
      final conversations = await _chatService.getConversations(
        accessToken: accessToken,
      );

      // Actualizar caché de memoria
      _conversationsCache = conversations;

      // Guardar en caché persistente (no await, background)
      _localStorage.saveConversations(
        conversations.map((c) => _conversationToJson(c)).toList(),
      ).ignore();

      return conversations;
    } catch (e) {
      // Si falla, intenta caché de memoria primero
      if (_conversationsCache != null) {
        return _conversationsCache!;
      }

      // Fallback a caché persistente
      final cachedData = await _localStorage.getConversations();
      final conversations = cachedData
          .map((json) => ChatConversation.fromJson(json))
          .toList();

      _conversationsCache = conversations;
      return conversations;
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

    // Actualizar caché en memoria
    if (_conversationsCache != null) {
      _conversationsCache!.add(conversation);
    }

    // Actualizar caché persistente (no await, background)
    _localStorage.updateConversation(
      conversation.id,
      _conversationToJson(conversation),
    ).ignore();

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

      // Actualizar caché en memoria
      if (_conversationsCache != null) {
        final index =
            _conversationsCache!.indexWhere((c) => c.id == conversationId);
        if (index >= 0) {
          _conversationsCache![index] = conversation;
        }
      }

      // Actualizar caché persistente (no await, background)
      _localStorage.updateConversation(
        conversationId,
        _conversationToJson(conversation),
      ).ignore();

      return conversation;
    } catch (e) {
      // Intenta obtener desde caché de memoria
      if (_conversationsCache != null) {
        final cached = _conversationsCache!
            .firstWhere((c) => c.id == conversationId,
                orElse: () => throw Exception(
                      'Conversation not found: $e',
                    ));
        return cached;
      }

      // Intenta obtener desde caché persistente
      final cachedData = await _localStorage.getConversations();
      final cachedConv = cachedData.firstWhere(
        (c) => c['id'] == conversationId,
        orElse: () => throw Exception(
          'Conversation not found and offline: $e',
        ),
      );
      return ChatConversation.fromJson(cachedConv);
    }
  }

  /// Obtiene mensajes: intenta online primero, fallback a caché
  /// Usa caché en memoria cuando está disponible
  Future<List<ChatMessage>> getMessages({
    required String accessToken,
    required String conversationId,
  }) async {
    try {
      final messages = await _chatService.getMessages(
        accessToken: accessToken,
        conversationId: conversationId,
      );

      // Actualizar caché en memoria
      _messagesCache[conversationId] = messages;

      // Guardar en caché persistente (no await, background)
      _localStorage.saveMessages(
        conversationId,
        messages.map((m) => _messageToJson(m)).toList(),
      ).ignore();

      return messages;
    } catch (e) {
      // Si falla, intenta caché de memoria primero
      if (_messagesCache.containsKey(conversationId)) {
        return _messagesCache[conversationId]!;
      }

      // Fallback a caché persistente
      final cachedData = await _localStorage.getMessages(conversationId);
      final messages =
          cachedData.map((json) => ChatMessage.fromJson(json)).toList();

      _messagesCache[conversationId] = messages;
      return messages;
    }
  }

  /// Envía un mensaje al servidor
  /// Más eficiente: solo agrega el nuevo mensaje al caché
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

    // Actualizar caché en memoria
    if (_messagesCache.containsKey(conversationId)) {
      _messagesCache[conversationId]!.add(message);
    }

    // Guardar en caché persistente (no await, background)
    _localStorage.addMessage(
      conversationId,
      _messageToJson(message),
    ).ignore();

    return message;
  }

  /// Obtiene mensajes desde caché sin intentar conexión (para offline)
  Future<List<ChatMessage>> getCachedMessages(String conversationId) async {
    // Primero intenta caché en memoria
    if (_messagesCache.containsKey(conversationId)) {
      return _messagesCache[conversationId]!;
    }

    // Luego caché persistente
    final cachedData = await _localStorage.getMessages(conversationId);
    final messages =
        cachedData.map((json) => ChatMessage.fromJson(json)).toList();

    _messagesCache[conversationId] = messages;
    return messages;
  }

  /// Obtiene conversaciones desde caché sin intentar conexión (para offline)
  Future<List<ChatConversation>> getCachedConversations() async {
    // Primero intenta caché en memoria
    if (_conversationsCache != null) {
      return _conversationsCache!;
    }

    // Luego caché persistente
    final cachedData = await _localStorage.getConversations();
    final conversations = cachedData
        .map((json) => ChatConversation.fromJson(json))
        .toList();

    _conversationsCache = conversations;
    return conversations;
  }

  /// Limpia los cachés (útil al logout)
  Future<void> clearCache() async {
    _conversationsCache = null;
    _messagesCache.clear();
    await _localStorage.clearAll();
  }

  /// Limpia los mensajes de una conversación específica
  Future<void> clearConversationCache(String conversationId) async {
    _messagesCache.remove(conversationId);
    await _localStorage.clearConversationMessages(conversationId);
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