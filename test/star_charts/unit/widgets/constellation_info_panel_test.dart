import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/constellation_info_panel.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('ConstellationInfoPanel', () {
    late VoidCallback onClose;
    late Map<String, dynamic> object;

    setUp(() {
      onClose = MockVoidCallback().call;
      object = {
        'name': 'Orion',
        'type': 'constellation',
        'alt': 45.0,
        'az': 120.0,
      };
    });

    testWidgets('renders correctly with constellation data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Stack(
              children: [
                ConstellationInfoPanel(object: object, onClose: onClose),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Orion'), findsOneWidget);
      
      expect(find.text('Type:'), findsOneWidget);
      expect(find.text('Constellation'), findsOneWidget);
      
      expect(find.text('Position:'), findsOneWidget);
      expect(find.text('Alt: 45.0° Az: 120.0°'), findsOneWidget);
      
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('renders different icons for different types', (WidgetTester tester) async {
      final starObject = {'name': 'Sirius', 'type': 'star'};
      
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Stack(
              children: [
                ConstellationInfoPanel(object: starObject, onClose: onClose),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Star'), findsOneWidget);
    });

    testWidgets('calls onClose when close button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Stack(
              children: [
                ConstellationInfoPanel(object: object, onClose: onClose),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      verify(() => onClose()).called(1);
    });

    testWidgets('handles missing optional fields gracefully', (WidgetTester tester) async {
      final minimalObject = {'name': 'Unknown Object'};
      
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Stack(
              children: [
                ConstellationInfoPanel(object: minimalObject, onClose: onClose),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Unknown Object'), findsOneWidget);
      expect(find.byIcon(Icons.help), findsOneWidget);
      
      expect(find.text('Type:'), findsNothing);
      expect(find.text('Position:'), findsNothing);
    });
  });
}