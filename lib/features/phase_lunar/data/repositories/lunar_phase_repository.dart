import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/lunar_phase_model.dart';

class LunarPhaseRepository {
  final SupabaseClient client;

  LunarPhaseRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;

  Future<List<LunarPhase>> fetchNext7DaysSimple(int locationId) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 7));

    final resp = await client
        .from('fase_lunar')
        .select('id_luna, fase, porcentaje_iluminacion, fecha')
        .eq('id_ubicacion', locationId)
        .gte('fecha', startDate.toIso8601String())
        .lte('fecha', endDate.toIso8601String())
        .order('fecha', ascending: true);

    final rows = (resp as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return rows.map(LunarPhase.fromMap).toList();
  }

  Future<LunarPhase?> fetchLunarPhaseDetailByIdAndDate({
    required int lunarPhaseId,
    required DateTime date,
  }) async {
    final resp = await client
        .from('fase_lunar')
        .select(
          '''
          id_luna,
          id_ubicacion,
          fase,
          porcentaje_iluminacion,
          edad_lunar,
          hora_salida,
          azimut_salida,
          hora_puesta,
          azimut_puesta,
          altitud_actual,
          proxima_fase,
          fecha
          ''',
        )
        .eq('id_luna', lunarPhaseId)
        .eq('fecha', date.toIso8601String())
        .maybeSingle();

    if (resp == null) return null;

    return LunarPhase.fromMap(Map<String, dynamic>.from(resp as Map));
  }
}
