import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/map_widget.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/providers/interactive_map_provider.dart';

class MockInteractiveMapProvider extends Mock implements InteractiveMapProvider {}

class FakeTileProvider extends TileProvider {
  FakeTileProvider();
  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    final bytes = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=');
    return MemoryImage(bytes);
  }
}

void main() {
  late MockInteractiveMapProvider mockProvider;
  late MapController mapController;
  late List<Marker> markers;

  setUp(() {
    mockProvider = MockInteractiveMapProvider();
    mapController = MapController();
    markers = [];

    when(() => mockProvider.currentPosition).thenReturn(null);
    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.errorMessage).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<InteractiveMapProvider>.value(
        value: mockProvider,
        child: Scaffold(
          body: MapWidget(
            mapController: mapController,
            markers: markers,
            onTap: (_, _) {},
            onLongPress: (_, _) {},
            tileProvider: FakeTileProvider(),
          ),
        ),
      ),
    );
  }

  testWidgets('renderiza FlutterMap correctamente', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(TileLayer), findsOneWidget);
    expect(find.byType(MarkerLayer), findsOneWidget);
  });

  testWidgets('muestra marcador de usuario cuando hay ubicación', (tester) async {
    when(() => mockProvider.currentPosition).thenReturn(const LatLng(40.4168, -3.7038));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });

  testWidgets('no muestra marcador de usuario cuando no hay ubicación', (tester) async {
    when(() => mockProvider.currentPosition).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.my_location), findsNothing);
  });

  testWidgets('muestra marcadores personalizados', (tester) async {
    markers.add(
      const Marker(
        point: LatLng(40.4168, -3.7038),
        width: 40,
        height: 40,
        child: Icon(Icons.location_on, color: Colors.red),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });

  testWidgets('usa ubicación por defecto cuando no hay ubicación del usuario', (tester) async {
    when(() => mockProvider.currentPosition).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(FlutterMap), findsOneWidget);
  });
}
