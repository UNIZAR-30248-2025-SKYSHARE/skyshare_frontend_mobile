import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/data/model/alert_model.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_card_widget.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/location_repository.dart'
    as dashboard_location;
import 'package:skyshare_frontend_mobile/core/models/location_model.dart';

// --- Mocks y Fakes ---
class MockLocationRepository extends Mock
    implements dashboard_location.LocationRepository {}

class FakeLocation extends Fake implements Location {
  @override
  final String name;
  FakeLocation(this.name);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockLocationRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeLocation('fallback'));
  });

  setUp(() {
    mockRepo = MockLocationRepository();
  });

  AlertModel buildSampleAlert({bool active = true}) {
    return AlertModel(
      idAlerta: 1,
      idUsuario: 'user1',
      idUbicacion: 99,
      tipoAlerta: 'meteorologica',
      parametroObjetivo: 'Temperature', // Cambiado a inglés
      tipoRepeticion: 'DIARIA',
      fechaObjetivo: DateTime(2025, 10, 27),
      activa: active,
    );
  }

  group('AlertCardWidget', () {
    testWidgets('muestra título, subtítulo y widgets hijos', (tester) async {
      final alert = buildSampleAlert();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCardWidget(alert: alert),
          ),
        ),
      );

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.textContaining('Location #99'), findsOneWidget);
      expect(find.textContaining('Every day'), findsOneWidget);
    });

    testWidgets('usa color atenuado cuando la alerta está inactiva', (tester) async {
      final alert = buildSampleAlert(active: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCardWidget(alert: alert),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final color = decoration.color!;
      expect(color.a, closeTo(0.04, 0.01));
    });

    testWidgets('ejecuta callback onTap correctamente', (tester) async {
      bool tapped = false;
      final alert = buildSampleAlert();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCardWidget(
              alert: alert,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      final gesture = find.descendant(
        of: find.byType(AlertCardWidget),
        matching: find.byType(GestureDetector),
      ).first;

      await tester.tap(gesture);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('muestra nombre de ubicación obtenido del repositorio', (tester) async {
      final alert = buildSampleAlert();

      when(() => mockRepo.fetchLocationById(any()))
          .thenAnswer((_) async => FakeLocation('Solar House')); // traducido

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCardWidget(
              alert: alert,
              locationRepository: mockRepo,
            ),
          ),
        ),
      );

      expect(find.textContaining('Loading location...'), findsOneWidget); // traducido
      await tester.pumpAndSettle();
      expect(find.textContaining('Solar House'), findsOneWidget);
    });

    testWidgets('didUpdateWidget recarga ubicación al cambiar idUbicacion', (tester) async {
      final alert1 = buildSampleAlert();
      final alert2 = alert1.copyWith(idUbicacion: 777);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCardWidget(alert: alert1),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCardWidget(alert: alert2),
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Location #777'), findsOneWidget); 
    });
  });
}
