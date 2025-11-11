import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/photo_profile_widget.dart';
import 'dart:typed_data';

void main() {
  group('PhotoProfileWidget', () {
    testWidgets('muestra el ícono por defecto cuando photoUrl es null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhotoProfileWidget(photoUrl: null),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('muestra el ícono por defecto cuando photoUrl está vacío',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhotoProfileWidget(photoUrl: ''),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

  

    testWidgets('muestra la imagen cuando se pasa un ImageProvider',
      (WidgetTester tester) async {
          final Uint8List transparentPixel = Uint8List.fromList([
                0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 
                0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 
                0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 
                0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
                0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 
                0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
                0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
                0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 
                0x42, 0x60, 0x82,
              ]);

          final testImage = MemoryImage(transparentPixel);

            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: PhotoProfileWidget(
                    imageProvider: testImage,
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();

            final imageFinder = find.descendant(
              of: find.byType(CircleAvatar),
              matching: find.byType(Image),
            );

            expect(imageFinder, findsOneWidget);

            final imageWidget = tester.widget<Image>(imageFinder);
            expect(imageWidget.image, testImage);

            expect(find.byIcon(Icons.person), findsNothing);
   });


    
    testWidgets('usa el radio correcto para el CircleAvatar',
        (WidgetTester tester) async {
      const customRadius = 40.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhotoProfileWidget(photoUrl: null, radius: customRadius),
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, equals(customRadius));
    });
  });
}