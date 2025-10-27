import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alerts_header_widget.dart';

void main() {
  testWidgets('muestra correctamente total y activas', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AlertsHeaderWidget(
            totalAlerts: 5,
            activeAlerts: 3,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('alerts_header_container')), findsOneWidget);
    expect(find.byKey(const Key('alerts_header_total')), findsOneWidget);
    expect(find.text('5 alerts'), findsOneWidget);

    expect(find.byKey(const Key('alerts_header_active')), findsOneWidget);
    expect(find.text('3 activas'), findsOneWidget);
  });
}
