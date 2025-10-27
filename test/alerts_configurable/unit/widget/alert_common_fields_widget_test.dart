import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_common_fields.dart';

void main() {
  group('AlertCommonFields', () {
    late TextEditingController dateController;
    late TextEditingController timeController;
    late bool dateTapped;
    late bool timeTapped;

    setUp(() {
      dateController = TextEditingController();
      timeController = TextEditingController();
      dateTapped = false;
      timeTapped = false;
    });

    testWidgets('displays the fields with correct hints and labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCommonFields(
              dateController: dateController,
              timeController: timeController,
              onSelectDate: () {},
              onSelectTime: () {},
            ),
          ),
        ),
      );

      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('TIME'), findsOneWidget);


      expect(find.text('HH:MM'), findsOneWidget);

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('calls onSelectDate and onSelectTime when tapping the fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCommonFields(
              dateController: dateController,
              timeController: timeController,
              onSelectDate: () => dateTapped = true,
              onSelectTime: () => timeTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('date_field')));
      await tester.pump();
      expect(dateTapped, isTrue);

      await tester.tap(find.byKey(const Key('time_field')));
      await tester.pump();
      expect(timeTapped, isTrue);
    });
  });
}
