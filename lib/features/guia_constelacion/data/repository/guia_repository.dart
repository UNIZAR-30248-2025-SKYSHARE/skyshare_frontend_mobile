import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/guia_model.dart';

class GuiaConstelacionRepository {
  final SupabaseClient client;

  GuiaConstelacionRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;

  Future<GuiaConstelacion?> fetchByNombreYTemporada({
    required String nombreConstelacion,
    required String temporada,
  }) async {
    final resp = await client
        .from('guia_constelacion')
        .select()
        .eq('nombre_constelacion', nombreConstelacion)
        .eq('temporada', temporada)
        .maybeSingle();

    if (resp == null) return null;

    return GuiaConstelacion.fromMap(Map<String, dynamic>.from(resp as Map));
  }

  Future<List<GuiaConstelacion>> fetchAll() async {
    final resp = await client
        .from('guia_constelacion')
        .select()
        .order('nombre_constelacion', ascending: true);

    final rows =
        (resp as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

    return rows.map(GuiaConstelacion.fromMap).toList();
  }
}
