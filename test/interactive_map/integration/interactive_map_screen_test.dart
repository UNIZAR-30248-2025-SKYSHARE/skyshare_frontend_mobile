import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/map_screen.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/providers/interactive_map_provider.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/location_repository.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/spot_model.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

const String _transparentBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=';
final Uint8List _transparentBytes = base64Decode(_transparentBase64);

class TestTileProvider extends TileProvider {
  final Uint8List _bytes;
  TestTileProvider([Uint8List? bytes]) : _bytes = bytes ?? _transparentBytes;

  @override
  ImageProvider getImage(dynamic coords, dynamic options) {
    return MemoryImage(_bytes);
  }
}

void main() {
  late MockLocationRepository mockLocationRepository;
  late InteractiveMapProvider mapProvider;

  setUp(() {
    mockLocationRepository = MockLocationRepository();
    mapProvider = InteractiveMapProvider(locationRepository: mockLocationRepository);
  });

  testWidgets('debería mostrar el mapa y cargar ubicación inicial', (tester) async {
    when(() => mockLocationRepository.getCurrentLatLng())
        .thenAnswer((_) async => const LatLng(40.4168, -3.7038));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<InteractiveMapProvider>(
          create: (_) => mapProvider,
          child: MapScreen(tileProvider: TestTileProvider()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MapScreen), findsOneWidget);
  });

  testWidgets('debería manejar error al obtener ubicación', (tester) async {
    when(() => mockLocationRepository.getCurrentLatLng())
        .thenAnswer((_) async => null);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<InteractiveMapProvider>(
          create: (_) => mapProvider,
          child: MapScreen(tileProvider: TestTileProvider()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(mapProvider.errorMessage, isNotNull);
  });

  testWidgets('debería obtener información de ubicación al hacer tap', (tester) async {
    when(() => mockLocationRepository.getCurrentLatLng())
        .thenAnswer((_) async => const LatLng(40.4168, -3.7038));
    
    when(() => mockLocationRepository.getCityCountryFromCoordinates(any(), any()))
        .thenAnswer((_) async => {'city': 'Madrid', 'country': 'España'});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<InteractiveMapProvider>(
          create: (_) => mapProvider,
          child: MapScreen(tileProvider: TestTileProvider()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final result = await mapProvider.fetchSpotLocation(const LatLng(40.4168, -3.7038));
    
    expect(result['city'], 'Madrid');
    expect(result['country'], 'España');
  });

  testWidgets('debería mostrar marcadores de spots en el mapa', (tester) async {
    when(() => mockLocationRepository.getCurrentLatLng())
        .thenAnswer((_) async => const LatLng(40.4168, -3.7038));

    final spot = Spot(
      id: 1,
      ubicacionId: 2,
      creadorId: "3",
      nombre: 'Spot de prueba',
      lat: 40.417,
      lng: -3.704,
      descripcion: 'Lugar bonito',
    );

    when(() => mockLocationRepository.fetchSpots(limit: any(named: 'limit')))
        .thenAnswer((_) async => [spot]);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<InteractiveMapProvider>(
          create: (_) => mapProvider,
          child: MapScreen(tileProvider: TestTileProvider()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.location_on), findsWidgets);
  });

  testWidgets('debería mostrar y expandir el FilterWidget', (tester) async {
    when(() => mockLocationRepository.getCurrentLatLng())
        .thenAnswer((_) async => const LatLng(40.4168, -3.7038));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<InteractiveMapProvider>(
          create: (_) => mapProvider,
          child: MapScreen(tileProvider: TestTileProvider()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.filter_list), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNWidgets(5));
  });

  testWidgets('debería filtrar spots por nombre', (tester) async {
    when(() => mockLocationRepository.getCurrentLatLng())
        .thenAnswer((_) async => const LatLng(40.4168, -3.7038));

    final spots = [
      Spot(
        id: 1,
        ubicacionId: 1,
        creadorId: "1",
        nombre: 'Mirador Norte',
        lat: 40.4168,
        lng: -3.7038,
        valoracionMedia: 4.5,
        totalValoraciones: 10,
      ),
      Spot(
        id: 2,
        ubicacionId: 2,
        creadorId: "1",
        nombre: 'Pico Sur',
        lat: 40.4178,
        lng: -3.7048,
        valoracionMedia: 3.2,
        totalValoraciones: 5,
      ),
    ];

    when(() => mockLocationRepository.fetchSpots(limit: any(named: 'limit')))
        .thenAnswer((_) async => spots);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<InteractiveMapProvider>(
          create: (_) => mapProvider,
          child: MapScreen(tileProvider: TestTileProvider()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'norte');
    await tester.pump();

    expect(find.text('norte'), findsOneWidget);
  });

  testWidgets('debería filtrar spots por valoración', (tester) async {
    when(() => mockLocationRepository.getCurrentLatLng())
        .thenAnswer((_) async => const LatLng(40.4168, -3.7038));

    final spots = [
      Spot(
        id: 1,
        ubicacionId: 1,
        creadorId: "1",
        nombre: 'Mirador Norte',
        lat: 40.4168,
        lng: -3.7038,
        valoracionMedia: 4.5,
        totalValoraciones: 10,
      ),
      Spot(
        id: 2,
        ubicacionId: 2,
        creadorId: "1",
        nombre: 'Pico Sur',
        lat: 40.4178,
        lng: -3.7048,
        valoracionMedia: 3.2,
        totalValoraciones: 5,
      ),
    ];

    when(() => mockLocationRepository.fetchSpots(limit: any(named: 'limit')))
        .thenAnswer((_) async => spots);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<InteractiveMapProvider>(
          create: (_) => mapProvider,
          child: MapScreen(tileProvider: TestTileProvider()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.star_border).at(3));
    await tester.pump();

    expect(find.textContaining('spot'), findsOneWidget);
  });

  testWidgets('debería mostrar contador de spots filtrados', (tester) async {
    when(() => mockLocationRepository.getCurrentLatLng())
        .thenAnswer((_) async => const LatLng(40.4168, -3.7038));

    final spots = [
      Spot(
        id: 1,
        ubicacionId: 1,
        creadorId: "1",
        nombre: 'Mirador Norte',
        lat: 40.4168,
        lng: -3.7038,
        valoracionMedia: 4.5,
        totalValoraciones: 10,
      ),
    ];

    when(() => mockLocationRepository.fetchSpots(limit: any(named: 'limit')))
        .thenAnswer((_) async => spots);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<InteractiveMapProvider>(
          create: (_) => mapProvider,
          child: MapScreen(tileProvider: TestTileProvider()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'mirador');
    await tester.pump();

    expect(find.text('1 spot'), findsOneWidget);
  });

  testWidgets('debería limpiar filtro correctamente', (tester) async {
    when(() => mockLocationRepository.getCurrentLatLng())
        .thenAnswer((_) async => const LatLng(40.4168, -3.7038));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<InteractiveMapProvider>(
          create: (_) => mapProvider,
          child: MapScreen(tileProvider: TestTileProvider()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();

    expect(find.text('test'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(find.text('test'), findsNothing);
  });
}