import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/core/models/location_model.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/visible_sky_model.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/weather_model.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/sky_indicator_model.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/weather_repository.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/visible_sky_repository.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/location_repository.dart';
import 'package:skyshare_frontend_mobile/core/services/location_service.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}
class MockVisibleSkyRepository extends Mock implements VisibleSkyRepository {}
class MockLocationRepository extends Mock implements LocationRepository {}
class MockLocationService extends Mock implements LocationService {}

class TestDashboardProvider extends DashboardProvider {
  bool _testLoading = false;
  WeatherData? _testWeather;
  List<VisibleSkyItem> _testConstellations = [];
  SkyIndicator? _testSkyIndicator;
  String? _testErrorMessage;
  Future<void> Function(int userId)? detectCallback;
  Future<void> Function({Location? location})? loadCallback;

  TestDashboardProvider({
    required super.weatherRepository,
    required super.visibleSkyRepository,
    required super.locationRepository,
  });

  @override
  bool get isLoading => _testLoading;

  @override
  WeatherData? get weather => _testWeather;

  @override
  List<VisibleSkyItem> get constellations => _testConstellations;

  @override
  SkyIndicator? get skyIndicator => _testSkyIndicator;

  @override
  String? get errorMessage => _testErrorMessage;

  void setTestLoading(bool v) {
    _testLoading = v;
    notifyListeners();
  }

  void setTestWeather(WeatherData? w) {
    _testWeather = w;
    notifyListeners();
  }

  void setTestConstellations(List<VisibleSkyItem> c) {
    _testConstellations = c;
    notifyListeners();
  }

  void setTestSkyIndicator(SkyIndicator? s) {
    _testSkyIndicator = s;
    notifyListeners();
  }

  void setTestError(String? e) {
    _testErrorMessage = e;
    notifyListeners();
  }

  @override
  Future<void> detectAndSyncLocation({required int userId}) async {
    if (detectCallback != null) {
      await detectCallback!(userId);
    }
  }

  @override
  Future<void> loadDashboardData({Location? location, double? latitude, double? longitude}) async {
    if (loadCallback != null) {
      await loadCallback!(location: location);
    }
  }
}

void main() {
  group('DashboardProvider Unit Tests', () {
    late DashboardProvider provider;
    late MockWeatherRepository mockWeatherRepo;
    late MockVisibleSkyRepository mockSkyRepo;
    late MockLocationRepository mockLocationRepo;

    final mockLocation = const Location(
      id: 1,
      name: 'Madrid',
      country: 'España',
      latitude: 40.4168,
      longitude: -3.7038,
    );

    final mockWeather = WeatherData(
      id: 1,
      locationId: 1,
      timestamp: DateTime.now(),
      temperature: 20.0,
      humidity: 60.0,
      cloudCoverage: 10.0,
      lightPollution: 3.0,
      skyIndicator: 85.0,
    );

    final mockSkyItems = [
      VisibleSkyItem(
        id: 1,
        locationId: 1,
        timestamp: DateTime.now(),
        name: 'Orión',
        tipo: 'Constelación',
      ),
    ];

    setUp(() {
      mockWeatherRepo = MockWeatherRepository();
      mockSkyRepo = MockVisibleSkyRepository();
      mockLocationRepo = MockLocationRepository();

      provider = DashboardProvider(
        weatherRepository: mockWeatherRepo,
        visibleSkyRepository: mockSkyRepo,
        locationRepository: mockLocationRepo,
      );
    });

    test('initial state is correct', () {
      expect(provider.isLoading, false);
      expect(provider.weather, null);
      expect(provider.constellations, []);
      expect(provider.skyIndicator, null);
      expect(provider.errorMessage, null);
    });

    test('setSelectedLocation adds location and notifies', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setSelectedLocation(mockLocation);

      expect(provider.selectedLocation, mockLocation);
      expect(provider.savedLocations.contains(mockLocation), true);
      expect(notified, true);
    });

    test('setSelectedLocation does not add duplicate locations', () {
      provider.setSelectedLocation(mockLocation);
      expect(provider.savedLocations.length, 1);

      provider.setSelectedLocation(mockLocation);
      expect(provider.savedLocations.length, 1); 
    });

    group('loadDashboardData', () {
      test('loads data successfully with existing location', () async {
        provider.setSelectedLocation(mockLocation);
        
        when(() => mockWeatherRepo.fetchLatestForLocation(1))
            .thenAnswer((_) async => mockWeather);
        when(() => mockSkyRepo.fetchLatestForLocation(1))
            .thenAnswer((_) async => mockSkyItems);

        await provider.loadDashboardData();

        expect(provider.weather, mockWeather);
        expect(provider.constellations, mockSkyItems);
        expect(provider.skyIndicator, isNotNull);
        verify(() => mockWeatherRepo.fetchLatestForLocation(1)).called(1);
        verify(() => mockSkyRepo.fetchLatestForLocation(1)).called(1);
      });

      test('loads data successfully with custom location', () async {
        when(() => mockWeatherRepo.fetchLatestForLocation(any()))
            .thenAnswer((_) async => null);
        when(() => mockSkyRepo.fetchLatestForLocation(any()))
            .thenAnswer((_) async => []);

        await provider.loadDashboardData(latitude: 40.0, longitude: -3.0);

        expect(provider.weather, null);
        expect(provider.constellations, []);
        expect(provider.skyIndicator, null);
        verifyNever(() => mockWeatherRepo.fetchLatestForLocation(any()));
        verifyNever(() => mockSkyRepo.fetchLatestForLocation(any()));
      });

      test('handles error when loading weather fails', () async {
        provider.setSelectedLocation(mockLocation);
        
        when(() => mockWeatherRepo.fetchLatestForLocation(1))
            .thenThrow(Exception('Network error'));
        when(() => mockSkyRepo.fetchLatestForLocation(1))
            .thenAnswer((_) async => mockSkyItems);

        await provider.loadDashboardData();

        expect(provider.errorMessage, contains('Error al cargar los datos'));
        expect(provider.isLoading, false);
      });

      test('handles error when loading constellations fails', () async {
        provider.setSelectedLocation(mockLocation);
        
        when(() => mockWeatherRepo.fetchLatestForLocation(1))
            .thenAnswer((_) async => mockWeather);
        when(() => mockSkyRepo.fetchLatestForLocation(1))
            .thenThrow(Exception('Database error'));

        await provider.loadDashboardData();

        expect(provider.errorMessage, contains('Error al cargar los datos'));
        expect(provider.isLoading, false);
      });

      test('sets error when no location provided', () async {
        await provider.loadDashboardData();

        expect(provider.errorMessage, 'No location provided');
        expect(provider.isLoading, false);
      });
    });

    group('SkyIndicator calculations', () {
      test('loads SkyIndicator from weather data when available', () {
        provider.setSelectedLocation(mockLocation);
        
        when(() => mockWeatherRepo.fetchLatestForLocation(1))
            .thenAnswer((_) async => mockWeather);
        when(() => mockSkyRepo.fetchLatestForLocation(1))
            .thenAnswer((_) async => mockSkyItems);
      });

      test('calculates SkyIndicator fallback when not in weather data', () {
        final weatherWithoutIndicator = WeatherData(
          id: 1,
          locationId: 1,
          timestamp: DateTime.now(),
          temperature: 20.0,
          humidity: 60.0,
          cloudCoverage: 10.0,
          lightPollution: 3.0,
        );

        provider.setSelectedLocation(mockLocation);
        
        when(() => mockWeatherRepo.fetchLatestForLocation(1))
            .thenAnswer((_) async => weatherWithoutIndicator);
        when(() => mockSkyRepo.fetchLatestForLocation(1))
            .thenAnswer((_) async => mockSkyItems);
      });
    });
  });

  group('DashboardScreen Integration (mock provider)', () {
    late TestDashboardProvider provider;
    late MockWeatherRepository mockWeatherRepo;
    late MockVisibleSkyRepository mockSkyRepo;
    late MockLocationRepository mockLocationRepo;

    final mockLocation = const Location(
      id: 1,
      name: 'Madrid',
      country: 'España',
      latitude: 40.4168,
      longitude: -3.7038,
    );

    final mockWeather = WeatherData(
      id: 1,
      locationId: 1,
      timestamp: DateTime.now(),
      temperature: 20.0,
      humidity: 60.0,
      cloudCoverage: 10.0,
      lightPollution: 3.0,
    );

    final mockSkyItems = [
      VisibleSkyItem(
        id: 1,
        locationId: 1,
        timestamp: DateTime.now(),
        name: 'Orión',
        tipo: 'Constelación',
      ),
    ];

    setUp(() {
      mockWeatherRepo = MockWeatherRepository();
      mockSkyRepo = MockVisibleSkyRepository();
      mockLocationRepo = MockLocationRepository();

      provider = TestDashboardProvider(
        weatherRepository: mockWeatherRepo,
        visibleSkyRepository: mockSkyRepo,
        locationRepository: mockLocationRepo,
      );
    });

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<DashboardProvider>.value(
          value: provider,
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pump();
    }

    testWidgets('muestra loading inicial', (WidgetTester tester) async {
      provider.detectCallback = (int userId) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      };
      await pump(tester);
      expect(find.text('Detectando ubicación…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('muestra skeleton loading después de detectar ubicación', (WidgetTester tester) async {
      provider.detectCallback = (int userId) async {
        provider.setSelectedLocation(mockLocation);
        provider.setTestLoading(true);
        provider.notifyListeners();
      };
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Madrid'), findsOneWidget);
      expect(find.text('España'), findsOneWidget);
      expect(find.text('---'), findsAtLeastNWidgets(3));
    });

    testWidgets('muestra datos completos cuando se cargan', (WidgetTester tester) async {
      provider.setSelectedLocation(mockLocation);
      provider.setTestWeather(mockWeather);
      provider.setTestConstellations(mockSkyItems);
      provider.setTestLoading(false);
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Madrid'), findsOneWidget);
      expect(find.text('España'), findsOneWidget);
      expect(find.text('20 °C'), findsOneWidget);
      expect(find.text('Orión'), findsOneWidget);
    });

    testWidgets('muestra error cuando falla la detección de ubicación', (WidgetTester tester) async {
      provider.detectCallback = (int userId) async {
        provider.setTestError('Error de ubicación');
        provider.notifyListeners();
      };
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Reintentar'), findsOneWidget);
    });

    testWidgets('muestra mensajes cuando no hay datos disponibles', (WidgetTester tester) async {
      provider.setSelectedLocation(mockLocation);
      provider.setTestWeather(null);
      provider.setTestConstellations([]);
      provider.setTestLoading(false);
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Datos meteorológicos no disponibles'), findsOneWidget);
      expect(find.text('No hay datos de constelaciones visibles'), findsOneWidget);
    });

    testWidgets('puede recargar los datos con pull-to-refresh', (WidgetTester tester) async {
      provider.setSelectedLocation(mockLocation);
      provider.setTestWeather(mockWeather);
      provider.setTestConstellations(mockSkyItems);
      provider.setTestLoading(false);
      
      var refreshCalled = false;
      provider.loadCallback = ({Location? location}) async {
        refreshCalled = true;
        provider.setTestLoading(true);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        provider.setTestLoading(false);
        provider.notifyListeners();
      };
      
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 100));
      
      final refreshIndicatorFinder = find.byType(RefreshIndicator);
      expect(refreshIndicatorFinder, findsOneWidget);
      
      await tester.drag(find.byType(RefreshIndicator), const Offset(0.0, 300.0));
      await tester.pumpAndSettle();
      
      expect(refreshCalled, true);
    });

    testWidgets('maneja correctamente el cambio entre estados', (WidgetTester tester) async {
      provider.detectCallback = (int userId) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      };
      await pump(tester);
      expect(find.text('Detectando ubicación…'), findsOneWidget);
      
      provider.setSelectedLocation(mockLocation);
      provider.notifyListeners();
      await tester.pump(const Duration(milliseconds: 200)); 
      
      expect(find.text('Detectando ubicación…'), findsNothing);
    });

    testWidgets('botón reintentar funciona correctamente', (WidgetTester tester) async {
      var retryCount = 0;
      provider.detectCallback = (int userId) async {
        retryCount++;
        if (retryCount == 1) {
          provider.setTestError('Error inicial');
        } else {
          provider.setSelectedLocation(mockLocation);
          provider.setTestWeather(mockWeather);
          provider.setTestLoading(false);
        }
        provider.notifyListeners();
      };
      
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(retryCount, 1);
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reintentar'));
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(retryCount, 2);
    });
  });
}