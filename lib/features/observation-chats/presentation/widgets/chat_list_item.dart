import 'package:flutter/material.dart';
import '../../data/models/chat_preview_model.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';


class ChatListItem extends StatelessWidget {
  final ChatPreview chat;
 
  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    String ultimoMensaje = localizations.t('chat.no_messages_list');

    if (chat.ultimoMensajeSenderNombre != null && chat.ultimoMensajeTexto != null) {
      ultimoMensaje = "${chat.ultimoMensajeSenderNombre}: ${chat.ultimoMensajeTexto}";
    }

    return Card(
      color: const Color(0xFF3A2D4C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.group, size: 40, color: Colors.white70),
        title: Text(
          chat.nombreGrupo,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          ultimoMensaje,
          style: const TextStyle(color: Colors.white70),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}