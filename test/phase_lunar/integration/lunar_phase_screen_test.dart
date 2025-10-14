import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/repositories/lunar_phase_repository.dart' as phase_lunar_repo;
import 'package:skyshare_frontend_mobile/features/phase_lunar/providers/lunar_phase_provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/phase_lunar_screen.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/phase_lunar_detailed_screen.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/widgets/lunar_phase_item.dart';

class MockLunarRepo extends Mock implements phase_lunar_repo.LunarPhaseRepository {}

void main() {
  late MockLunarRepo mockRepo;

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  setUp(() {
    mockRepo = MockLunarRepo();
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

  Future<void> pumpWithProviders(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<phase_lunar_repo.LunarPhaseRepository>.value(value: mockRepo),
          ChangeNotifierProvider<LunarPhaseProvider>(
            create: (_) => LunarPhaseProvider(repo: mockRepo),
          ),
        ],
        child: MaterialApp(home: child),
      ),
    );
  }

  testWidgets('muestra loader inicialmente y luego "No lunar phases available" si lista vacía', (tester) async {
    final completer = Completer<List<LunarPhase>>();
    when(() => mockRepo.fetchNext7DaysSimple(any())).thenAnswer((_) => completer.future);

    await pumpWithProviders(tester, const PhaseLunarScreen());

    await tester.pump(); 
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(<LunarPhase>[]);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No lunar phases available'), findsOneWidget);
  });

  testWidgets('muestra mensaje de error cuando el repo lanza', (tester) async {
    when(() => mockRepo.fetchNext7DaysSimple(any())).thenThrow(Exception('DB error'));

    await pumpWithProviders(tester, const PhaseLunarScreen());
    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('muestra la lista de fases cuando hay datos y permite navegación al detalle', (tester) async {
    final phase = makePhase(id: 42, fase: 'Quarter', fecha: DateTime(2025, 10, 14));
    when(() => mockRepo.fetchNext7DaysSimple(any())).thenAnswer((_) async => [phase]);

    when(() => mockRepo.fetchLunarPhaseDetailByIdAndDate(lunarPhaseId: 42, date: any(named: 'date')))
        .thenAnswer((_) async => phase);

    await pumpWithProviders(tester, const PhaseLunarScreen());
    await tester.pumpAndSettle();

    expect(find.text('Next 7 days'), findsOneWidget);
    expect(find.byType(LunarPhaseItem), findsOneWidget);
    expect(find.text('Quarter'), findsOneWidget);

    await tester.tap(find.byType(LunarPhaseItem));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(find.byType(PhaseLunarDetailedScreen), findsOneWidget);
  });

  testWidgets('PhaseLunarDetailedScreen muestra "No data available for this date" cuando repo devuelve null', (tester) async {
    final exampleDate = DateTime(2025, 10, 14);

    when(() => mockRepo.fetchLunarPhaseDetailByIdAndDate(lunarPhaseId: 123, date: any(named: 'date')))
        .thenAnswer((_) async => null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<phase_lunar_repo.LunarPhaseRepository>.value(value: mockRepo),
          ChangeNotifierProvider<LunarPhaseProvider>(
            create: (_) => LunarPhaseProvider(repo: mockRepo),
          ),
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

    when(() => mockRepo.fetchLunarPhaseDetailByIdAndDate(lunarPhaseId: 99, date: any(named: 'date')))
        .thenAnswer((_) async => phase);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<phase_lunar_repo.LunarPhaseRepository>.value(value: mockRepo),
          ChangeNotifierProvider<LunarPhaseProvider>(
            create: (_) => LunarPhaseProvider(repo: mockRepo),
          ),
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
