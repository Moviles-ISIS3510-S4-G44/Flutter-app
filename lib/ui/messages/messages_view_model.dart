import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/repositories/chat_repository.dart';
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';

class MessagesViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  // Control para evitar sincronizaciones demasiado frecuentes
  DateTime? _lastSyncTime;
  static const _syncDebounceMs = 5000; // 5 segundos

  MessagesViewModel({
    required ChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  bool isLoading = false;
  bool _isSyncing = false;
  String? errorMessage;
  List<ChatConversation> conversations = [];

  /// Carga conversaciones: primero desde caché, luego intenta sincronizar con API
  /// Implementa debounce para evitar llamadas frecuentes
  Future<void> loadConversations({
    required String accessToken,
  }) async {
    final cleanToken = accessToken.trim();

    if (cleanToken.isEmpty || cleanToken.split('.').length != 3) {
      errorMessage = 'Invalid access token for chat.';
      conversations = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('CHAT TOKEN VALID: ${cleanToken.substring(0, 12)}...');

      // Cargar desde caché primero
      conversations = await _chatRepository.getCachedConversations();

      // Decidir si sincronizar basado en tiempo transcurrido
      final now = DateTime.now();
      final shouldSync = _lastSyncTime == null ||
          now.difference(_lastSyncTime!).inMilliseconds > _syncDebounceMs;

      if (shouldSync) {
        _isSyncing = true;
        _lastSyncTime = now;

        try {
          conversations = await _chatRepository.getConversations(
            accessToken: cleanToken,
          );
          errorMessage = null;
        } catch (syncError) {
          // Si falla pero hay caché, mostrar advertencia suave
          if (conversations.isEmpty) {
            errorMessage = 'Offline: Using cached conversations';
          } else {
            debugPrint('Sync error (cached data available): $syncError');
          }
        } finally {
          _isSyncing = false;
        }
      }
    } catch (error) {
      conversations = [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Recarga conversaciones desde el API, mostrando spinner
  Future<void> refreshConversations({
    required String accessToken,
  }) async {
    _lastSyncTime = null; // Fuerza sincronización
    await loadConversations(accessToken: accessToken);
  }

  /// Indica si está sincronizando en background
  bool get isSyncing => _isSyncing;

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  bool get hasConversations => conversations.isNotEmpty;

  @override
  void dispose() {
    super.dispose();
  }
}

  bool get isEmptyState =>
      !isLoading && errorMessage == null && conversations.isEmpty;
}