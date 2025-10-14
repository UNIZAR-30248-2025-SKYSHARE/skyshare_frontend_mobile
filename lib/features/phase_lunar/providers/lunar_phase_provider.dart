import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/repositories/lunar_phase_repository.dart' as phase_lunar_repo;

class LunarPhaseProvider extends ChangeNotifier {
  final phase_lunar_repo.LunarPhaseRepository repo;

  LunarPhaseProvider({ required this.repo });

  List<LunarPhase> phases = [];
  bool isLoading = false;
  String? error;

  Future<void> loadNext7Days(int locationId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fetched = await repo.fetchNext7DaysSimple(locationId);
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
      return await repo.fetchLunarPhaseDetailByIdAndDate(
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
    notifyListeners();
  }
}
