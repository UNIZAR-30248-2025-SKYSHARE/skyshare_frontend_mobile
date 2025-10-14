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
        .thenAnswer((_) async => LatLng(40.4168, -3.7038));

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
        .thenAnswer((_) async => LatLng(40.4168, -3.7038));
    
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

    final result = await mapProvider.fetchSpotLocation(LatLng(40.4168, -3.7038));
    
    expect(result['city'], 'Madrid');
    expect(result['country'], 'España');
  });
}
