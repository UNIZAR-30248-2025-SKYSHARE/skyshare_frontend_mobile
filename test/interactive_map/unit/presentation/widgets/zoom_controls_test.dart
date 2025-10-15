import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/zoom_controls.dart';

void main() {
  testWidgets('renderiza botones de zoom in y zoom out', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZoomControls(
            onZoomIn: () {},
            onZoomOut: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    expect(find.byType(Positioned), findsOneWidget);
  });

  testWidgets('botones de zoom tienen tamaño mini', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZoomControls(
            onZoomIn: () {},
            onZoomOut: () {},
          ),
        ),
      ),
    );

    final fabButtons = tester.widgetList<FloatingActionButton>(find.byType(FloatingActionButton));
    for (final button in fabButtons) {
      expect(button.mini, isTrue);
    }
  });

  testWidgets('llama onZoomIn cuando se presiona botón de zoom in', (tester) async {
    var zoomInCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZoomControls(
            onZoomIn: () => zoomInCalled = true,
            onZoomOut: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    expect(zoomInCalled, isTrue);
  });

  testWidgets('llama onZoomOut cuando se presiona botón de zoom out', (tester) async {
    var zoomOutCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZoomControls(
            onZoomIn: () {},
            onZoomOut: () => zoomOutCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove));
    expect(zoomOutCalled, isTrue);
  });

  testWidgets('botones tienen heroTags únicos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZoomControls(
            onZoomIn: () {},
            onZoomOut: () {},
          ),
        ),
      ),
    );

    final fabButtons = tester.widgetList<FloatingActionButton>(find.byType(FloatingActionButton));
    final heroTags = fabButtons.map((button) => button.heroTag).toList();
    
    expect(heroTags.contains('zoomIn'), isTrue);
    expect(heroTags.contains('zoomOut'), isTrue);
  });
}