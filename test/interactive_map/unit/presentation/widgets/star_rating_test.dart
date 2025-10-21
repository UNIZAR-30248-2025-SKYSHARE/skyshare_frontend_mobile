import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/star_rating.dart';

void main() {
  group('StarRating', () {
    testWidgets('should render 5 full stars for rating 5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 5.0),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(5));
      expect(find.byIcon(Icons.star_half), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('should render 3 full stars, 1 half star and 1 empty for rating 3.5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 3.5),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('should render 5 empty stars for null rating', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: null),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_half), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
    });

    testWidgets('should render 2 full stars, 1 half and 2 empty for rating 2.5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 2.5),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(2));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('should render 4 full stars and 1 half for rating 4.7', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 4.7),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('should render correct star colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 3.0),
          ),
        ),
      );

      final fullStars = tester.widgetList<Icon>(find.byIcon(Icons.star));
      for (final star in fullStars) {
        expect(star.color, Colors.white);
      }

      final emptyStars = tester.widgetList<Icon>(find.byIcon(Icons.star_border));
      for (final star in emptyStars) {
        expect(star.color, Colors.white70);
      }
    });
  });
}