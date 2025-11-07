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
    
    if (_isInitialized) {
      notifyListeners();
    }

    try {
      final data = await _astronomyRepository.getCelestialBodies(
        latitude: latitude,
        longitude: longitude,
      );
      
      _celestialBodies = _astronomyRepository.extractCelestialBodiesFromData(data);
      print("CELESTIAL BODIES: ${_celestialBodies.toString()}");
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

  Future<List<Map<String, dynamic>>> _getStoredData() async {
    try {
      final storedData = await _astronomyRepository.getStoredCelestialData();
      if (storedData.isNotEmpty) {
        return storedData;
      }
      return _getDemoData();
    } catch (e) {
      return _getDemoData();
    }
  }

  List<Map<String, dynamic>> _getDemoData() {
    return [
      {
        'id': 'sirius',
        'name': 'Sirius',
        'az': 180.0,
        'alt': 25.0,
        'mag': -1.46,
        'type': 'star',
        'constellation': 'Canis Major',
        'is_visible': true,
      },
      {
        'id': 'vega',
        'name': 'Vega',
        'az': 45.0,
        'alt': 60.2,
        'mag': 0.03,
        'type': 'star',
        'constellation': 'Lyra',
        'is_visible': true,
      },
    ];
  }
}