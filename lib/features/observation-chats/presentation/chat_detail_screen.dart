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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2F),
      appBar: AppBar(
        title: Text(groupName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.messages.isEmpty
                    ? Center(
                        child: Text(
                          localizations.t('chat.no_messages_chat'),
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages.reversed.toList()[index];
                          return ChatBubble(message: message);
                        },
                      ),
          ),
         
          ChatInputBar(
            onSend: (text) {
              providerActions.sendMessage(text);
            },
            hintText: localizations.t('spot.write_comment_hint'), // Reutilizamos esta clave para el hint
          ),
        ],
      ),
    );
  }
}