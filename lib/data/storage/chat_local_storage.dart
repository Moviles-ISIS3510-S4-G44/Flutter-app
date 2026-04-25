import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatLocalStorage {
  static const _conversationsKey = 'cached_conversations';
  static const _messagesPrefix = 'cached_messages_';

  Future<void> saveConversations(List<Map<String, dynamic>> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(conversations);
    await prefs.setString(_conversationsKey, jsonString);
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_conversationsKey);

    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }


  Future<void> saveMessages(
    String conversationId,
    List<Map<String, dynamic>> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_messagesPrefix$conversationId';

    final jsonString = jsonEncode(messages);
    await prefs.setString(key, jsonString);
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_messagesPrefix$conversationId';

    final jsonString = prefs.getString(key);

    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }
}