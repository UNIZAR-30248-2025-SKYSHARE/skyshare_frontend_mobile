import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/widgets/phase_lunar_info_row.dart';

void main() {
  group('PhaseLunarInfoRow', () {
    testWidgets('muestra correctamente los iconos y textos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhaseLunarInfoRow(
              rise: '06:30',
              set: '18:45',
              illumination: '75%',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.nights_stay), findsOneWidget);
      expect(find.byIcon(Icons.wb_twighlight), findsOneWidget);
      expect(find.byIcon(Icons.light_mode), findsOneWidget);

      expect(find.text('Rise\n06:30'), findsOneWidget);
      expect(find.text('Set\n18:45'), findsOneWidget);
      expect(find.text('Illum.\n75%'), findsOneWidget);
    });

    testWidgets('all columns have correct text alignment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhaseLunarInfoRow(
              rise: '07:00',
              set: '19:00',
              illumination: '50%',
            ),
          ),
        ),
      );

      final textFinder = find.byType(Text);
      for (var textWidget in textFinder.evaluate()) {
        final text = textWidget.widget as Text;
        expect(text.textAlign, TextAlign.center);
      }
    });

    // testWidgets('columns are spaced correctly with spaceBetween', (tester) async {
    //   await tester.pumpWidget(
    //     const MaterialApp(
    //       home: Scaffold(
    //         body: SizedBox(
    //           width: 300, 
    //           child: PhaseLunarInfoRow(
    //             rise: '06:30',
    //             set: '18:45',
    //             illumination: '75%',
    //           ),
    //         ),
    //       ),
    //     ),
    //   );

    //   final columnFinder = find.byType(Column);
    //   expect(columnFinder, findsNWidgets(3));

    //   final columns = columnFinder.evaluate().toList();
    //   final leftX = tester.getTopLeft(find.byWidget(columns[0].widget)).dx;
    //   final middleX = tester.getTopLeft(find.byWidget(columns[1].widget)).dx;
    //   final rightX = tester.getTopLeft(find.byWidget(columns[2].widget)).dx;

    //   expect(leftX < middleX, isTrue);
    //   expect(middleX < rightX, isTrue);

    //   expect(rightX - leftX > 100, isTrue);
    // });
  });
}
