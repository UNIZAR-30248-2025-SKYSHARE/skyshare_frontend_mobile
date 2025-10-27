import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/empty_alerts_widget.dart';

void main() {
  testWidgets('EmptyAlertsWidget displays icon and texts correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyAlertsWidget(),
        ),
      ),
    );

    expect(find.byKey(const Key('empty_alerts_icon')), findsOneWidget);
    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);

    expect(find.byKey(const Key('empty_alerts_title')), findsOneWidget);
    expect(find.text("You don't have alerts"), findsOneWidget);

    expect(find.byKey(const Key('empty_alerts_subtitle')), findsOneWidget);
    expect(
      find.text(" Make your first astronomical alert \nso you don't miss any event"),
      findsOneWidget,
    );
  });
}
