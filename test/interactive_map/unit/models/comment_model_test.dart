import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Comment Model Tests', () {
    final testDate = DateTime(2023, 11, 15, 9, 00);
    final testDateIso = testDate.toIso8601String();

    final commentMapFromDb = {
      'id_comentario': 101, 
      'id_spot': 20,
      'id_usuario': 303, 
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

class Comment {
  final int id;
  final int spotId;
  final int userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.spotId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });


  Map<String, dynamic> toMap() {
    return {
      'id_spot': spotId,
      'id_usuario': userId,
      'texto': text,
      'fecha_comentario': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return Comment(
      id: parseInt(map['id_comentario']),
      spotId: parseInt(map['id_spot']),
      userId: parseInt(map['id_usuario']),
      text: map['texto']?.toString() ?? '',
      createdAt: parseDate(map['fecha_comentario']),
    );
  }
}
