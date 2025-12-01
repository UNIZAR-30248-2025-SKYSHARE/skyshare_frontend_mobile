import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_detail_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class ChatDetailScreen extends StatelessWidget {
  final String groupName;
 
  const ChatDetailScreen({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatDetailProvider>();
    final providerActions = context.read<ChatDetailProvider>();
    
    final loc = AppLocalizations.of(context);

    final visibleMessages = provider.messages.where((msg) => !provider.undecipherableMessageIds.contains(msg.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2F),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(groupName, style: const TextStyle(color: Colors.white)),
            if (provider.hasUndecipherableMessages)
              Text(
                loc?.t('chat.undecipherable_messages') ?? 'Mensajes no descifrados',
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : visibleMessages.isEmpty
                    ? Center(
                        child: Text(
                          loc?.t('chat.no_messages_chat') ?? 'No messages. Be the first!',
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: visibleMessages.length,
                        itemBuilder: (context, index) {
                          final message = visibleMessages[index];
                          return ChatBubble(message: message);
                        },
                      ),
          ),
         
          ChatInputBar(
            onSend: (text) {
              providerActions.sendMessage(text);
            },
            hintText: loc?.t('spot.write_comment_hint') ?? 'Write a message...', 
          ),
        ],
      ),
    );
  }
}