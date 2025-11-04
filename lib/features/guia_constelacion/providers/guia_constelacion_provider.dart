import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/models/guia_model.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/repository/guia_repository.dart';

class GuiaConstelacionProvider extends ChangeNotifier {
  final GuiaConstelacionRepository guiaRepo;

  GuiaConstelacionProvider({required this.guiaRepo});

  GuiaConstelacion? guia;
  bool isLoading = false;
  String? error;
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
      } else {
        guia = null;
        error = 'No se encontró la guía para $nombreConstelacion ($temporada)';
      }
    } catch (e) {
      guia = null;
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia los datos del provider
  void clear() {
    guia = null;
    error = null;
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
