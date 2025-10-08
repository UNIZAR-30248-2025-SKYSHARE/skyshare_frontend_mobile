import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/weather_model.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/presentation/widgets/weather_card.dart';

void main() {
  group('WeatherCard', () {
    late WeatherData mockWeather;

    setUp(() {
      mockWeather = WeatherData(
        id: 1,
        locationId: 1,
        timestamp: DateTime.now(),
        temperature: 22,
        humidity: 65.0,
        wind: 15.3,
        cloudCoverage: 30.0,
        lightPollution: 4.0,
        skyIndicator: 7.5,
      );
    });

    testWidgets('muestra la temperatura correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherCard(weather: mockWeather),
          ),
        ),
      );

      expect(find.text('22 °C'), findsOneWidget);
    });

    testWidgets('muestra la humedad correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherCard(weather: mockWeather),
          ),
        ),
      );

      expect(find.text('Humedad: 65%'), findsOneWidget);
    });

    testWidgets('muestra la nubosidad correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherCard(weather: mockWeather),
          ),
        ),
      );

      expect(find.text('Nubosidad: 30%'), findsOneWidget);
    });

    testWidgets('muestra el viento correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherCard(weather: mockWeather),
          ),
        ),
      );

      expect(find.text('Viento: 15.3 km/h'), findsOneWidget);
    });

    testWidgets('muestra "Parcialmente nublado" para baja nubosidad', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherCard(weather: mockWeather),
          ),
        ),
      );

      expect(find.text('Parcialmente nublado'), findsOneWidget);
    });

    testWidgets('maneja valores nulos correctamente', (WidgetTester tester) async {
      final nullWeather = WeatherData(
        id: 1,
        locationId: 1,
        timestamp: DateTime.now(),
        temperature: null,
        humidity: null,
        wind: null,
        cloudCoverage: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherCard(weather: nullWeather),
          ),
        ),
      );

      expect(find.text('-- °C'), findsOneWidget);
      expect(find.text('Humedad: --%'), findsOneWidget);
      expect(find.text('Nubosidad: --%'), findsOneWidget);
      expect(find.text('Viento: -- km/h'), findsOneWidget);
    });
  });
}