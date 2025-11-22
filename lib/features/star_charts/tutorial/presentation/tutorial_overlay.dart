import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/data/tutorial_data.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class TutorialOverlay extends StatelessWidget {
  final TutorialStep currentStep;
  final bool isTargetVisible;
  final VoidCallback onNextStep;
  final VoidCallback onSkip;

  const TutorialOverlay({
    super.key,
    required this.currentStep,
    required this.isTargetVisible,
    required this.onNextStep,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    // No mostramos overlay si ya terminó
    if (currentStep == TutorialStep.completed) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: _buildDirectionIndicator(context),
        ),

        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: _buildBottomPanel(context),
        ),

        Positioned(
          top: 50, // Ajustar según SafeArea
            right: 20,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                AppLocalizations.of(context)?.t('tutorial.skip') ?? 'Skip',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDirectionIndicator(BuildContext context) {
    IconData? icon;
    
    switch (currentStep) {
      case TutorialStep.searchRight:
        icon = Icons.arrow_forward_ios;
        break;
      case TutorialStep.searchLeft:
        icon = Icons.arrow_back_ios;
        break;
      case TutorialStep.searchUp:
        icon = Icons.arrow_upward;
        break;
      default:
        return const SizedBox.shrink();
    }

    // Si el objeto YA es visible, ocultamos la flecha para no molestar
    if (isTargetVisible) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Icon(
        icon,
        size: 100,
        color: Colors.white.withOpacity(0.3), // Semitransparente
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    final key = TutorialData.getInstructionKey(currentStep);
    final instruction = AppLocalizations.of(context)?.t(key) ?? key;
    
    // Configuración del botón según el paso
    bool isButtonEnabled = false;
    String buttonText = "CONTINUAR";
    Color buttonColor = Colors.grey;

    if (currentStep == TutorialStep.intro) {
      isButtonEnabled = true;
      buttonText = AppLocalizations.of(context)?.t('tutorial.button.start') ?? 'START';
      buttonColor = const Color(0xFF6366F1); // Índigo
    } else {
      if (isTargetVisible) {
        isButtonEnabled = true;
        buttonText = AppLocalizations.of(context)?.t('tutorial.button.found') ?? 'I SEE IT!';
        buttonColor = Colors.green;
      } else {
        isButtonEnabled = false;
        buttonText = AppLocalizations.of(context)?.t('tutorial.button.searching') ?? 'SEARCHING...';
        buttonColor = Colors.grey.withOpacity(0.5);
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Texto de Instrucción
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? onNextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  disabledBackgroundColor: buttonColor, 
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: isButtonEnabled ? Colors.white : Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}