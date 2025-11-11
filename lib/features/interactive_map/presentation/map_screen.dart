import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/location_repository.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/spot_repository.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/spot_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/interactive_map_provider.dart';
import './widgets/map_widget.dart';
import './widgets/loading_overlay.dart';
import './widgets/error_banner.dart';
import './widgets/zoom_controls.dart';
import './widgets/location_button.dart';
import './widgets/filter_widget.dart';
import './widgets/create_spot.dart';
import '../data/models/spot_model.dart';
import 'widgets/spot_popup_widget.dart';

class MapScreen extends StatefulWidget {
  final TileProvider? tileProvider;
  final String? urlTemplate;

  const MapScreen({
    super.key,
    this.tileProvider,
    this.urlTemplate,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  String _filterValue = '';
  FilterType _filterType = FilterType.nombre;
  Spot? _selectedSpot;
  LatLng? _selectedSpotLatLng;
  StreamSubscription? _mapSub;
  Timer? _debounce;
  Timer? _initTimer;
  final double _minLoadZoom = 10.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mapProvider = Provider.of<InteractiveMapProvider>(
        context,
        listen: false,
      );
      await mapProvider.fetchUserLocation();
      if (mapProvider.currentPosition != null) {
        _mapController.move(mapProvider.currentPosition!, 14.5);
      }
      _initTimer = Timer(const Duration(milliseconds: 500), () {
        _fetchSpotsForCurrentView();
      });
    });
    _mapSub = _mapController.mapEventStream.listen(_onMapEvent);
  }

  @override
  void dispose() {
    _mapSub?.cancel();
    _debounce?.cancel();
    _initTimer?.cancel();
    super.dispose();
  }

  void _reloadSpots() {
    _fetchSpotsForCurrentView();
  }

  void _onMapEvent(MapEvent event) {
    if (_selectedSpot != null &&
        (event is MapEventMove ||
            event is MapEventScrollWheelZoom ||
            event is MapEventFlingAnimation)) {
      setState(() {
        _selectedSpot = null;
        _selectedSpotLatLng = null;
      });
    }
    if (event is MapEventMoveEnd ||
        event is MapEventRotateEnd ||
        event is MapEventScrollWheelZoom) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _fetchSpotsForCurrentView();
      });
    }
  }

  void _fetchSpotsForCurrentView() {
    if (!mounted) return;
    final mapProvider = Provider.of<InteractiveMapProvider>(context, listen: false);
    final zoom = _mapController.camera.zoom;
    if (zoom < _minLoadZoom) {
      mapProvider.clearSpots();
      return;
    }
    try {
      final LatLngBounds bounds = _mapController.camera.visibleBounds;
      mapProvider.fetchSpots(bounds: bounds);
    } catch (_) {
      mapProvider.fetchSpots();
    }
  }

  void _handleTap(TapPosition tapPosition, LatLng position) {
    if (_selectedSpot != null) {
      setState(() {
        _selectedSpot = null;
        _selectedSpotLatLng = null;
      });
      return;
    }
    _showLocationConfirmation(position, false);
  }

  void _handleLongPress(TapPosition tapPosition, LatLng position) =>
      _showLocationConfirmation(position, true);

  void _showLocationConfirmation(LatLng position, bool isLongPress) async {
    final mapProvider = Provider.of<InteractiveMapProvider>(
      context,
      listen: false,
    );
    _showLoadingDialog();
    final result = await mapProvider.fetchSpotLocation(position);
    if (mounted) Navigator.pop(context);
    final city = result['city'] ?? 'Desconocida';
    final country = result['country'] ?? 'Desconocido';
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.t('map.create_spot') ?? 'Crear Spot'),
        content: Text((AppLocalizations.of(context)?.t('map.city_country') ?? 'Ciudad: {city}\nPaís: {country}').replaceAll('{city}', city).replaceAll('{country}', country)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.t('cancel') ?? 'Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateSpot(position);
            },
            child: Text(AppLocalizations.of(context)?.t('map.yes_create') ?? 'Sí, crear'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _navigateToCreateSpot(LatLng position) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSpotScreen(
          position: position,
          spotRepository: SpotRepository(),
          locationRepository: LocationRepository(),
          imagePicker: ImagePicker(),
          authClient: Supabase.instance.client.auth,
        ),
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((AppLocalizations.of(context)?.t('map.spot_created') ?? 'Spot "{name}" creado!').replaceAll('{name}', result['nombre'] ?? '')),
        ),
      );
      _reloadSpots();
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
    final mapProvider = Provider.of<InteractiveMapProvider>(
      context,
      listen: false,
    );
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
        return spots
            .where((spot) => spot.nombre.toLowerCase().contains(_filterValue))
            .toList();
      case FilterType.valoracion:
        final minRating = double.tryParse(_filterValue);
        if (minRating == null) return spots;
        return spots
            .where((spot) =>
                spot.valoracionMedia != null &&
                spot.valoracionMedia! >= minRating)
            .toList();
    }
  }

  Color _getMarkerColor(Spot spot) {
    if (spot.valoracionMedia == null) return Colors.grey;
    if (spot.valoracionMedia! >= 4.5) return Colors.green;
    if (spot.valoracionMedia! >= 3.5) return Colors.orange;
    return Colors.red;
  }

  List<Marker> _spotsToMarkers(List<Spot> spots) {
    return spots.map((spot) {
      final color = _getMarkerColor(spot);
      return Marker(
        point: LatLng(spot.lat, spot.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedSpot != null && _selectedSpot!.id == spot.id) {
                _selectedSpot = null;
                _selectedSpotLatLng = null;
              } else {
                _selectedSpot = spot;
                _selectedSpotLatLng = LatLng(spot.lat, spot.lng);
              }
            });
          },
          child: Stack(
            children: [
              Icon(Icons.location_on, color: color, size: 36),
              if (spot.valoracionMedia != null)
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
                      spot.valoracionMedia!.toStringAsFixed(1),
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
    final markers = baseMarkers;

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
          if (_selectedSpot != null && _selectedSpotLatLng != null)
            _buildSpotPopup(context, _selectedSpot!, _selectedSpotLatLng!),
          LoadingOverlay(isLoading: mapProvider.isLoading),
          ErrorBanner(errorMessage: mapProvider.errorMessage),
          FilterWidget(
            onFilterChanged: _onFilterChanged,
            onClear: _onFilterClear,
          ),
          ZoomControls(
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
          ),
          LocationButton(onPressed: _moveToCurrentLocation),
          if (_filterValue.isNotEmpty)
            Positioned(
              top: 106,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
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
                      '${filteredSpots.length} '
                      'spot${filteredSpots.length != 1 ? 's' : ''}',
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

  Widget _buildSpotPopup(
    BuildContext context,
    Spot spot,
    LatLng latLng,
  ) {
    const popupWidth = 260.0;
    const popupHeight = 260.0;

    double left = (MediaQuery.of(context).size.width - popupWidth) / 2;
    double top = 120.0;

    try {
      final point = _mapController.camera.latLngToScreenPoint(latLng);
      final px = point.x.toDouble();
      final py = point.y.toDouble();

      left = px - popupWidth / 2;
      top = py - popupHeight - 18;

      left = left.clamp(
        8.0,
        MediaQuery.of(context).size.width - popupWidth - 8.0,
      );
      top = top.clamp(
        8.0,
        MediaQuery.of(context).size.height - popupHeight - 120.0,
      );
    } catch (_) {}

    return Positioned(
      left: left,
      top: top,
      width: popupWidth,
      height: popupHeight + 12,
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.translucent,
        child: SpotPopupWidget(
          spot: spot,
          width: popupWidth,
          onClose: () {
            setState(() {
              _selectedSpot = null;
              _selectedSpotLatLng = null;
            });
          },
          onViewDetails: () {
            setState(() {
              _selectedSpot = null;
              _selectedSpotLatLng = null;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpotDetailScreen(spot: spot),
              ),
            );
          },
          onSpotUpdated: () {
            _reloadSpots();
            setState(() {
              _selectedSpot = null;
              _selectedSpotLatLng = null;
            });
          },
          backgroundColor: const Color(0xFF0F0E14),
        ),
      ),
    );
  }
}
