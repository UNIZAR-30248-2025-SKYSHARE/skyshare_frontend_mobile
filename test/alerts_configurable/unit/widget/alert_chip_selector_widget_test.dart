import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_chip_selector.dart';

void main() {
  group('AlertChipSelector', () {
    testWidgets('displays label and options', (tester) async {
      final options = ['Option 1', 'Option 2', 'Option 3']; 
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertChipSelector(
              options: options,
              selectedValue: null,
              label: 'Alert Type', 
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('ALERT TYPE'), findsOneWidget);

      for (var option in options) {
        expect(find.text(option), findsOneWidget);
      }
    });

    testWidgets('selects a chip and calls onChanged', (tester) async {
      final options = ['Option 1', 'Option 2']; 
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertChipSelector(
              options: options,
              selectedValue: null,
              label: 'Type', 
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();

      expect(selected, 'Option 2');

      final choiceChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Option 2'));
      expect(choiceChip.selected, isTrue);
    });

    testWidgets('deselects a chip when tapped again', (tester) async {
      final options = ['Option A']; 
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertChipSelector(
              options: options,
              selectedValue: 'Option A', 
              label: 'Test',
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      );

      // Tap to deselect
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      expect(selected, null);

      final choiceChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Option A'));
      expect(choiceChip.selected, isFalse);
    });

    testWidgets('starts with a selected value', (tester) async {
      final options = ['Option X', 'Option Y']; 
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertChipSelector(
              options: options,
              selectedValue: 'Option Y', 
              label: 'Test',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final chipY = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Option Y'));
      expect(chipY.selected, isTrue);

      final chipX = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Option X'));
      expect(chipX.selected, isFalse);
    });
  });
}
