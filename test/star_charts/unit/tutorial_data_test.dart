import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/data/tutorial_data.dart';


void main() {
  group('TutorialData.getInstructionKey', () {
    test('devuelve la key correcta para cada enum', () {
      expect(
        TutorialData.getInstructionKey(TutorialStep.intro),
        'tutorial.intro',
      );

      expect(
        TutorialData.getInstructionKey(TutorialStep.searchRight),
        'tutorial.search_right',
      );

      expect(
        TutorialData.getInstructionKey(TutorialStep.searchLeft),
        'tutorial.search_left',
      );

      expect(
        TutorialData.getInstructionKey(TutorialStep.searchUp),
        'tutorial.search_up',
      );

      expect(
        TutorialData.getInstructionKey(TutorialStep.completed),
        'tutorial.completed',
      );
    });
  });
}
