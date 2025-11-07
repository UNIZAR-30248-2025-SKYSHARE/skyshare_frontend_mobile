import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/star_chart_screen.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/custom_back_button.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/star_chart_content.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/calibration_guide.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/providers/star_chart_provider.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/utils/sensor_wrapper.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MockStarChartProvider extends Mock implements StarChartProvider {}
class MockSensorWrapper extends Mock implements SensorWrapper {}
class MockAccelerometerEvent extends Mock implements AccelerometerEvent {}

void main() {
  late MockStarChartProvider mockProvider;
  late MockSensorWrapper mockSensorWrapper;
  late MockAccelerometerEvent mockAccelEvent;

  setUp(() {
    mockProvider = MockStarChartProvider();
    mockSensorWrapper = MockSensorWrapper();
    mockAccelEvent = MockAccelerometerEvent();

    when(() => mockAccelEvent.y).thenReturn(9.8);
    when(() => mockSensorWrapper.accelerometerEvents)
        .thenAnswer((_) => Stream.value(mockAccelEvent));

    when(() => mockProvider.visibleBodies).thenReturn([
      {
        'id': 'star_1',
        'name': 'Sirius',
        'type': 'star',
        'az': 120.0,
        'alt': 45.0,
        'mag': -1.46,
        'is_visible': true,
      },
    ]);
    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.isInitialized).thenReturn(true);
    when(() => mockProvider.fetchCelestialBodies(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async {});
  });

  Widget createTestableWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<StarChartProvider>.value(
        value: mockProvider,
        child: StarChartScreen(
          latitude: 40.0,
          longitude: -3.7,
          sensorWrapper: mockSensorWrapper,
        ),
      ),
    );
  }

  testWidgets('Muestra CalibrationGuide al inicio', (tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump(); 

    expect(find.byType(CalibrationGuide), findsOneWidget);
    expect(find.byType(StarChartContent), findsNothing);
  });

  testWidgets('Tras calibración, se muestra StarChartContent', (tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    final continueButton = find.byKey(const Key('continue-button'));
    expect(continueButton, findsOneWidget);

    await tester.tap(continueButton);
    await tester.pump();

    expect(find.byType(CalibrationGuide), findsNothing);
    expect(find.byType(StarChartContent), findsOneWidget);
  });

  testWidgets('Back button pops the screen', (tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    expect(find.byType(CustomBackButton), findsOneWidget);

    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();

    expect(find.byType(StarChartScreen), findsNothing);
  });
}