import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/repositories/lunar_phase_repository.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/repositories/location_repository.dart';

class LunarPhaseProvider extends ChangeNotifier {
  final LunarPhaseRepository lunarPhaseRepo;
  final LocationRepository locationRepo;

  LunarPhaseProvider({
    required this.lunarPhaseRepo,
    required this.locationRepo,
  });

  List<LunarPhase> phases = [];
  bool isLoading = false;
  String? error;
  int? currentLocationId;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  bool _dataLoaded = false;

  Future<void> loadNext7Days() async {
    isLoading = true;
    error = null;
    _retryCount = 0;
    _dataLoaded = false;
    notifyListeners();

    try {
      currentLocationId = await locationRepo.getCurrentLocationId();
      if (currentLocationId == null) {
        await _waitForLocation();
        currentLocationId = await locationRepo.getCurrentLocationId();
        
        if (currentLocationId == null) {
          throw Exception('No location found for user');
        }
      }

      await _loadLunarDataWithRetry();

    } catch (e) {
      phases = [];
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLunarDataWithRetry() async {
    while (_retryCount < _maxRetries) {
      try {
        final fetched = await lunarPhaseRepo.fetchNext7DaysSimple(currentLocationId!);

        if (fetched.isNotEmpty) {
          phases = fetched.map((d) {
            return LunarPhase(
              idLuna: d.idLuna,
              idUbicacion: d.idUbicacion,
              fase: (d.fase.isNotEmpty) ? d.fase : 'Unknown phase',
              fecha: d.fecha,
              porcentajeIluminacion: (d.porcentajeIluminacion ?? 0).toDouble(),
              edadLunar: d.edadLunar,
              horaSalida: d.horaSalida,
              horaPuesta: d.horaPuesta,
              altitudActual: d.altitudActual,
              proximaFase: d.proximaFase,
            );
          }).toList();
          _dataLoaded = true;
          isLoading = false;
          notifyListeners();
          return;
        }

        _retryCount++;
        if (_retryCount < _maxRetries) {
          final delay = Duration(seconds: 2 * (1 << (_retryCount - 1)));
          await Future.delayed(delay);
        }
      } catch (e) {
        _retryCount++;
        if (_retryCount >= _maxRetries) {
          phases = [];
          error = 'No se pudieron cargar las fases lunares después de $_maxRetries intentos';
          isLoading = false;
          notifyListeners();
          return;
        }
        final delay = Duration(seconds: 2 * (1 << (_retryCount - 1)));
        await Future.delayed(delay);
      }
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> _waitForLocation() async {
    int attempts = 0;
    while (currentLocationId == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      currentLocationId = await locationRepo.getCurrentLocationId();
      attempts++;
    }
  }

  Future<LunarPhase?> fetchDetail(int lunarPhaseId, DateTime date) async {
    try {
      return await lunarPhaseRepo.fetchLunarPhaseDetailByIdAndDate(
        lunarPhaseId: lunarPhaseId,
        date: date,
      );
    } catch (e) {
      rethrow;
    }
  }

  void clear() {
    phases = [];
    error = null;
    isLoading = false;
    currentLocationId = null;
    _retryCount = 0;
    _dataLoaded = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    if (currentLocationId != null) {
      await loadNext7Days();
    }
  }

  bool get shouldShowRetry {
    return !isLoading && currentLocationId != null && !_dataLoaded && _retryCount >= _maxRetries;
  }
}