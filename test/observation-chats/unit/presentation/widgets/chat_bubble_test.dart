import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/models/chat_message_model.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/presentation/widgets/chat_bubble.dart';

void main() {
  Widget createTestWidget(ChatMessage message) {
    return MaterialApp(
      home: Scaffold(
        body: ChatBubble(message: message),
      ),
    );
  }

  testWidgets('muestra la burbuja "isMe" (propia) correctamente', (tester) async {
    final message = ChatMessage(
      id: BigInt.one,
      createdAt: DateTime.now(),
      idUsuario: '1',
      texto: 'Este es mi mensaje',
      nombreUsuario: 'Yo',
      isMe: true, 
    );

    await tester.pumpWidget(createTestWidget(message));

    expect(find.text('Este es mi mensaje'), findsOneWidget);
    expect(find.text('Yo'), findsNothing); 
    final row = tester.widget<Row>(find.ancestor(of: find.byType(Flexible), matching: find.byType(Row)));
    expect(row.mainAxisAlignment, MainAxisAlignment.end);
  });

  testWidgets('muestra la burbuja "other" (de otro) correctamente', (tester) async {
    final message = ChatMessage(
      id: BigInt.two,
      createdAt: DateTime.now(),
      idUsuario: '2',
      texto: 'Este es tu mensaje',
      nombreUsuario: 'Otro Usuario',
      isMe: false,
    );

    await tester.pumpWidget(createTestWidget(message));

    expect(find.text('Este es tu mensaje'), findsOneWidget);
    expect(find.text('Otro Usuario'), findsOneWidget); 
    final row = tester.widget<Row>(find.ancestor(of: find.byType(Flexible), matching: find.byType(Row)));
    expect(row.mainAxisAlignment, MainAxisAlignment.start);
  });
}