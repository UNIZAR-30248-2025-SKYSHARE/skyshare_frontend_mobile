import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/star_chart_screen.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/custom_back_button.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/star_chart_content.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/providers/star_chart_provider.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/utils/sensor_wrapper.dart';

class MockStarChartProvider extends Mock implements StarChartProvider {}
class MockSensorWrapper extends Mock implements SensorWrapper {}
class MockAccelerometerEvent extends Mock implements AccelerometerEvent {}

void main() {
  group('StarChartScreen', () {
    late MockStarChartProvider mockProvider;
    late MockSensorWrapper mockSensorWrapper;
    late StreamController<AccelerometerEvent> accelerometerController;

    setUp(() {
      mockProvider = MockStarChartProvider();
      mockSensorWrapper = MockSensorWrapper();
      accelerometerController = StreamController<AccelerometerEvent>();
      
      when(() => mockSensorWrapper.accelerometerEvents)
          .thenAnswer((_) => accelerometerController.stream);

      when(() => mockProvider.fetchCelestialBodies(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      )).thenAnswer((_) => Future.value());

      when(() => mockProvider.isLoading).thenReturn(false);
      when(() => mockProvider.visibleBodies).thenReturn([]);
    });

    tearDown(() {
      accelerometerController.close();
    });

    testWidgets('shows calibration guide initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StarChartScreen(
            latitude: 40.4168,
            longitude: -3.7038,
            sensorWrapper: mockSensorWrapper,
          ),
        ),
      );

      expect(find.text('Inicializando sensores...'), findsOneWidget);

      accelerometerController.add(AccelerometerEvent(0, 9.8, 0, DateTime.now()));
      await tester.pump();

      expect(find.text('Coloca el móvil recto y mirando al frente'), findsOneWidget);
    });

    testWidgets('shows star chart content after calibration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<StarChartProvider>.value(
            value: mockProvider,
            child: StarChartScreen(
              latitude: 40.4168,
              longitude: -3.7038,
              sensorWrapper: mockSensorWrapper,
            ),
          ),
        ),
      );

      accelerometerController.add(AccelerometerEvent(0, 9.8, 0, DateTime.now()));
      await tester.pump();

      expect(find.text('Coloca el móvil recto y mirando al frente'), findsOneWidget);
      
      final continueButton = find.byKey(const Key('continue-button'));
      expect(continueButton, findsOneWidget);
      
      await tester.tap(continueButton);
      await tester.pump();

      expect(find.byType(StarChartContent), findsOneWidget);
    });

    testWidgets('contains CustomBackButton', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<StarChartProvider>.value(
            value: mockProvider,
            child: StarChartScreen(
              latitude: 40.4168,
              longitude: -3.7038,
              sensorWrapper: mockSensorWrapper,
            ),
          ),
        ),
      );

      accelerometerController.add(AccelerometerEvent(0, 9.8, 0, DateTime.now()));
      await tester.pump();
      
      await tester.tap(find.byKey(const Key('continue-button')));
      await tester.pump();

      expect(find.byType(CustomBackButton), findsOneWidget);
    });
  });
}