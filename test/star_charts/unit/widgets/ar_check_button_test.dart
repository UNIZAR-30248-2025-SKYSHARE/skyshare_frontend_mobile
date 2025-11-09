import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/ar_button.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('ARCheckButton', () {
    late VoidCallback onARAvailable;

    setUp(() {
      onARAvailable = MockVoidCallback().call;
    });

    testWidgets('renders correctly with all elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ARCheckButton(onARAvailable: onARAvailable),
          ),
        ),
      );

      expect(find.text('Ver en AR'), findsOneWidget);
      expect(find.byIcon(Icons.view_in_ar), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onARAvailable when pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ARCheckButton(onARAvailable: onARAvailable),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); 

      verify(() => onARAvailable()).called(1);
    });

    testWidgets('has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ARCheckButton(onARAvailable: onARAvailable),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = elevatedButton.style;

      expect(style?.backgroundColor?.resolve(<WidgetState>{}), const Color(0xFF6366F1));
      expect(style?.padding?.resolve(<WidgetState>{}), const EdgeInsets.symmetric(vertical: 16));
    });
  });
}
