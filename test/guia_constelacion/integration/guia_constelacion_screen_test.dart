import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/guia_constelacion_screen.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/providers/guia_constelacion_provider.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/models/guia_model.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/pasos_observacion.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/referencia_constelacion.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/banner_constelacion.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/descripcion_constelacion.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/imagen_principal.dart';
import 'package:skyshare_frontend_mobile/core/widgets/star_background.dart';

// -------------------- MOCKS --------------------

class MockGuiaConstelacionProvider extends Mock
    implements GuiaConstelacionProvider {}

class GuiaConstelacionFake extends Fake implements GuiaConstelacion {}

void main() {
  late MockGuiaConstelacionProvider mockProvider;

  setUpAll(() {
    registerFallbackValue(GuiaConstelacionFake());
  });

  setUp(() {
    mockProvider = MockGuiaConstelacionProvider();

    when(() => mockProvider.fetchGuiaPorNombreYTemporada(
          nombreConstelacion: any(named: 'nombreConstelacion'),
          temporada: any(named: 'temporada'),
        )).thenAnswer((_) async {});
  });

  testWidgets('muestra indicador de carga cuando provider.isLoading = true', (tester) async {
    when(() => mockProvider.isLoading).thenReturn(true);
    when(() => mockProvider.error).thenReturn(null);
    when(() => mockProvider.guia).thenReturn(null);

    await tester.pumpWidget(
      ChangeNotifierProvider<GuiaConstelacionProvider>.value(
        value: mockProvider,
        child: const MaterialApp(
          home: GuiaConstelacionScreen(
            nombreConstelacion: 'Orión',
            temporada: 'invierno',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra mensaje de error cuando provider.error != null', (tester) async {
    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.error).thenReturn('Error al cargar');
    when(() => mockProvider.guia).thenReturn(null);

    await tester.pumpWidget(
      ChangeNotifierProvider<GuiaConstelacionProvider>.value(
        value: mockProvider,
        child: const MaterialApp(
          home: GuiaConstelacionScreen(
            nombreConstelacion: 'Orión',
            temporada: 'invierno',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Error al cargar'), findsOneWidget);
    expect(find.text('No se encontró la guía'), findsNothing);
  });

  testWidgets('muestra mensaje "No se encontró la guía" cuando guia es null', (tester) async {
    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.error).thenReturn(null);
    when(() => mockProvider.guia).thenReturn(null);

    await tester.pumpWidget(
      ChangeNotifierProvider<GuiaConstelacionProvider>.value(
        value: mockProvider,
        child: const MaterialApp(
          home: GuiaConstelacionScreen(
            nombreConstelacion: 'Orión',
            temporada: 'invierno',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('No se encontró la guía'), findsOneWidget);
  });

  testWidgets('muestra correctamente todos los widgets cuando guia está cargada', (tester) async {
    final guia = GuiaConstelacion(
      idGuia: 1,
      nombreConstelacion: 'Orión',
      temporada: 'invierno',
      paso1: 'Busca el cinturón',
      paso2: 'Identifica Betelgeuse',
      paso3: 'Ubica Rigel',
      paso4: 'Observa con telescopio',
      paso5: 'Toma notas',
      referencia: 'Referencia visual',
      urlReferencia: 'imagen_local.png',
      descripcionGeneral: 'Orión es una constelación visible en invierno.',
      imagenUrl: 'orion.png',
    );

    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.error).thenReturn(null);
    when(() => mockProvider.guia).thenReturn(guia);

    await tester.pumpWidget(
      ChangeNotifierProvider<GuiaConstelacionProvider>.value(
        value: mockProvider,
        child: const MaterialApp(
          home: GuiaConstelacionScreen(
            nombreConstelacion: 'Orión',
            temporada: 'invierno',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(StarBackground), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);

    expect(find.byType(BannerConstelacionDelegate), findsNothing); // SliverPersistentHeader usa delegate internamente
    expect(find.byType(DescripcionConstelacion), findsOneWidget);
    expect(find.byType(ImagenPrincipal), findsOneWidget);
    expect(find.byType(ReferenciaConstelacion), findsOneWidget);
    expect(find.byType(PasosObservacion), findsOneWidget);

    expect(find.textContaining('Orión'), findsWidgets);
    expect(find.textContaining('Busca el cinturón'), findsOneWidget);
    expect(find.text('Referencia'), findsOneWidget);
  });
}
