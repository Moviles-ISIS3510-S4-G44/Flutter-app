import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/repositories/chat_repository.dart';
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';

class MessagesViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  MessagesViewModel({
    required ChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  bool isLoading = false;
  String? errorMessage;
  List<ChatConversation> conversations = [];

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

      conversations = await _chatRepository.getConversations(
        accessToken: cleanToken,
      );
    } catch (error) {
      conversations = [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshConversations({
    required String accessToken,
  }) async {
    await loadConversations(accessToken: accessToken);
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  bool get hasConversations => conversations.isNotEmpty;

  bool get isEmptyState =>
      !isLoading && errorMessage == null && conversations.isEmpty;
}