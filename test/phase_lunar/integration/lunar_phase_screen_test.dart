import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/repositories/lunar_phase_repository.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/repositories/location_repository.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/providers/lunar_phase_provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/phase_lunar_screen.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/phase_lunar_detailed_screen.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/widgets/lunar_phase_item.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:skyshare_frontend_mobile/core/models/location_model.dart';

class MockLunarPhaseRepo extends Mock implements LunarPhaseRepository {}
class MockLocationRepo extends Mock implements LocationRepository {}
class MockDashboardProvider extends Mock implements DashboardProvider {}

void main() {
  late MockLunarPhaseRepo mockLunarRepo;
  late MockLocationRepo mockLocationRepo;
  late MockDashboardProvider mockDashboardProvider;

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  setUp(() {
    mockLunarRepo = MockLunarPhaseRepo();
    mockLocationRepo = MockLocationRepo();
    mockDashboardProvider = MockDashboardProvider();
    
    when(() => mockDashboardProvider.selectedLocation).thenReturn(null);
    when(() => mockDashboardProvider.isLoading).thenReturn(false);
  });

  LunarPhase makePhase({
    int id = 1,
    String fase = 'Full Moon',
    DateTime? fecha,
    int porcentaje = 75,
  }) {
    return LunarPhase(
      idLuna: id,
      idUbicacion: 10,
      fase: fase,
      fecha: fecha ?? DateTime.now(),
      porcentajeIluminacion: porcentaje.toDouble(),
    );
  }

  Location makeLocation({int id = 10, String name = 'Zaragoza'}) {
    return Location(
      id: id,
      name: name,
      country: 'Spain',
      latitude: 41.6488,
      longitude: -0.8891,
    );
  }

  Future<void> pumpWithProviders(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LunarPhaseRepository>.value(value: mockLunarRepo),
          Provider<LocationRepository>.value(value: mockLocationRepo),
          ChangeNotifierProvider<LunarPhaseProvider>(
            create: (_) => LunarPhaseProvider(
              lunarPhaseRepo: mockLunarRepo,
              locationRepo: mockLocationRepo,
            ),
          ),
          ChangeNotifierProvider<DashboardProvider>.value(value: mockDashboardProvider),
        ],
        child: MaterialApp(home: child),
      ),
    );
  }

    testWidgets('muestra loader inicialmente y luego mensaje si lista vacía', (tester) async {
    when(() => mockLocationRepo.getCurrentLocationId()).thenAnswer((_) async => 10);
    
    final location = makeLocation();
    when(() => mockDashboardProvider.selectedLocation).thenReturn(location);

    when(() => mockLunarRepo.fetchNext7DaysSimple(10)).thenAnswer((_) async => []);

    await pumpWithProviders(tester, const PhaseLunarScreen());

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Las fases lunares están tardando en cargar'), findsOneWidget);
  });


  testWidgets('muestra mensaje de error cuando el repo lanza excepción', (tester) async {
    when(() => mockLocationRepo.getCurrentLocationId()).thenThrow(Exception('DB error'));
    
    final location = makeLocation();
    when(() => mockDashboardProvider.selectedLocation).thenReturn(location);

    await pumpWithProviders(tester, const PhaseLunarScreen());
    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('muestra la lista de fases cuando hay datos y permite navegación al detalle', (tester) async {
    when(() => mockLocationRepo.getCurrentLocationId()).thenAnswer((_) async => 10);
    
    final location = makeLocation();
    when(() => mockDashboardProvider.selectedLocation).thenReturn(location);

    final phase = makePhase(id: 42, fase: 'Quarter', fecha: DateTime(2025, 10, 14));
    when(() => mockLunarRepo.fetchNext7DaysSimple(10)).thenAnswer((_) async => [phase]);

    when(() => mockLunarRepo.fetchLunarPhaseDetailByIdAndDate(lunarPhaseId: 42, date: any(named: 'date')))
        .thenAnswer((_) async => phase);

    await pumpWithProviders(tester, const PhaseLunarScreen());
    await tester.pumpAndSettle();

    expect(find.text('Next 7 days'), findsOneWidget);
    expect(find.byType(LunarPhaseItem), findsOneWidget);
    expect(find.text('Quarter'), findsOneWidget);
    expect(find.text('Zaragoza'), findsOneWidget);

    await tester.tap(find.byType(LunarPhaseItem));
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(PhaseLunarDetailedScreen), findsOneWidget);
  });

  testWidgets('PhaseLunarDetailedScreen muestra "No data available for this date" cuando repo devuelve null', (tester) async {
    final exampleDate = DateTime(2025, 10, 14);

    when(() => mockLunarRepo.fetchLunarPhaseDetailByIdAndDate(lunarPhaseId: 123, date: any(named: 'date')))
        .thenAnswer((_) async => null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LunarPhaseRepository>.value(value: mockLunarRepo),
          Provider<LocationRepository>.value(value: mockLocationRepo),
          ChangeNotifierProvider<LunarPhaseProvider>(
            create: (_) => LunarPhaseProvider(
              lunarPhaseRepo: mockLunarRepo,
              locationRepo: mockLocationRepo,
            ),
          ),
          ChangeNotifierProvider<DashboardProvider>.value(value: mockDashboardProvider),
        ],
        child: MaterialApp(
          home: PhaseLunarDetailedScreen(lunarPhaseId: 123, date: exampleDate),
        ),
      ),
    );

    await tester.pump(); 
    await tester.pumpAndSettle();

    expect(find.text('No data available for this date'), findsOneWidget);
  });

  testWidgets('PhaseLunarDetailedScreen muestra detalle cuando repo devuelve datos', (tester) async {
    final exampleDate = DateTime(2025, 10, 14);
    final phase = makePhase(id: 99, fase: 'Waxing Crescent', fecha: exampleDate, porcentaje: 34);

    when(() => mockLunarRepo.fetchLunarPhaseDetailByIdAndDate(lunarPhaseId: 99, date: any(named: 'date')))
        .thenAnswer((_) async => phase);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LunarPhaseRepository>.value(value: mockLunarRepo),
          Provider<LocationRepository>.value(value: mockLocationRepo),
          ChangeNotifierProvider<LunarPhaseProvider>(
            create: (_) => LunarPhaseProvider(
              lunarPhaseRepo: mockLunarRepo,
              locationRepo: mockLocationRepo,
            ),
          ),
          ChangeNotifierProvider<DashboardProvider>.value(value: mockDashboardProvider),
        ],
        child: MaterialApp(
          home: PhaseLunarDetailedScreen(lunarPhaseId: 99, date: exampleDate),
        ),
      ),
    );

    await tester.pump(); 
    await tester.pumpAndSettle();

    expect(find.textContaining('Waxing Crescent'), findsOneWidget);
    expect(find.textContaining('34%'), findsOneWidget);
  });
}