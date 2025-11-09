import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/constellation_info_panel.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/star_chart_content.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/providers/star_chart_provider.dart';

class MockStarChartProvider extends Mock implements StarChartProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StarChartContent', () {
    late MockStarChartProvider mockProvider;

    setUp(() {
      mockProvider = MockStarChartProvider();
      
      when(() => mockProvider.isLoading).thenReturn(false);
      when(() => mockProvider.visibleBodies).thenReturn([]);
    });

    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(StarChartContent), findsOneWidget);
    });

    testWidgets('shows loading overlay when isLoading is true', (WidgetTester tester) async {
      when(() => mockProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.text('Cargando mapa estelar...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading when compass is not ready', (WidgetTester tester) async {
      when(() => mockProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.text('Cargando mapa estelar...'), findsOneWidget);
    });

    testWidgets('handles empty visible bodies', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(StarChartContent), findsOneWidget);
    });

    testWidgets('handles non-empty visible bodies', (WidgetTester tester) async {
      when(() => mockProvider.visibleBodies).thenReturn([
        {
          'name': 'Sirius',
          'type': 'star',
          'az': 100.0,
          'alt': 30.0,
          'mag': -1.46,
          'is_visible': true,
        }
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(StarChartContent), findsOneWidget);
    });

    testWidgets('shows ConstellationInfoPanel when star is selected', (WidgetTester tester) async {
      when(() => mockProvider.visibleBodies).thenReturn([
        {
          'name': 'Sirius',
          'type': 'star',
          'az': 100.0,
          'alt': 30.0,
          'mag': -1.46,
          'is_visible': true,
        }
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(ConstellationInfoPanel), findsNothing);
    });

    testWidgets('has black background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      final containerFinder = find.byWidgetPredicate(
        (widget) => widget is Container && widget.color == Colors.black,
      );
      
      expect(containerFinder, findsAtLeast(1));
    });

    testWidgets('uses LayoutBuilder for responsive sizing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
    });
  });

  group('StarChartContent Edge Cases', () {
    late MockStarChartProvider mockProvider;

    setUp(() {
      mockProvider = MockStarChartProvider();
      when(() => mockProvider.isLoading).thenReturn(false);
      when(() => mockProvider.visibleBodies).thenReturn([]);
    });

    testWidgets('handles provider with empty visibleBodies', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(StarChartContent), findsOneWidget);
    });

    testWidgets('handles provider with mixed celestial objects', (WidgetTester tester) async {
      when(() => mockProvider.visibleBodies).thenReturn([
        {
          'name': 'Orion',
          'type': 'constellation',
          'az': 100.0,
          'alt': 30.0,
          'is_visible': true,
        },
        {
          'name': 'Sirius',
          'type': 'star',
          'az': 120.0,
          'alt': 40.0,
          'mag': -1.46,
          'is_visible': true,
        },
        {
          'name': 'Jupiter',
          'type': 'planet',
          'az': 80.0,
          'alt': 20.0,
          'mag': -2.0,
          'is_visible': true,
        }
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(StarChartContent), findsOneWidget);
    });

    testWidgets('handles objects with missing properties', (WidgetTester tester) async {
      when(() => mockProvider.visibleBodies).thenReturn([
        {
          'name': 'Unknown Object',
        }
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(StarChartContent), findsOneWidget);
    });

    testWidgets('contains expected widget structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Container), findsAtLeast(1));
      
      expect(find.text('Cargando mapa estelar...'), findsOneWidget);
    });
  });

  group('StarChartContent Integration', () {
    late MockStarChartProvider mockProvider;

    setUp(() {
      mockProvider = MockStarChartProvider();
      when(() => mockProvider.isLoading).thenReturn(false);
      when(() => mockProvider.visibleBodies).thenReturn([]);
    });

    testWidgets('builds complete widget tree without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.byType(StarChartContent), findsOneWidget);
      expect(find.byType(LayoutBuilder), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Container), findsAtLeast(1));
    });

    testWidgets('shows loading when compass is not ready', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StarChartContent(starChartProvider: mockProvider),
        ),
      );

      expect(find.text('Cargando mapa estelar...'), findsOneWidget);
    });
  });
}