import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/chat_repository.dart';
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';
import 'package:marketplace_flutter_application/models/chats/chat_message.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final AuthRepository _authRepository;
  final String conversationId;

  // Control para evitar sincronizaciones demasiado frecuentes
  DateTime? _lastSyncTime;
  static const _syncDebounceMs = 3000; // 3 segundos

  ChatDetailViewModel({
    required ChatRepository chatRepository,
    required AuthRepository authRepository,
    required this.conversationId,
  })  : _chatRepository = chatRepository,
        _authRepository = authRepository;

  bool isLoading = false;
  bool isSending = false;
  bool _isSyncing = false;
  String? errorMessage;

  String? currentUserId;
  ChatConversation? conversation;
  List<ChatMessage> messages = [];

  Future<String> _getToken() async {
    final token = await _authRepository.getAccessToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('No active session found.');
    }

    return token;
  }

  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      return json['sub'] as String? ??
          json['user_id'] as String? ??
          json['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Carga el chat: primero desde caché, luego sincroniza con API
  /// Implementa debounce para evitar llamadas frecuentes
  Future<void> loadChat() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await _getToken();
      currentUserId = _extractUserIdFromToken(token);

      // Cargar desde caché primero (respuesta instantánea)
      try {
        messages = await _chatRepository.getCachedMessages(conversationId);
        messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      } catch (_) {
        // Si no hay caché, continuar
      }

      // Decidir si sincronizar basado en tiempo transcurrido
      final now = DateTime.now();
      final shouldSync = _lastSyncTime == null ||
          now.difference(_lastSyncTime!).inMilliseconds > _syncDebounceMs;

      if (shouldSync) {
        _isSyncing = true;
        _lastSyncTime = now;

        try {
          // Sincronizar en paralelo para mejor performance
          final conversationFuture = _chatRepository.getConversation(
            accessToken: token,
            conversationId: conversationId,
          );

          final messagesFuture = _chatRepository.getMessages(
            accessToken: token,
            conversationId: conversationId,
          );

          final results = await Future.wait(
            [conversationFuture, messagesFuture] as List<Future<dynamic>>,
            eagerError: false,
          );

          conversation = results[0] as ChatConversation;
          messages = results[1] as List<ChatMessage>;

          messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
          errorMessage = null;
        } catch (syncError) {
          // Si falla pero hay caché, mostrar advertencia suave
          if (messages.isEmpty) {
            errorMessage = 'Offline: Using cached messages';
          } else {
            debugPrint('Sync error (cached data available): $syncError');
          }
        } finally {
          _isSyncing = false;
        }
      }
    } catch (error) {
      errorMessage = error.toString();
      messages = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Recarga el chat forzando sincronización
  Future<void> refreshChat() async {
    _lastSyncTime = null; // Fuerza sincronización
    await loadChat();
  }

  /// Envía un mensaje al servidor
  /// Más eficiente: solo agrega el nuevo mensaje al caché
  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty || isSending) return;

    isSending = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await _getToken();

      currentUserId ??= _extractUserIdFromToken(token);

      final newMessage = await _chatRepository.sendMessage(
        accessToken: token,
        conversationId: conversationId,
        body: cleanText,
      );

      messages = [...messages, newMessage];
      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

      // Actualizar conversación sin bloquear UI
      _chatRepository.getConversation(
        accessToken: token,
        conversationId: conversationId,
      ).then((conv) {
        conversation = conv;
        notifyListeners();
      }).catchError((_) {
        // Silenciar error si falla
      });
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  /// Indica si está sincronizando en background
  bool get isSyncing => _isSyncing;

  /// Limpia el caché de esta conversación
  Future<void> clearCache() async {
    await _chatRepository.clearConversationCache(conversationId);
    messages = [];
    conversation = null;
    _lastSyncTime = null;
    notifyListeners();
  }
}