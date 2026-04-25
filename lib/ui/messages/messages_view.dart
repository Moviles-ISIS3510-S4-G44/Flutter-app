import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/models/chats/chat_conversation.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';
import 'package:marketplace_flutter_application/ui/messages/messages_view_model.dart';
import 'package:marketplace_flutter_application/ui/shared/widgets/app_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_checkAuthAndLoad);
  }

  Future<void> _checkAuthAndLoad() async {
    final authRepository = context.read<AuthRepository>();
    final token = await authRepository.getAccessToken();

    if (!mounted) return;

    if (token == null || token.trim().isEmpty) {
      debugPrint('NO TOKEN FOR CHAT - REDIRECTING TO LOGIN');
      context.go('/login');
      return;
    }

    setState(() {
      _checkingAuth = false;
    });

    await context.read<MessagesViewModel>().loadConversations(
          accessToken: token,
        );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/Home');
        break;
      case 1:
        context.go('/Sell');
        break;
      case 2:
        context.go('/cart');
        break;
      case 3:
        context.go('/messages');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityModel = context.watch<ConnectivityModel>();
    final viewModel = context.watch<MessagesViewModel>();

    if (_checkingAuth) {
      return const Scaffold(
        backgroundColor: Color(0xFFEEF2F7),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2F7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!connectivityModel.isOnline) const ConnectivityView(),
            Expanded(
              child: _MessagesContent(viewModel: viewModel),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 3,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}

class _MessagesContent extends StatelessWidget {
  final MessagesViewModel viewModel;

  const _MessagesContent({
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ),
      );
    }

    if (viewModel.conversations.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF666666),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: viewModel.conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final conversation = viewModel.conversations[index];

        return _ConversationCard(
          conversation: conversation,
          onTap: () {
            context.push('/messages/${conversation.id}');
          },
        );
      },
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = conversation.otherUser.name.isNotEmpty
        ? conversation.otherUser.name[0].toUpperCase()
        : '?';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEAF1FF),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF3483FA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.otherUser.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.listingTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.lastMessageBody.isEmpty
                          ? 'No messages yet'
                          : conversation.lastMessageBody,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF999999),
              ),
            ],
          ),
        ),
      ),
    );
  }
}