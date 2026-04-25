import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/chat_repository.dart';
import 'package:marketplace_flutter_application/models/chats/chat_message.dart';
import 'package:marketplace_flutter_application/ui/chat/chat_detail_view_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';
import 'package:provider/provider.dart';

class ChatDetailView extends StatefulWidget {
  final String conversationId;

  const ChatDetailView({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  late final ChatDetailViewModel _viewModel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();

    _viewModel = ChatDetailViewModel(
      chatRepository: context.read<ChatRepository>(),
      authRepository: context.read<AuthRepository>(),
      conversationId: widget.conversationId,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoad();
    });
  }

  Future<void> _checkAuthAndLoad() async {
    final authRepository = context.read<AuthRepository>();
    final token = await authRepository.getAccessToken();

    if (!mounted) return;

    if (token == null || token.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to open this chat.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go('/login');
      return;
    }

    setState(() {
      _checkingAuth = false;
    });

    await _viewModel.loadChat();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    final connectivityModel = context.read<ConnectivityModel>();

    if (!connectivityModel.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are offline. Connect to send messages.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _messageController.clear();

    await _viewModel.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivityModel = context.watch<ConnectivityModel>();

    if (_checkingAuth) {
      return const Scaffold(
        backgroundColor: Color(0xFFEEF2F7),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final conversation = _viewModel.conversation;

        return Scaffold(
          backgroundColor: const Color(0xFFEEF2F7),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation?.otherUser.name ?? 'Chat',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                if (conversation != null)
                  Text(
                    conversation.listingTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
              ],
            ),
          ),
          body: Column(
            children: [
              if (!connectivityModel.isOnline) const ConnectivityView(),
              Expanded(child: _buildBody()),
              _MessageInput(
                controller: _messageController,
                isSending: _viewModel.isSending,
                isOnline: connectivityModel.isOnline,
                onSend: _sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF666666)),
          ),
        ),
      );
    }

    if (_viewModel.messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Start the conversation.',
          style: TextStyle(color: Color(0xFF666666)),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: _viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = _viewModel.messages[index];
        final isMine = message.senderId == _viewModel.currentUserId;

        return _MessageBubble(
          message: message,
          isMine: isMine,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFF3483FA) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMine ? 14 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 14),
          ),
        ),
        child: Text(
          message.body,
          style: TextStyle(
            fontSize: 14,
            color: isMine ? Colors.white : const Color(0xFF1F1F1F),
          ),
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final bool isOnline;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.isSending,
    required this.isOnline,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: isOnline,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!isSending && isOnline) onSend();
                },
                decoration: InputDecoration(
                  hintText: isOnline
                      ? 'Write a message...'
                      : 'Connect to send messages',
                  filled: true,
                  fillColor: const Color(0xFFF2F4F7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: isSending || !isOnline ? null : onSend,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              color: const Color(0xFF3483FA),
            ),
          ],
        ),
      ),
    );
  }
}