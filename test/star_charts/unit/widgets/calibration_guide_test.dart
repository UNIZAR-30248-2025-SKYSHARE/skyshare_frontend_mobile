import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/calibration_guide.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/custom_back_button.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/utils/sensor_wrapper.dart';

class MockVoidCallback extends Mock {
  void call();
}

class MockSensorWrapper extends Mock implements SensorWrapper {}
class FakeAccelerometerEvent extends Fake implements AccelerometerEvent {}

void main() {
  group('CalibrationGuide', () {
    late VoidCallback onContinue;
    late MockSensorWrapper mockSensorWrapper;
    late StreamController<AccelerometerEvent> accelerometerController;

    setUpAll(() {
      registerFallbackValue(FakeAccelerometerEvent());
    });

    setUp(() {
      onContinue = MockVoidCallback().call;
      mockSensorWrapper = MockSensorWrapper();
      accelerometerController = StreamController<AccelerometerEvent>();
      
      when(() => mockSensorWrapper.accelerometerEvents)
          .thenAnswer((_) => accelerometerController.stream);
    });

    tearDown(() {
      accelerometerController.close();
    });

    testWidgets('shows loading when no sensor data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalibrationGuide(
            onContinue: onContinue,
            sensorWrapper: mockSensorWrapper,
          ),
        ),
      );

      expect(find.text('Inicializando sensores...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows calibration UI when sensor data is received', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalibrationGuide(
            onContinue: onContinue,
            sensorWrapper: mockSensorWrapper,
          ),
        ),
      );

      accelerometerController.add(AccelerometerEvent(0, 9.8, 0, DateTime.now()));
      await tester.pump();

      expect(find.text('Coloca el móvil recto y mirando al frente'), findsOneWidget);
      expect(find.byKey(const Key('continue-button')), findsOneWidget);
    });

    testWidgets('has CustomBackButton in position', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalibrationGuide(
            onContinue: onContinue,
            sensorWrapper: mockSensorWrapper,
          ),
        ),
      );

      expect(find.byType(CustomBackButton), findsOneWidget);
    });

    testWidgets('enables continue button when calibration is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalibrationGuide(
            onContinue: onContinue,
            sensorWrapper: mockSensorWrapper,
          ),
        ),
      );

      accelerometerController.add(AccelerometerEvent(0, 9.8, 0, DateTime.now()));
      await tester.pump();

      final continueButton = find.byKey(const Key('continue-button'));
      expect(continueButton, findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull);
    });
  });
}