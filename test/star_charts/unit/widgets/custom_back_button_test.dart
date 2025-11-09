import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/custom_back_button.dart';

class MockNavigator extends Mock implements NavigatorObserver {}

void main() {
  group('CustomBackButton', () {
    testWidgets('renders with default styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomBackButton(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final icon = iconButton.icon as Icon;

      expect(container.margin, const EdgeInsets.all(16));
      expect(icon.icon, Icons.arrow_back);
      expect(icon.color, Colors.white);
    });

    testWidgets('uses custom colors when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomBackButton(
              backgroundColor: Colors.red,
              iconColor: Colors.blue,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration?;
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final icon = iconButton.icon as Icon;

      expect(decoration?.color, Colors.red);
      expect(icon.color, Colors.blue);
    });

    testWidgets('calls custom onPressed when provided', (WidgetTester tester) async {
      var customPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBackButton(
              onPressed: () => customPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      
      expect(customPressed, true);
    });
  });
}