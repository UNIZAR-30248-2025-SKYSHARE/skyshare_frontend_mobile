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
class MockXFile extends Mock implements XFile {
  @override
  String get path => '/fake/path/image.jpg';
}

void main() {
  const testPosition = LatLng(40.4168, -3.7038);
  late MockSpotRepository mockSpotRepository;
  late MockLocationRepository mockLocationRepository;
  late MockImagePicker mockImagePicker;
  late MockGoTrueClient mockAuthClient;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(ImageSource.camera);
    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(MockXFile());
  });

  setUp(() {
    mockSpotRepository = MockSpotRepository();
    mockLocationRepository = MockLocationRepository();
    mockImagePicker = MockImagePicker();
    mockAuthClient = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockAuthClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('fake-user-id');
    when(() => mockLocationRepository.getCityCountryFromCoordinates(any(), any()))
        .thenAnswer((_) async => {'city': 'Madrid', 'country': 'Spain'});
  });

  testWidgets('renderiza elementos básicos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CreateSpotScreen(
          position: testPosition,
          spotRepository: mockSpotRepository,
          locationRepository: mockLocationRepository,
          imagePicker: mockImagePicker,
          authClient: mockAuthClient,
        ),
      ),
    );

    expect(find.text('Name of the spot'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Add photo'), findsOneWidget);
  });

  testWidgets('muestra coordenadas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CreateSpotScreen(
          position: testPosition,
          spotRepository: mockSpotRepository,
          locationRepository: mockLocationRepository,
          imagePicker: mockImagePicker,
          authClient: mockAuthClient,
        ),
      ),
    );

    expect(find.text('Lat: 40.41680'), findsOneWidget);
    expect(find.text('Lng: -3.70380'), findsOneWidget);
  });

  testWidgets('selecciona imagen de galería', (tester) async {
    final mockXFile = MockXFile();
    when(() => mockImagePicker.pickImage(
      source: any(named: 'source'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      imageQuality: any(named: 'imageQuality'),
    )).thenAnswer((_) async => mockXFile);

    await tester.pumpWidget(
      MaterialApp(
        home: CreateSpotScreen(
          position: testPosition,
          spotRepository: mockSpotRepository,
          locationRepository: mockLocationRepository,
          imagePicker: mockImagePicker,
          authClient: mockAuthClient,
        ),
      ),
    );

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    verify(() => mockImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    )).called(1);
  });

  testWidgets('selecciona imagen de cámara', (tester) async {
    final mockXFile = MockXFile();
    when(() => mockImagePicker.pickImage(
      source: any(named: 'source'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      imageQuality: any(named: 'imageQuality'),
    )).thenAnswer((_) async => mockXFile);

    await tester.pumpWidget(
      MaterialApp(
        home: CreateSpotScreen(
          position: testPosition,
          spotRepository: mockSpotRepository,
          locationRepository: mockLocationRepository,
          imagePicker: mockImagePicker,
          authClient: mockAuthClient,
        ),
      ),
    );

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    verify(() => mockImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    )).called(1);
  });

  testWidgets('contiene formulario y campos de texto', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CreateSpotScreen(
          position: testPosition,
          spotRepository: mockSpotRepository,
          locationRepository: mockLocationRepository,
          imagePicker: mockImagePicker,
          authClient: mockAuthClient,
        ),
      ),
    );

    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}