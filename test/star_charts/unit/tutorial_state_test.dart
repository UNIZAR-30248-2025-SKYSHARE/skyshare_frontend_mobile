import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/data/tutorial_data.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/domain/tutorial_state.dart';

void main() {
  group('TutorialState tests', () {
    late TutorialState state;

    setUp(() {
      state = TutorialState();
    });

    test('Initial state', () {
      expect(state.currentStep, TutorialStep.intro);
      expect(state.isActive, true);
    });

    test('nextStep advances through steps', () {
      state.nextStep();
      expect(state.currentStep, TutorialStep.searchRight);
      state.nextStep();
      expect(state.currentStep, TutorialStep.searchLeft);
      state.nextStep();
      expect(state.currentStep, TutorialStep.searchUp);
    });

    test('nextStep completes tutorial at last step', () {
      state.nextStep(); // intro -> searchRight
      state.nextStep(); // searchRight -> searchLeft
      state.nextStep(); // searchLeft -> searchUp
      state.nextStep(); // searchUp -> completed

      expect(state.currentStep, TutorialStep.completed);
      expect(state.isActive, false);
    });

    test('completeTutorial sets completed state', () {
      state.completeTutorial();
      expect(state.currentStep, TutorialStep.completed);
      expect(state.isActive, false);
    });

    test('reset returns to initial state', () {
      state.nextStep();
      state.completeTutorial();

      state.reset();
      expect(state.currentStep, TutorialStep.intro);
      expect(state.isActive, true);
    });

    test('isTargetObject returns correct result for each step', () {
      // intro step
      expect(state.isTargetObject('tut_right'), false);

      state.nextStep(); // searchRight
      expect(state.isTargetObject('tut_right'), true);
      expect(state.isTargetObject('tut_left'), false);

      state.nextStep(); // searchLeft
      expect(state.isTargetObject('tut_left'), true);
      expect(state.isTargetObject('tut_up'), false);

      state.nextStep(); // searchUp
      expect(state.isTargetObject('tut_up'), true);
      expect(state.isTargetObject('tut_left'), false);
    });
  });
}
