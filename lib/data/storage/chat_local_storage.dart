import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatLocalStorage {
  static const _conversationsKey = 'cached_conversations';
  static const _messagesPrefix = 'cached_messages_';
  static const _syncTimestampPrefix = 'chat_sync_';
  static const _conversationTimestampPrefix = 'conversation_sync_';

  /// Ottiene tutte le conversazioni dal cache
  Future<List<Map<String, dynamic>>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_conversationsKey);

    if (jsonString == null) return [];

    try {
      final List decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Salva tutte le conversazioni nel cache
  Future<void> saveConversations(List<Map<String, dynamic>> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(conversations);
    await prefs.setString(_conversationsKey, jsonString);
    // Aggiorna timestamp di sincronizzazione globale
    await prefs.setInt(_syncTimestampPrefix, DateTime.now().millisecondsSinceEpoch);
  }

  /// Aggiorna una singola conversazione nel cache (più efficiente che riscrivere tutto)
  Future<void> updateConversation(String conversationId, Map<String, dynamic> conversation) async {
    final conversations = await getConversations();
    final index = conversations.indexWhere((c) => c['id'] == conversationId);

    if (index >= 0) {
      conversations[index] = conversation;
    } else {
      conversations.add(conversation);
    }

    await saveConversations(conversations);
  }

  /// Rimuove una conversazione dal cache
  Future<void> deleteConversation(String conversationId) async {
    final conversations = await getConversations();
    conversations.removeWhere((c) => c['id'] == conversationId);
    await saveConversations(conversations);
  }

  /// Ottiene i messaggi per una conversazione
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_messagesPrefix$conversationId';
    final jsonString = prefs.getString(key);

    if (jsonString == null) return [];

    try {
      final List decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Salva tutti i messaggi per una conversazione
  Future<void> saveMessages(
    String conversationId,
    List<Map<String, dynamic>> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_messagesPrefix$conversationId';
    final jsonString = jsonEncode(messages);
    await prefs.setString(key, jsonString);
    // Aggiorna timestamp di sincronizzazione per questa conversazione
    await prefs.setInt('$_conversationTimestampPrefix$conversationId',
        DateTime.now().millisecondsSinceEpoch);
  }

  /// Aggiunge un singolo messaggio al cache (più efficiente che riscrivere tutto)
  Future<void> addMessage(
    String conversationId,
    Map<String, dynamic> message,
  ) async {
    final messages = await getMessages(conversationId);
    messages.add(message);
    await saveMessages(conversationId, messages);
  }

  /// Ottiene l'ultimo timestamp di sincronizzazione
  Future<int?> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_syncTimestampPrefix);
  }

  /// Ottiene l'ultimo timestamp di sincronizzazione per una conversazione
  Future<int?> getConversationSyncTimestamp(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_conversationTimestampPrefix$conversationId');
  }

  /// Pulisce il cache completamente
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversationsKey);
    await prefs.remove(_syncTimestampPrefix);
    
    // Rimuove tutti i messaggi cacheati
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_messagesPrefix) || key.startsWith(_conversationTimestampPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// Pulisce i messaggi di una conversazione specifica
  Future<void> clearConversationMessages(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_messagesPrefix$conversationId';
    await prefs.remove(key);
    await prefs.remove('$_conversationTimestampPrefix$conversationId');
  }
}