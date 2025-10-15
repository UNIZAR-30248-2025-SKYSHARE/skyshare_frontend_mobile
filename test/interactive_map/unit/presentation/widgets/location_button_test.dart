import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/location_button.dart';

void main() {
  testWidgets('renderiza botón de ubicación correctamente', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationButton(onPressed: () {}),
        ),
      ),
    );

    expect(find.byIcon(Icons.my_location), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(Positioned), findsOneWidget);
  });

  testWidgets('botón tiene color azul', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationButton(onPressed: () {}),
        ),
      ),
    );

    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.backgroundColor, Colors.blueAccent);
  });

  testWidgets('llama onPressed cuando se presiona el botón', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationButton(onPressed: () => pressed = true),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    expect(pressed, isTrue);
  });

  testWidgets('está posicionado en la esquina inferior derecha', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationButton(onPressed: () {}),
        ),
      ),
    );

    final positioned = tester.widget<Positioned>(find.byType(Positioned));
    expect(positioned.bottom, 20);
    expect(positioned.right, 20);
  });
}