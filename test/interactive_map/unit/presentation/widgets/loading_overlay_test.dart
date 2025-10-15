import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/loading_overlay.dart';

void main() {
  testWidgets('muestra CircularProgressIndicator cuando isLoading es true', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(isLoading: true),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final finder = find.descendant(
      of: find.byType(LoadingOverlay),
      matching: find.byType(AbsorbPointer),
    );
    expect(finder, findsOneWidget);
  });

  testWidgets('no muestra nada cuando isLoading es false', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(isLoading: false),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);

    final finder = find.descendant(
      of: find.byType(LoadingOverlay),
      matching: find.byType(AbsorbPointer),
    );
    expect(finder, findsNothing);
  });

  testWidgets('AbsorbPointer bloquea interacciones cuando está cargando', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              LoadingOverlay(isLoading: true),
              Text('Contenido'),
            ],
          ),
        ),
      ),
    );

    final finder = find.descendant(
      of: find.byType(LoadingOverlay),
      matching: find.byType(AbsorbPointer),
    );
    expect(finder, findsOneWidget);

    final absorbPointer = tester.widget<AbsorbPointer>(finder);
    expect(absorbPointer.absorbing, isTrue);
  });
}
