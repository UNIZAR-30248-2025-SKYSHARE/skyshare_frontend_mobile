// data/repository/alerts_repository.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/alert_model.dart';

class AlertRepository {
  final SupabaseClient client;
  final String tableName;

  AlertRepository({SupabaseClient? client, this.tableName = 'alerta'})
      : client = client ?? Supabase.instance.client;

  // Obtener todas las alertas del usuario actual
  Future<List<AlertModel>> fetchAllAlerts() async {
    try {
      final userId = client.auth.currentUser?.id;
      
      final resp = await client
          .from(tableName)
          .select()
          .eq('id_usuario', userId ?? 'user123')
          .order('fecha_objetivo', ascending: true);
      
      final rows = (resp as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return rows.map((row) => AlertModel.fromMap(row)).toList();
    } catch (e) {
      throw Exception('Error al cargar alertas: $e');
    }
  }

  // Obtener resumen de alertas (solo campos esenciales para la lista)
  // Esto es para optimizar cuando solo necesites mostrar la lista sin detalles
  Future<List<Map<String, dynamic>>> fetchAlertsSummary() async {
    try {
      final userId = client.auth.currentUser?.id;
      
      final resp = await client
          .from(tableName)
          .select('''
            id_alerta,
            tipo_alerta,
            parametro_objetivo,
            nombre_ubicacion,
            fecha_objetivo,
            tipo_repeticion,
            activa
          ''')
          .eq('id_usuario', userId ?? 'user123')
          .order('fecha_objetivo', ascending: true);

      return List<Map<String, dynamic>>.from(resp as List);
    } catch (e) {
      throw Exception('Error al cargar resumen de alertas: $e');
    }
  }

  // Obtener alerta individual por ID
  Future<AlertModel?> fetchAlertById(int idAlerta) async {
    try {
      final resp = await client
          .from(tableName)
          .select()
          .eq('id_alerta', idAlerta)
          .maybeSingle();
      
      if (resp == null) return null;

      final row = Map<String, dynamic>.from(resp as Map);
      return AlertModel.fromMap(row);
    } catch (e) {
      throw Exception('Error al cargar alerta: $e');
    }
  }

  // Crear alerta nueva
  Future<AlertModel> createAlert(Map<String, dynamic> alertData) async {
    try {
      // Crear copia limpia de los datos
      final dataToInsert = Map<String, dynamic>.from(alertData);
      
      // CRÍTICO: Remover id_alerta para que Supabase lo genere automáticamente
      dataToInsert.remove('id_alerta');
      
      // Si no hay id_usuario válido, usar uno temporal
      if (!dataToInsert.containsKey('id_usuario') || 
          dataToInsert['id_usuario'] == null ||
          dataToInsert['id_usuario'] == 'user123' ||
          dataToInsert['id_usuario'].toString().isEmpty) {
        
        // Intentar obtener el ID del usuario autenticado
        final currentUser = client.auth.currentUser;
        if (currentUser != null && currentUser.id.isNotEmpty) {
          dataToInsert['id_usuario'] = currentUser.id;
        } else {
          // Si no hay usuario autenticado, usar un ID temporal
          dataToInsert['id_usuario'] = 'temp_user_${DateTime.now().millisecondsSinceEpoch}';
        }
      }

      if (kDebugMode) {
        print('DEBUG: Datos a insertar: $dataToInsert');
      } // Para debug

      // Insertar y obtener el registro creado
      final resp = await client
          .from(tableName)
          .insert(dataToInsert)
          .select()
          .single();

      if (kDebugMode) {
        print('DEBUG: Respuesta de Supabase: $resp');
      } // Para debug

      return AlertModel.fromMap(Map<String, dynamic>.from(resp as Map));
    } catch (e) {
      if (kDebugMode) {
        print('ERROR al crear alerta: $e');
      } // Para debug
      throw Exception('Error al crear alerta: $e');
    }
  }

  // Actualizar alerta existente
  Future<void> updateAlert(int idAlerta, Map<String, dynamic> alertData) async {
    try {
      // Remover el id_alerta del map de actualización
      final dataToUpdate = Map<String, dynamic>.from(alertData);
      dataToUpdate.remove('id_alerta');
      dataToUpdate.remove('id_usuario'); // No actualizar el usuario

      await client
          .from(tableName)
          .update(dataToUpdate)
          .eq('id_alerta', idAlerta);
    } catch (e) {
      throw Exception('Error al actualizar alerta: $e');
    }
  }

  // Eliminar alerta
  Future<void> deleteAlert(int idAlerta) async {
    try {
      await client
          .from(tableName)
          .delete()
          .eq('id_alerta', idAlerta);
    } catch (e) {
      throw Exception('Error al eliminar alerta: $e');
    }
  }

  // Activar/desactivar alerta
  Future<void> toggleAlert(int idAlerta, bool activa) async {
    try {
      await client
          .from(tableName)
          .update({'activa': activa})
          .eq('id_alerta', idAlerta);
    } catch (e) {
      throw Exception('Error al cambiar estado de alerta: $e');
    }
  }

  // Obtener alertas activas del usuario
  Future<List<AlertModel>> fetchActiveAlerts() async {
    try {
      final userId = client.auth.currentUser?.id;
      
      final resp = await client
          .from(tableName)
          .select()
          .eq('id_usuario', userId ?? 'user123')
          .eq('activa', true)
          .order('fecha_objetivo', ascending: true);
      
      final rows = (resp as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return rows.map((row) => AlertModel.fromMap(row)).toList();
    } catch (e) {
      throw Exception('Error al cargar alertas activas: $e');
    }
  }

  // Obtener alertas por tipo
  Future<List<AlertModel>> fetchAlertsByType(String tipoAlerta) async {
    try {
      final userId = client.auth.currentUser?.id;
      
      final resp = await client
          .from(tableName)
          .select()
          .eq('id_usuario', userId ?? 'user123')
          .eq('tipo_alerta', tipoAlerta)
          .order('fecha_objetivo', ascending: true);
      
      final rows = (resp as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return rows.map((row) => AlertModel.fromMap(row)).toList();
    } catch (e) {
      throw Exception('Error al cargar alertas por tipo: $e');
    }
  }
}