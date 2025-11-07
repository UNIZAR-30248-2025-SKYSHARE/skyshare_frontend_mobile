import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/data/repositories/star_chart_repository.dart';

class StarChartProvider with ChangeNotifier {
  final StarChartRepository _astronomyRepository;

  StarChartProvider({required StarChartRepository astronomyRepository})
      : _astronomyRepository = astronomyRepository;

  List<Map<String, dynamic>> _celestialBodies = [];
  List<Map<String, dynamic>> get celestialBodies => _celestialBodies;
  
  List<Map<String, dynamic>> get visibleBodies => 
      _celestialBodies.where((obj) => obj['is_visible'] == true).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> fetchCelestialBodies({
    required double latitude,
    required double longitude,
  }) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final storedData = await _astronomyRepository.getStoredCelestialData();
      if (storedData.isNotEmpty) {
        _celestialBodies = storedData;
      } else {
        await _callEdgeFunctionWithRetry(latitude, longitude);
      }
      
      _error = null;
      
    } catch (e) {
      _error = e.toString();
      _celestialBodies = await _getStoredData();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _callEdgeFunctionWithRetry(double latitude, double longitude) async {
    const int maxRetries = 3;
    const Duration initialDelay = Duration(seconds: 3);
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (attempt == 1) {
          await Future.delayed(initialDelay);
        } else {
          await Future.delayed(Duration(seconds: attempt * 2));
        }

        final data = await _astronomyRepository.getCelestialBodies(
          latitude: latitude,
          longitude: longitude,
        );
        
        final extractedData = _astronomyRepository.extractCelestialBodiesFromData(data);
        
        if (extractedData.isNotEmpty) {
          _celestialBodies = extractedData;
          return;
        }
        
      } catch (e) {
        if (attempt == maxRetries) {
          throw Exception("No se pudieron obtener datos después de $maxRetries intentos: $e");
        }
      }
    }
    
    throw Exception("No se pudieron cargar los datos celestes después de $maxRetries intentos");
  }

  Future<List<Map<String, dynamic>>> _getStoredData() async {
    try {
      final storedData = await _astronomyRepository.getStoredCelestialData();

      if (storedData.isNotEmpty) {
        return storedData;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}