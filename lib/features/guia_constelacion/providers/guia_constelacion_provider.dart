import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/models/guia_model.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/repository/guia_repository.dart';

class GuiaConstelacionProvider extends ChangeNotifier {
  final GuiaConstelacionRepository guiaRepo;

  GuiaConstelacionProvider({required this.guiaRepo});

  GuiaConstelacion? guia;
  bool isLoading = false;
  String? error;
  /// Optional machine-readable error key for UI localization
  String? errorKey;
  /// optional arguments for the error (not currently interpolated by AppLocalizations)
  List<String>? errorArgs;
  bool _dataLoaded = false;

  Future<void> fetchGuiaPorNombreYTemporada({
    required String nombreConstelacion,
    required String temporada,
  }) async {
    isLoading = true;
    error = null;
    _dataLoaded = false;
    notifyListeners();

    try {
      final fetched = await guiaRepo.fetchByNombreYTemporada(
        nombreConstelacion: nombreConstelacion,
        temporada: temporada,
      );

      if (fetched != null) {
        guia = fetched;
        _dataLoaded = true;
        error = null;
        errorKey = null;
        errorArgs = null;
      } else {
        guia = null;
        // set an i18n-friendly error key; UI will render a localized message
        error = null;
        errorKey = 'no_se_encontro_la_guia';
        errorArgs = [nombreConstelacion, temporada];
      }
    } catch (e) {
      guia = null;
      // For unexpected exceptions keep the raw error string
      error = e.toString();
      errorKey = null;
      errorArgs = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia los datos del provider
  void clear() {
    guia = null;
    error = null;
    errorKey = null;
    errorArgs = null;
    isLoading = false;
    _dataLoaded = false;
    notifyListeners();
  }

  /// Permite forzar una recarga de la guía
  Future<void> refresh({
    required String nombreConstelacion,
    required String temporada,
  }) async {
    await fetchGuiaPorNombreYTemporada(
      nombreConstelacion: nombreConstelacion,
      temporada: temporada,
    );
  }

  bool get dataLoaded => _dataLoaded;
  bool get shouldShowRetry => !_dataLoaded && !isLoading && error != null;
}
