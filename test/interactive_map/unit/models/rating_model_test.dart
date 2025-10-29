import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/rating_model.dart';

void main() {
  group('Rating Model Tests', () {

    final testDate = DateTime(2023, 10, 27, 14, 30);
    final testDateIso = testDate.toIso8601String();
    const testUserId = 'abc-123-xyz';

    final ratingMap = {
      'id_spot': 10,
      'id_usuario': testUserId,
      'puntuacion': 5,
      'fecha_valoracion': testDateIso,
    };

    final ratingModel = Rating(
      spotId: 10,
      userId: testUserId,
      value: 5,
      createdAt: testDate,
    );

    test('Rating.fromMap crea un objeto Rating correctamente', () {
      final rating = Rating.fromMap(ratingMap);

      expect(rating.spotId, 10);
      expect(rating.userId, testUserId);
      expect(rating.value, 5);
      expect(rating.createdAt, testDate);
    });

    test('Rating.toMap convierte un objeto Rating a Map correctamente', () {
      final map = ratingModel.toMap();

      expect(map, equals(ratingMap));
    });

    test('Test de "Round-trip" (Map -> Objeto -> Map)', () {
      final ratingFromMap = Rating.fromMap(ratingMap);
      final mapFromRating = ratingFromMap.toMap();

      expect(mapFromRating, equals(ratingMap));
    });

    test('Rating.fromMap falla si los tipos son incorrectos', () {
      final badMap = {
        'id_spot': '10', 
        'id_usuario': 123,   
        'puntuacion': '5', 
        'fecha_valoracion': '2023-10-27T14:30:00Z',
      };
      
      expect(() => Rating.fromMap(badMap), throwsA(isA<TypeError>()));
    });
  });
}