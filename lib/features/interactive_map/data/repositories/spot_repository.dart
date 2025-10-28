import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/spot_model.dart';

class SpotRepository {
  final SupabaseClient client;

  SpotRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;

  Future<String> uploadImage(XFile pickedFile, String nombreSpot) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${nombreSpot.replaceAll(' ', '_')}.jpg';

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      await client.storage.from('spots-images').uploadBinary(fileName, bytes);
    } else {
      final file = File(pickedFile.path);
      await client.storage.from('spots-images').upload(fileName, file);
    }

    return client.storage.from('spots-images').getPublicUrl(fileName);
  }

  Future<bool> insertSpot({
    required String nombre,
    required String descripcion,
    required String ciudad,
    required String pais,
    required double lat,
    required double lng,
    required XFile imagen,
    required String? creadorId,
  }) async {
    try {
      final urlImagen = await uploadImage(imagen, nombre);

      final ubicacionResp = await client.from('ubicacion').insert({
        'latitud': lat,
        'longitud': lng,
        'nombre': ciudad,
        'pais': pais,
      }).select().single();

      final int idUbicacion = ubicacionResp['id_ubicacion'];

      final resp = await client.from('spot').insert({
        'id_usuario_creador': creadorId,
        'nombre': nombre,
        'descripcion': descripcion,
        'id_ubicacion': idUbicacion,
        'url_imagen': urlImagen,
      }).select();

      return resp.isNotEmpty;
    } catch (e) {
      log('Error insertando spot: $e');
      return false;
    }
  }

  Future<bool> updateSpot({
    required int spotId,
    required String nombre,
    required String? descripcion,
    required XFile? nuevaImagen,
  }) async {
    try {
      String? urlImagen;
      if (nuevaImagen != null) {
        urlImagen = await uploadImage(nuevaImagen, nombre);
      }

      final Map<String, dynamic> updates = {
        'nombre': nombre,
        'descripcion': descripcion,
      };

      if (urlImagen != null) {
        updates['url_imagen'] = urlImagen;
      }

      final resp = await client
          .from('spot')
          .update(updates)
          .eq('id_spot', spotId)
          .select();
      
      return resp.isNotEmpty;
    } catch (e) {
      log('Error actualizando spot: $e');
      return false;
    }
  }

  Future<bool> deleteSpot(int spotId) async {
    try {
      await client
          .from('valoracion')
          .delete()
          .eq('id_spot', spotId);
          
      final resp = await client
          .from('spot')
          .delete()
          .eq('id_spot', spotId)
          .select();
          
      return resp.isNotEmpty;
    } catch (e) {
      log('Error eliminando spot y/o valoraciones: $e');
      return false;
    }
  }

  Future<List<Spot>> fetchAllSpots() async {
    final resp = await client.from('spot').select('*, valoracion(*), ubicacion(*)');
    final rows = (resp as List).map((e) => Map<String, dynamic>.from(e)).toList();
    return rows.map(Spot.fromMap).toList();
  }

  Future<Spot?> fetchSpotById(int id) async {
    final resp = await client
      .from('spot')
      .select('*, ubicacion(*), valoracion(puntuacion)')
      .eq('id_spot', id)
      .maybeSingle();

    if (resp == null) return null;
    return Spot.fromMap(Map<String, dynamic>.from(resp));
  }
}