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
import './widgets/create_spot.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mapProvider = Provider.of<InteractiveMapProvider>(context, listen: false);
      await mapProvider.fetchUserLocation();

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
        _markers.add(
          Marker(
            point: position,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spot "${result['nombre']}" creado!')),
      );
    }
  }

  void _zoomIn() {
    final zoom = _mapController.zoom + 1;
    _mapController.move(_mapController.center, zoom);
  }

  void _zoomOut() {
    final zoom = _mapController.zoom - 1;
    _mapController.move(_mapController.center, zoom);
  }

  void _moveToCurrentLocation() {
    final mapProvider = Provider.of<InteractiveMapProvider>(context, listen: false);
    if (mapProvider.currentPosition != null) {
      _mapController.move(mapProvider.currentPosition!, 14.5);
    } else {
      mapProvider.fetchUserLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<InteractiveMapProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            mapController: _mapController,
            markers: _markers,
            onTap: _handleTap,
            onLongPress: _handleLongPress,
          ),
          LoadingOverlay(isLoading: mapProvider.isLoading),
          ErrorBanner(errorMessage: mapProvider.errorMessage),
          ZoomControls(
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
          ),
          LocationButton(onPressed: _moveToCurrentLocation),
        ],
      ),
    );
  }
}