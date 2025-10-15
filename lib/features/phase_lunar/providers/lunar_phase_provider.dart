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

  Future<void> loadNext7Days() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      currentLocationId = await locationRepo.getCurrentLocationId(1);
      print('Current location ID: $currentLocationId');
      if (currentLocationId == null) {
        throw Exception('No location found for user');
      }

      final fetched = await lunarPhaseRepo.fetchNext7DaysSimple(currentLocationId!);

      print('Fetched lunar phases: $fetched');
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
    } catch (e) {
      phases = [];
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
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
    notifyListeners();
  }

  Future<void> refreshData() async {
    if (currentLocationId != null) {
      await loadNext7Days();
    }
  }
}