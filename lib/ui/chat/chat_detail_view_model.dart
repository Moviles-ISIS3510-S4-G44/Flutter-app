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
  Future<void> loadChat() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await _getToken();
      currentUserId = _extractUserIdFromToken(token);

      // Cargar desde caché primero
      try {
        messages = await _chatRepository.getCachedMessages(conversationId);
        messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      } catch (_) {
        // Si no hay caché, continuar
      }

      // Sincronizar con API en background
      _isSyncing = true;
      try {
        conversation = await _chatRepository.getConversation(
          accessToken: token,
          conversationId: conversationId,
        );

        messages = await _chatRepository.getMessages(
          accessToken: token,
          conversationId: conversationId,
        );

        messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
        errorMessage = null; // Limpiar error si la sincronización funciona
      } catch (syncError) {
        // Si falla la sincronización pero hay caché, mostrar advertencia suave
        if (messages.isEmpty) {
          errorMessage = 'Offline: Using cached messages';
        } else {
          debugPrint('Sync error (but cached data available): $syncError');
        }
      } finally {
        _isSyncing = false;
      }
    } catch (error) {
      errorMessage = error.toString();
      messages = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Envía un mensaje al servidor
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

      conversation = await _chatRepository.getConversation(
        accessToken: token,
        conversationId: conversationId,
      );
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  /// Indica si está sincronizando en background
  bool get isSyncing => _isSyncing;
}