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

  group('SpotDetailScreen', () {
    final testSpot = Spot(
      id: 1,
      ubicacionId: 1,
      creadorId: "1",
      nombre: 'Test Spot',
      lat: 40.4168,
      lng: -3.7038,
      ciudad: 'Madrid',
      pais: 'España',
      descripcion: 'Test description',
      valoracionMedia: 4.5,
      totalValoraciones: 10,
      urlImagen: 'https://example.com/image.jpg',
    );

    late MockComentarioRepository mockComentarioRepo;
    late MockRatingRepository mockRatingRepo;
    late MockSpotRepository mockSpotRepo;
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockComentarioRepo = MockComentarioRepository();
      mockRatingRepo = MockRatingRepository();
      mockSpotRepo = MockSpotRepository();
      mockAuthProvider = MockAuthProvider();

      when(() => mockComentarioRepo.fetchForSpot(any())).thenAnswer((_) async => <Comment>[]);
      when(() => mockComentarioRepo.insertComentario(any())).thenAnswer((_) async => true);
      when(() => mockComentarioRepo.deleteComentario(any())).thenAnswer((_) async => true);
      when(() => mockComentarioRepo.fetchUserNames(any())).thenAnswer((_) async => {});

      when(() => mockRatingRepo.fetchUserRating(any(), any())).thenAnswer((_) async => null);
      when(() => mockRatingRepo.insertRating(any())).thenAnswer((_) async => true);

      when(() => mockSpotRepo.fetchSpotById(any())).thenAnswer((_) async => testSpot);

      when(() => mockAuthProvider.currentUser).thenReturn(null);
    });

    Widget wrapWithProvider(Widget child) {
      return MultiProvider(
        providers: [
          Provider<ComentarioRepository>.value(value: mockComentarioRepo),
          Provider<RatingRepository>.value(value: mockRatingRepo),
          Provider<SpotRepository>.value(value: mockSpotRepo),
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('should render all main components', (tester) async {
      await tester.pumpWidget(wrapWithProvider(SpotDetailScreen(spot: testSpot)));

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(SpotDetailScreen), findsOneWidget);
    });

    testWidgets('should have correct background color', (tester) async {
      await tester.pumpWidget(wrapWithProvider(SpotDetailScreen(spot: testSpot)));

      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF13121A));
    });

    testWidgets('should pass spot data to children', (tester) async {
      await tester.pumpWidget(wrapWithProvider(SpotDetailScreen(spot: testSpot)));

      await tester.pumpAndSettle();

      expect(find.text('Test Spot'), findsOneWidget);
      expect(find.text('Madrid, España'), findsOneWidget);
    });
  });
}