import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/error_banner.dart';

void main() {
  testWidgets('muestra mensaje de error cuando errorMessage no es nulo', (tester) async {
    const errorMessage = 'Error de prueba';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorBanner(errorMessage: errorMessage),
        ),
      ),
    );

    expect(find.text(errorMessage), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(Positioned), findsOneWidget);
  });

  testWidgets('no muestra nada cuando errorMessage es nulo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorBanner(errorMessage: null),
        ),
      ),
    );

    expect(find.byType(Card), findsNothing);
    expect(find.byType(Positioned), findsNothing);
  });

  testWidgets('Card tiene color rojo cuando hay error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorBanner(errorMessage: 'Error'),
        ),
      ),
    );

    final card = tester.widget<Card>(find.byType(Card));
    expect(card.color, Colors.red[700]);
  });

  testWidgets('texto del error es blanco', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorBanner(errorMessage: 'Error de prueba'),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Error de prueba'));
    final style = text.style;
    expect(style?.color, Colors.white);
  });
}