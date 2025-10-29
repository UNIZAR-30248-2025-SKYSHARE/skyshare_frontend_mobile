import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/spot_detail_screen.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/spot_model.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/comment_model.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/rating_model.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/comment_repository.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/rating_repository.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/spot_repository.dart';
import 'package:skyshare_frontend_mobile/features/auth/providers/auth_provider.dart';

class MockComentarioRepository extends Mock implements ComentarioRepository {}
class MockRatingRepository extends Mock implements RatingRepository {}
class MockSpotRepository extends Mock implements SpotRepository {}
class MockAuthProvider extends Mock implements AuthProvider {}

class FakeComment extends Fake implements Comment {}
class FakeRating extends Fake implements Rating {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeComment());
    registerFallbackValue(FakeRating());
  });

  group('SpotDetailScreen Integration Tests', () {
    late MockComentarioRepository mockComentarioRepo;
    late MockRatingRepository mockRatingRepo;
    late MockSpotRepository mockSpotRepo;
    late MockAuthProvider mockAuthProvider;
    late Comment firstComment;
    late Comment secondComment;

    final spotWithImage = Spot(
      id: 1,
      ubicacionId: 1,
      creadorId: "1",
      nombre: 'Mirador Excelente',
      lat: 40.4168,
      lng: -3.7038,
      ciudad: 'Madrid',
      pais: 'España',
      descripcion: 'Un mirador con vistas espectaculares a la ciudad',
      valoracionMedia: 4.8,
      totalValoraciones: 20,
      urlImagen: 'https://example.com/image.jpg',
    );

    final spotWithoutImage = Spot(
      id: 2,
      ubicacionId: 2,
      creadorId: "2",
      nombre: 'Pico Montañoso',
      lat: 40.5123,
      lng: -3.8123,
      ciudad: 'Segovia',
      pais: 'España',
      descripcion: null,
      valoracionMedia: 3.2,
      totalValoraciones: 5,
      urlImagen: null,
    );

    final spotWithoutRating = Spot(
      id: 3,
      ubicacionId: 3,
      creadorId: "3",
      nombre: 'Llanura Desconocida',
      lat: 40.6123,
      lng: -3.9123,
      ciudad: 'Toledo',
      pais: 'España',
      descripcion: 'Un lugar tranquilo y poco conocido',
      valoracionMedia: null,
      totalValoraciones: 0,
      urlImagen: 'https://example.com/another-image.jpg',
    );

    setUp(() {
      mockComentarioRepo = MockComentarioRepository();
      mockRatingRepo = MockRatingRepository();
      mockSpotRepo = MockSpotRepository();
      mockAuthProvider = MockAuthProvider();

      final now = DateTime.now();

      firstComment = Comment.fromMap({
        'id_comentario': 1,
        'id_spot': 1,
        'id_usuario': '100',
        'texto': 'First comment',
        'fecha_comentario': now.subtract(const Duration(hours: 2)).toIso8601String(),
      });

      secondComment = Comment.fromMap({
        'id_comentario': 2,
        'id_spot': 1,
        'id_usuario': '101',
        'texto': 'Second comment',
        'fecha_comentario': now.subtract(const Duration(hours: 3)).toIso8601String(),
      });

      when(() => mockComentarioRepo.fetchForSpot(any())).thenAnswer((inv) async {
        final int spotId = inv.positionalArguments[0] as int;
        if (spotId == 1) return [firstComment, secondComment];
        return <Comment>[];
      });

      when(() => mockComentarioRepo.insertComentario(any())).thenAnswer((_) async => true);
      when(() => mockComentarioRepo.deleteComentario(any())).thenAnswer((_) async => true);
      when(() => mockComentarioRepo.fetchUserNames(any())).thenAnswer((_) async => {});

      when(() => mockRatingRepo.fetchUserRating(any(), any())).thenAnswer((_) async => null);
      when(() => mockRatingRepo.insertRating(any())).thenAnswer((_) async => true);

      when(() => mockSpotRepo.fetchSpotById(any())).thenAnswer((_) async => spotWithImage);

      when(() => mockAuthProvider.currentUser).thenReturn(null);
    });

    Widget createTestWidget(Spot spot) {
      return MultiProvider(
        providers: [
          Provider<ComentarioRepository>.value(value: mockComentarioRepo),
          Provider<RatingRepository>.value(value: mockRatingRepo),
          Provider<SpotRepository>.value(value: mockSpotRepo),
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider), 
        ],
        child: MaterialApp(
          home: SpotDetailScreen(spot: spot),
        ),
      );
    }

    testWidgets('debería mostrar todos los detalles del spot con imagen', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithImage));
      await tester.pumpAndSettle();

      expect(find.text('Mirador Excelente'), findsOneWidget);
      expect(find.text('Madrid, España'), findsOneWidget);
      expect(find.text('Un mirador con vistas espectaculares a la ciudad'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('20 valoraciones'), findsOneWidget);
    });

    testWidgets('debería mostrar placeholder cuando no hay imagen', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithoutImage));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('debería manejar spots sin valoración', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithoutRating));
      await tester.pumpAndSettle();

      expect(find.text('—'), findsOneWidget);
      expect(find.text('0 valoraciones'), findsOneWidget);
    });

    testWidgets('debería mostrar "Sin descripción" cuando no hay descripción', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithoutImage));
      await tester.pumpAndSettle();

      expect(find.text('Sin descripción'), findsOneWidget);
    });

    testWidgets('debería mostrar comentarios', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithImage));
      await tester.pumpAndSettle();

      expect(find.text('First comment'), findsOneWidget);
      expect(find.text('Second comment'), findsOneWidget);
    });

    testWidgets('debería mostrar las estrellas de valoración correctamente', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithImage));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(4));
    });

    testWidgets('debería manejar scroll correctamente', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithImage));
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Mirador Excelente'), findsOneWidget);
    });

    testWidgets('debería mostrar información de ubicación correctamente', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithImage));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.text('Madrid, España'), findsOneWidget);
    });

    testWidgets('debería mostrar elementos de tarjeta de rating', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithImage));
      await tester.pumpAndSettle();

      expect(find.text('Valoración'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('20 valoraciones'), findsOneWidget);
    });

    testWidgets('debería tener una estructura de layout completa', (tester) async {
      await tester.pumpWidget(createTestWidget(spotWithImage));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  });
}