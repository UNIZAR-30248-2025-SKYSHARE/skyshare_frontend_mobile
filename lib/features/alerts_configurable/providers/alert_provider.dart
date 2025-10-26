// providers/alert_provider.dart
import 'package:flutter/material.dart';
import '../data/model/alert_model.dart';
import '../data/repository/alerts_repository.dart';

class AlertProvider with ChangeNotifier {
  final AlertRepository _repository;
  
  List<AlertModel> _alerts = [];
  bool _isLoading = false;
  String? _error;

  AlertProvider({AlertRepository? repository}) 
      : _repository = repository ?? AlertRepository();

  List<AlertModel> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get activeAlertsCount => _alerts.where((a) => a.activa == true).length;

  // Cargar alertas desde Supabase
  Future<void> loadAlerts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alerts = await _repository.fetchAllAlerts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'No se pudieron cargar las alertas: ${e.toString()}';
      _isLoading = false;
      _alerts = [];
      notifyListeners();
    }
  }

  // Añadir alerta - GUARDA EN SUPABASE
  Future<void> addAlert(AlertModel alert) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Crear la alerta en Supabase
      await _repository.createAlert(alert.toMap());
      
      // Recargar todas las alertas para obtener el ID correcto
      await loadAlerts();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al crear la alerta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Actualizar alerta - GUARDA EN SUPABASE
  Future<void> updateAlert(int alertId, AlertModel updatedAlert) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Actualizar en Supabase
      await _repository.updateAlert(alertId, updatedAlert.toMap());
      
      // Recargar alertas
      await loadAlerts();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar la alerta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Activar/desactivar alerta - GUARDA EN SUPABASE
  Future<void> toggleAlert(int alertId, bool isActive) async {
    try {
      final index = _alerts.indexWhere((a) => a.idAlerta == alertId);
      if (index == -1) return;

      final alert = _alerts[index];
      final updatedAlert = alert.copyWith(activa: isActive);

      // Actualizar localmente primero para feedback inmediato
      _alerts[index] = updatedAlert;
      notifyListeners();

      // Actualizar en Supabase
      await _repository.updateAlert(alertId, updatedAlert.toMap());
    } catch (e) {
      _error = 'Error al cambiar el estado de la alerta: ${e.toString()}';
      // Revertir cambio local si falla
      await loadAlerts();
      notifyListeners();
    }
  }

  // Eliminar alerta - ELIMINA DE SUPABASE
  Future<void> deleteAlert(int alertId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteAlert(alertId);
      
      // Actualizar lista local
      _alerts.removeWhere((a) => a.idAlerta == alertId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar la alerta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Obtener alerta por ID
  AlertModel? getAlertById(int alertId) {
    try {
      return _alerts.firstWhere((a) => a.idAlerta == alertId);
    } catch (e) {
      return null;
    }
  }

  // Filtrar alertas por tipo
  List<AlertModel> getAlertsByType(String type) {
    final t = type.toLowerCase();
    return _alerts.where((a) => a.tipoAlerta.toLowerCase() == t).toList();
  }

  // Obtener alertas activas
  List<AlertModel> get activeAlerts {
    return _alerts.where((a) => a.activa == true).toList();
  }

  // Obtener alertas inactivas
  List<AlertModel> get inactiveAlerts {
    return _alerts.where((a) => a.activa == false).toList();
  }

  // Obtener próximas alertas (próximos 7 días)
  List<AlertModel> get upcomingAlerts {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));

    return _alerts.where((alert) {
      final fecha = alert.fechaObjetivo;
      return fecha.isAfter(now) && fecha.isBefore(sevenDaysLater);
    }).toList();
  }

  // Limpiar todas las alertas
  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  // Resetear estado
  void reset() {
    _alerts = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}