import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/comment_item.dart';

void main() {
  group('CommentItem', () {
    testWidgets('should render author and time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentItem(
              author: 'Test User',
              time: '2 h',
            ),
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Hace 2 h'), findsOneWidget);
    });

    testWidgets('should render user avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentItem(
              author: 'Test User',
              time: '2 h',
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should have correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentItem(
              author: 'Test User',
              time: '2 h',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF1A1A24));
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('should render multiple comment items correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CommentItem(
                  author: 'User 1',
                  time: '1 h',
                ),
                CommentItem(
                  author: 'User 2',
                  time: '3 h',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('User 1'), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
      expect(find.text('Hace 1 h'), findsOneWidget);
      expect(find.text('Hace 3 h'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNWidgets(2));
    });
  });
}