import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/comment_model.dart';

void main() {
  group('Comment Model Tests', () {
    final testDate = DateTime(2023, 11, 15, 09, 00);
    final testDateIso = testDate.toIso8601String();

    final commentMapFromDb = {
      'id_comentario': 101, // El ID existe cuando se lee
      'id_spot': 20,
      'id_usuario': 303, // Nota: userId es int en este modelo
      'texto': '¡Qué buen sitio!',
      'fecha_comentario': testDateIso,
    };

    final commentModel = Comment(
      id: 101,
      spotId: 20,
      userId: 303,
      text: '¡Qué buen sitio!',
      createdAt: testDate,
    );

    final commentMapToDb = {
      'id_spot': 20,
      'id_usuario': 303,
      'texto': '¡Qué buen sitio!',
      'fecha_comentario': testDateIso,
    };

    test('Comment.fromMap crea un objeto Comment correctamente', () {
      final comment = Comment.fromMap(commentMapFromDb);

      expect(comment.id, 101);
      expect(comment.spotId, 20);
      expect(comment.userId, 303);
      expect(comment.text, '¡Qué buen sitio!');
      expect(comment.createdAt, testDate);
    });

    test('Comment.toMap convierte un objeto Comment a Map correctamente (para crear)', () {
      final map = commentModel.toMap();

      expect(map, equals(commentMapToDb));
      expect(map.containsKey('id_comentario'), isFalse);
    });

    test('Test de asimetría (Map con ID -> Objeto -> Map sin ID)', () {

      final commentFromMap = Comment.fromMap(commentMapFromDb);
      final mapFromComment = commentFromMap.toMap();

      expect(mapFromComment, isNot(equals(commentMapFromDb)));
      expect(mapFromComment, equals(commentMapToDb));
    });

  });
}