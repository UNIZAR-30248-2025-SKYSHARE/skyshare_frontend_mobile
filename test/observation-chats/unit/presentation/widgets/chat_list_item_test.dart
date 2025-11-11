import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/models/chat_preview_model.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/presentation/widgets/chat_list_item.dart';

void main() {
  Widget createTestWidget(ChatPreview chat) {
    return MaterialApp(
      home: Scaffold(
        body: ChatListItem(chat: chat),
      ),
    );
  }

  testWidgets('muestra el nombre del grupo y el último mensaje', (tester) async {
    final chat = ChatPreview(
      idGrupo: 1,
      nombreGrupo: 'Grupo Test',
      ultimoMensajeTexto: 'Hola a todos',
      ultimoMensajeSenderNombre: 'Juan',
      ultimoMensajeFecha: DateTime.now(),
    );

    await tester.pumpWidget(createTestWidget(chat));

    expect(find.text('Grupo Test'), findsOneWidget);
    expect(find.text('Juan: Hola a todos'), findsOneWidget);
    expect(find.byIcon(Icons.group), findsOneWidget);
  });

  testWidgets('muestra "No hay mensajes" si no hay último mensaje', (tester) async {
    final chat = ChatPreview(
      idGrupo: 2,
      nombreGrupo: 'Grupo Vacío',
    );

    await tester.pumpWidget(createTestWidget(chat));

    expect(find.text('Grupo Vacío'), findsOneWidget);
    expect(find.text('No hay mensajes'), findsOneWidget);
  });
}