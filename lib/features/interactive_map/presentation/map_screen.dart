import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/interactive_map_provider.dart';
import './widgets/map_widget.dart';
import './widgets/loading_overlay.dart';
import './widgets/error_banner.dart';
import './widgets/zoom_controls.dart';
import './widgets/location_button.dart';
import './widgets/filter_widget.dart';
import './widgets/create_spot.dart';
import '../data/models/spot_model.dart';

class MapScreen extends StatefulWidget {
  final TileProvider? tileProvider;
  final String? urlTemplate;
  const MapScreen({super.key, this.tileProvider, this.urlTemplate});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Marker> _createdMarkers = [];
  final MapController _mapController = MapController();
  String _filterValue = '';
  FilterType _filterType = FilterType.nombre;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mapProvider = Provider.of<InteractiveMapProvider>(context, listen: false);
      await mapProvider.fetchUserLocation();
      await mapProvider.fetchSpots();
      if (mapProvider.currentPosition != null) {
        _mapController.move(mapProvider.currentPosition!, 14.5);
      }
    });
  }

  void _handleTap(TapPosition tapPosition, LatLng position) => _showLocationConfirmation(position, false);
  void _handleLongPress(TapPosition tapPosition, LatLng position) => _showLocationConfirmation(position, true);

  void _showLocationConfirmation(LatLng position, bool isLongPress) async {
    final mapProvider = Provider.of<InteractiveMapProvider>(context, listen: false);
    _showLoadingDialog();
    final result = await mapProvider.fetchSpotLocation(position);
    if (mounted) Navigator.pop(context);
    final city = result['city'] ?? 'Desconocida';
    final country = result['country'] ?? 'Desconocido';
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Crear Spot'),
        content: Text('Ciudad: $city\nPaís: $country'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateSpot(position);
            },
            child: const Text('Sí, crear'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _navigateToCreateSpot(LatLng position) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSpotScreen(position: position),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _createdMarkers.add(
          Marker(
            point: position,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spot "${result['nombre']}" creado!')),
      );
      final mapProvider = Provider.of<InteractiveMapProvider>(context, listen: false);
      await mapProvider.fetchSpots();
    }
  }

  void _zoomIn() {
    final zoom = _mapController.camera.zoom + 1;
    _mapController.move(_mapController.camera.center, zoom);
  }

  void _zoomOut() {
    final zoom = _mapController.camera.zoom - 1;
    _mapController.move(_mapController.camera.center, zoom);
  }

  void _moveToCurrentLocation() {
    final mapProvider = Provider.of<InteractiveMapProvider>(context, listen: false);
    if (mapProvider.currentPosition != null) {
      _mapController.move(mapProvider.currentPosition!, 14.5);
    } else {
      mapProvider.fetchUserLocation();
    }
  }

  void _onFilterChanged(FilterType type, String value) {
    setState(() {
      _filterType = type;
      _filterValue = value.toLowerCase();
    });
  }

  void _onFilterClear() {
    setState(() {
      _filterValue = '';
    });
  }

  List<Spot> _filterSpots(List<Spot> spots) {
    if (_filterValue.isEmpty) return spots;
    
    switch (_filterType) {
      case FilterType.nombre:
        return spots.where((spot) {
          return spot.nombre.toLowerCase().contains(_filterValue);
        }).toList();
        
      case FilterType.valoracion:
        final minRating = double.tryParse(_filterValue);
        if (minRating == null) return spots;
        return spots.where((spot) {
          if (spot.valoracionMedia == null) return false;
          return spot.valoracionMedia! >= minRating;
        }).toList();
    }
  }

  Color _getMarkerColor(Spot spot) {
    if (spot.valoracionMedia == null) return Colors.grey;
    if (spot.valoracionMedia! >= 4.5) return Colors.green;
    if (spot.valoracionMedia! >= 3.5) return Colors.orange;
    return Colors.red;
  }

  List<Marker> _spotsToMarkers(List<Spot> spots) {
    return spots.map((s) {
      final color = _getMarkerColor(s);
      return Marker(
        point: LatLng(s.lat, s.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (s.valoracionMedia != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.yellow, 
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: color, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  s.valoracionMedia!.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (s.descripcion != null) ...[
                      Text(s.descripcion!),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'ID: ${s.id} • ${s.totalValoraciones} valoracion${s.totalValoraciones != 1 ? 'es' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Icon(Icons.location_on, color: color, size: 36),
              if (s.valoracionMedia != null)
                Positioned(
                  top: 2,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.yellow, 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.valoracionMedia!.toStringAsFixed(1),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _getFilterDescription() {
    if (_filterValue.isEmpty) return '';
    
    switch (_filterType) {
      case FilterType.nombre:
        return 'nombre contiene "$_filterValue"';
      case FilterType.valoracion:
        final rating = double.tryParse(_filterValue);
        return rating != null ? 'valoración ≥ $rating ⭐' : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<InteractiveMapProvider>(context);
    final filteredSpots = _filterSpots(mapProvider.spots);
    final baseMarkers = _spotsToMarkers(filteredSpots);
    final markers = [...baseMarkers, ..._createdMarkers];
    
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            mapController: _mapController,
            markers: markers,
            onTap: _handleTap,
            onLongPress: _handleLongPress,
            tileProvider: widget.tileProvider,
            urlTemplate: widget.urlTemplate,
          ),
          LoadingOverlay(isLoading: mapProvider.isLoading),
          ErrorBanner(errorMessage: mapProvider.errorMessage),
          FilterWidget(
            onFilterChanged: _onFilterChanged,
            onClear: _onFilterClear,
          ),
          ZoomControls(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
          LocationButton(onPressed: _moveToCurrentLocation),
          if (_filterValue.isNotEmpty)
            Positioned(
              top: 106,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${filteredSpots.length} spot${filteredSpots.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getFilterDescription(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}