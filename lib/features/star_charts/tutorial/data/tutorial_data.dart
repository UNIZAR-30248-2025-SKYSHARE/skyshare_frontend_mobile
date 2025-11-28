enum TutorialStep {
  intro,
  searchRight,
  searchLeft,
  searchUp,
  completed
}

class TutorialData {
  
  static List<Map<String, dynamic>> getMockCelestialBodies(double userHeading) {
    
    double normalize(double angle) {
      double res = angle % 360;
      return res < 0 ? res + 360 : res;
    }

    final double rightAz = normalize(userHeading + 50); 
    final double leftAz = normalize(userHeading - 50);  
    final double upAz = userHeading;                    

    return [
      // --- PASO 1: DERECHA (Constelación de Andrómeda) ---
      {
        'id': 'tut_right',
        'tutorial_step': TutorialStep.searchRight, // Etiqueta para filtrar
        'name': 'Andrómeda',
        'az': rightAz,
        'alt': 20.0, 
        'mag': 1.5,
        'type': 'constellation',
        'constellation': 'Andrómeda',
        'is_visible': true,
        'stars': [
           {'name': 'Alpha', 'az': rightAz, 'alt': 20.0, 'mag': 2.0, 'is_visible': true},
           {'name': 'Beta', 'az': rightAz + 5, 'alt': 22.0, 'mag': 2.5, 'is_visible': true},
           {'name': 'Gamma', 'az': rightAz - 5, 'alt': 18.0, 'mag': 2.5, 'is_visible': true},
        ]
      },

      // --- PASO 2: IZQUIERDA (Planeta Marte) ---
      {
        'id': 'tut_left',
        'tutorial_step': TutorialStep.searchLeft,
        'name': 'Marte',
        'az': leftAz,
        'alt': 15.0, 
        'mag': -1.5, 
        'type': 'planet',
        'is_visible': true,
      },

      // --- PASO 3 & 4: ARRIBA (Estrella Polar) ---
      // Este objeto se usa tanto para buscar arriba como para hacer click
      {
        'id': 'tut_up',
        'tutorial_step': TutorialStep.searchUp, 
        'name': 'Polaris',
        'az': upAz,
        'alt': 70.0, 
        'mag': 0.5, 
        'type': 'star',
        'constellation': 'Ursa Minor',
        'is_visible': true,
      },
    ];
  }
  
  // Return a translation key for the requested tutorial step. The UI
  // layer is responsible for resolving the key to a localized string
  // using the `AppLocalizations` helper.
  static String getInstructionKey(TutorialStep step) {
    switch (step) {
      case TutorialStep.intro:
        return 'tutorial.intro';
      case TutorialStep.searchRight:
        return 'tutorial.search_right';
      case TutorialStep.searchLeft:
        return 'tutorial.search_left';
      case TutorialStep.searchUp:
        return 'tutorial.search_up';
      case TutorialStep.completed:
        return 'tutorial.completed';
    }
  }
}