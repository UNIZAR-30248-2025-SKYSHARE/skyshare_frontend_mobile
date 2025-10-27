import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart'; // Importado
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/location_repository.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/spot_repository.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/create_spot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Mocks ---
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class MockSpotRepository extends Mock implements SpotRepository {}
class MockLocationRepository extends Mock implements LocationRepository {}
class MockImagePicker extends Mock implements ImagePicker {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
// --- Fin Mocks ---

void main() {
  late MockNavigatorObserver mockObserver;
  const testPosition = LatLng(40.4168, -3.7038);

  // Declarar instancias de mocks
  late MockSpotRepository mockSpotRepository;
  late MockLocationRepository mockLocationRepository;
  late MockImagePicker mockImagePicker;
  late MockGoTrueClient mockAuthClient;
  late MockUser mockUser;

  setUp(() {
    mockObserver = MockNavigatorObserver();

    // Inicializar mocks
    mockSpotRepository = MockSpotRepository();
    mockLocationRepository = MockLocationRepository();
    mockImagePicker = MockImagePicker();
    mockAuthClient = MockGoTrueClient();
    mockUser = MockUser();

    // Stub mínimo para evitar null pointer exceptions (p.ej., en user.id)
    when(() => mockAuthClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('fake-user-id');
  });

  // --- FUNCIÓN CORREGIDA ---
  Future<void> pumpCreateSpotScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CreateSpotScreen(
          position: testPosition,
          // Pasa las dependencias mockeadas
          spotRepository: mockSpotRepository,
          locationRepository: mockLocationRepository,
          imagePicker: mockImagePicker,
          authClient: mockAuthClient,
        ),
        navigatorObservers: [mockObserver],
      ),
    );
  }
  // -------------------------

  testWidgets('renderiza todos los elementos del formulario', (tester) async {
    await pumpCreateSpotScreen(tester);

    expect(find.text('Crear Nuevo Spot'), findsOneWidget);
    expect(find.text('Nombre del spot *'), findsOneWidget);
    expect(find.text('Descripción *'), findsOneWidget);
    expect(find.text('Añadir foto'), findsOneWidget);
    expect(find.text('Crear Spot'), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('muestra coordenadas de ubicación', (tester) async {
    await pumpCreateSpotScreen(tester);

    expect(find.text('Lat: 40.41680'), findsOneWidget);
    expect(find.text('Lng: -3.70380'), findsOneWidget);
  });

  testWidgets('valida campos obligatorios', (tester) async {
    await pumpCreateSpotScreen(tester);

    await tester.tap(find.text('Crear Spot'));
    await tester.pump(); // Espera a que se reconstruya el widget con los mensajes de error

    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    expect(find.text('La descripción es obligatoria'), findsOneWidget);
  });

  testWidgets('permite ingresar texto en los campos', (tester) async {
    await pumpCreateSpotScreen(tester);

    await tester.enterText(
      find.byLabelText('Nombre del spot *'), 
      'Mirador del Pico'
    );

    await tester.enterText(
      find.byLabelText('Descripción *'), 
      'Vista increíble'
    );

    await tester.pump(); 

    expect(find.text('Mirador del Pico'), findsOneWidget);
    expect(find.text('Vista increíble'), findsOneWidget);
  });

  testWidgets('muestra snackbar cuando no hay imagen', (tester) async {
    await pumpCreateSpotScreen(tester);

    // Rellena los campos para que la validación pase
    
    // --- CORRECCIÓN AQUÍ ---
    // Usa el finder incorporado de Flutter, que es más fiable.
    await tester.enterText(
      find.byLabelText('Nombre del spot *'),
      'Test Spot',
    );
    // ---------------------

    // --- Y CORRECCIÓN AQUÍ ---
    await tester.enterText(
      find.byLabelText('Descripción *'),
      'Test Description',
    );
    // -----------------------
    
    await tester.tap(find.text('Crear Spot'));
    await tester.pump(); // Espera a que aparezca el SnackBar

    expect(find.text('Por favor, añade una foto'), findsOneWidget);
  });

  testWidgets('contiene círculo para añadir foto', (tester) async {
    await pumpCreateSpotScreen(tester);

    final container = tester.widget<Container>(find.descendant(
      of: find.byType(GestureDetector),
      matching: find.byType(Container),
    ).first);

    expect(container.decoration, isA<BoxDecoration>());
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
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