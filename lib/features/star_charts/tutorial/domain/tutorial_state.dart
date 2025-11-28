import 'package:flutter/foundation.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/data/tutorial_data.dart';

class TutorialState extends ChangeNotifier {
  
  TutorialStep _currentStep = TutorialStep.intro;
  bool _isActive = true; 

  TutorialStep get currentStep => _currentStep;
  bool get isActive => _isActive;

  void nextStep() {
    switch (_currentStep) {
      case TutorialStep.intro:
        _currentStep = TutorialStep.searchRight;
        break;

      case TutorialStep.searchRight:
        _currentStep = TutorialStep.searchLeft;
        break;

      case TutorialStep.searchLeft:
        _currentStep = TutorialStep.searchUp;
        break;

      case TutorialStep.searchUp:
        completeTutorial();
        return;

      case TutorialStep.completed:
        break;
    }
    notifyListeners();
  }

  void completeTutorial() {
    _currentStep = TutorialStep.completed;
    _isActive = false;
    notifyListeners();
  }

  void reset() {
    _currentStep = TutorialStep.intro;
    _isActive = true;
    notifyListeners();
  }
  
  bool isTargetObject(String objectId) {
    switch (_currentStep) {
      case TutorialStep.searchRight:
        return objectId == 'tut_right';
      case TutorialStep.searchLeft:
        return objectId == 'tut_left';
      case TutorialStep.searchUp:
        return objectId == 'tut_up';
      default:
        return false;
    }
  }
}