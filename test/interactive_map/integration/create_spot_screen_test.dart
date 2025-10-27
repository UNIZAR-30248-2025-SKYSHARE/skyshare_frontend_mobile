import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/location_repository.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/spot_repository.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/create_spot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MockSpotRepository extends Mock implements SpotRepository {}
class MockLocationRepository extends Mock implements LocationRepository {}
class MockImagePicker extends Mock implements ImagePicker {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockXFile extends Mock implements XFile {}

Future<File> createDummyFile() async {
  final directory = Directory.systemTemp;
  final file = File('${directory.path}/dummy_image.png');
  await file.writeAsBytes([1, 2, 3, 4, 5]); // Contenido dummy
  return file;
}

void main() {
  // --- Declaración de Mocks ---
  late MockSpotRepository mockSpotRepository;
  late MockLocationRepository mockLocationRepository;
  late MockImagePicker mockImagePicker;
  late MockGoTrueClient mockAuthClient;
  late MockUser mockUser;
  late XFile mockImageFile;

  const testPosition = LatLng(40.7128, -74.0060); // New York
  const testSpotName = 'Mi Spot de Prueba';
  const testSpotDesc = 'Una descripción genial.';
  const testUserId = 'test-user-id-123';
  final testLocationInfo = {'city': 'New York', 'country': 'USA'};
  
  setUpAll(() {
    // Registra fallbacks para mocktail
    registerFallbackValue(ImageSource.camera);
    registerFallbackValue(XFile(''));
  });

  setUp(() async {
    mockSpotRepository = MockSpotRepository();
    mockLocationRepository = MockLocationRepository();
    mockImagePicker = MockImagePicker();
    mockAuthClient = MockGoTrueClient();
    mockUser = MockUser();

    final dummyFile = await createDummyFile();
    mockImageFile = XFile(dummyFile.path);

    when(() => mockAuthClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn(testUserId);

    when(() => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        )).thenAnswer((_) async => mockImageFile);

    when(() => mockLocationRepository.getCityCountryFromCoordinates(any(), any()))
        .thenAnswer((_) async => testLocationInfo);

    when(() => mockSpotRepository.insertSpot(
          nombre: any(named: 'nombre'),
          descripcion: any(named: 'descripcion'),
          ciudad: any(named: 'ciudad'),
          pais: any(named: 'pais'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
          imagen: any(named: 'imagen'),
          creadorId: any(named: 'creadorId'),
        )).thenAnswer((_) async => true);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: CreateSpotScreen(
        position: testPosition,
        spotRepository: mockSpotRepository,
        locationRepository: mockLocationRepository,
        imagePicker: mockImagePicker,
        authClient: mockAuthClient,
      ),
    );
  }

  testWidgets('Error: Muestra error si no se selecciona imagen', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byLabelText('Nombre del spot *'), testSpotName);
    await tester.enterText(find.byLabelText('Descripción *'), testSpotDesc);

    final buttonFinder = find.text('Crear Spot');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Por favor, añade una foto'), findsOneWidget);
    verifyNever(() => mockSpotRepository.insertSpot(
      nombre: any(named: 'nombre'),
      descripcion: any(named: 'descripcion'),
      ciudad: any(named: 'ciudad'),
      pais: any(named: 'pais'),
      lat: any(named: 'lat'),
      lng: any(named: 'lng'),
      imagen: any(named: 'imagen'),
      creadorId: any(named: 'creadorId'),
    ));
  });

  testWidgets('Error: Muestra error de validación si el nombre está vacío', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.add_photo_alternate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galería'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byLabelText('Descripción *'), testSpotDesc);

    final buttonFinder = find.text('Crear Spot');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('El nombre es obligatorio'), findsOneWidget);
  });
  
    testWidgets('Error: Muestra error de validación si la descripción está vacía', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.add_photo_alternate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galería'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byLabelText('Nombre del spot *'), testSpotName);

    final buttonFinder = find.text('Crear Spot');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.text('La descripción es obligatoria'), findsOneWidget);
  });

  testWidgets('Error: Muestra SnackBar si insertSpot devuelve false', (tester) async {
    when(() => mockSpotRepository.insertSpot(
          nombre: any(named: 'nombre'),
          descripcion: any(named: 'descripcion'),
          ciudad: any(named: 'ciudad'),
          pais: any(named: 'pais'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
          imagen: any(named: 'imagen'),
          creadorId: any(named: 'creadorId'),
        )).thenAnswer((_) async => false);

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.add_photo_alternate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galería'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byLabelText('Nombre del spot *'), testSpotName);
    await tester.enterText(find.byLabelText('Descripción *'), testSpotDesc);

    final buttonFinder = find.text('Crear Spot');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    await tester.tap(buttonFinder);
    await tester.pump(); // Loading
    await tester.pumpAndSettle(); // Fin

    expect(find.text('Error al crear el spot'), findsOneWidget);
  });
  
  testWidgets('Error: Muestra SnackBar si insertSpot lanza una excepción', (tester) async {
    // 1. Arrange
    final exception = Exception('Error de base de datos');
    when(() => mockSpotRepository.insertSpot(
          nombre: any(named: 'nombre'),
          descripcion: any(named: 'descripcion'),
          ciudad: any(named: 'ciudad'),
          pais: any(named: 'pais'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
          imagen: any(named: 'imagen'),
          creadorId: any(named: 'creadorId'),
        )).thenThrow(exception);

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.add_photo_alternate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galería'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byLabelText('Nombre del spot *'), testSpotName);
    await tester.enterText(find.byLabelText('Descripción *'), testSpotDesc);

    final buttonFinder = find.text('Crear Spot');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    await tester.tap(buttonFinder);
    await tester.pump(); // Loading
    await tester.pumpAndSettle(); // Fin

    expect(find.text('Error: $exception'), findsOneWidget);
  });
}

extension on CommonFinders {
  FinderBase<Element> byLabelText(String labelText) {
    return find.byWidgetPredicate((Widget widget) {
      if (widget is TextFormField) {
        return widget.decoration?.labelText == labelText;
      }
      if (widget is TextField) {
        return widget.decoration?.labelText == labelText;
      }
      return false;
    });
  }
}

extension on TextFormField {
  get decoration => null;
}
