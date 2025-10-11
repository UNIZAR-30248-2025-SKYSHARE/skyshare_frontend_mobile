import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/interactive_map_provider.dart';

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

  void _handleTap(TapPosition tapPosition, LatLng position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Spot'),
        content: const Text('¿Quieres crear un spot en esta ubicación?\n\n'),
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

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<InteractiveMapProvider>(context);
    final hasLocation = mapProvider.currentPosition != null;

    final userMarker = hasLocation
        ? Marker(
            point: mapProvider.currentPosition!,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.my_location,
              color: Colors.blueAccent,
              size: 35,
            ),
          )
        : null;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: hasLocation ? mapProvider.currentPosition : LatLng(40.4168, -3.7038),
              zoom: hasLocation ? 14.5 : 6.0,
              minZoom: 1.0,
              maxZoom: 18.0,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.miapp',
              ),
              MarkerLayer(
                markers: [
                  if (userMarker != null) userMarker,
                  ..._markers,
                ],
              ),
            ],
          ),

          if (mapProvider.isLoading)
            const Center(child: CircularProgressIndicator()),

          if (mapProvider.errorMessage != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.red[700],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    mapProvider.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 90,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  mini: true,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  mini: true,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                if (mapProvider.currentPosition != null) {
                  _mapController.move(mapProvider.currentPosition!, 14.5);
                } else {
                  mapProvider.fetchUserLocation();
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateSpotScreen extends StatefulWidget {
  final LatLng position;

  const CreateSpotScreen({super.key, required this.position});

  @override
  State<CreateSpotScreen> createState() => _CreateSpotScreenState();
}

class _CreateSpotScreenState extends State<CreateSpotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  File? _imagen;
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? foto = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1920,
                  maxHeight: 1080,
                  imageQuality: 85,
                );
                if (foto != null) {
                  setState(() => _imagen = File(foto.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? foto = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1920,
                  maxHeight: 1080,
                  imageQuality: 85,
                );
                if (foto != null) {
                  setState(() => _imagen = File(foto.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _guardarSpot() {
    if (_formKey.currentState!.validate()) {
      if (_imagen == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, añade una foto')),
        );
        return;
      }

      Navigator.pop(context, {
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'imagen': _imagen!.path,
        'position': widget.position,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Spot'),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _seleccionarImagen,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[600]!,
                        width: 3,
                      ),
                    ),
                    child: _imagen == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Añadir foto',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : ClipOval(
                            child: Image.file(
                              _imagen!,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del spot *',
                  hintText: 'Ej: Mirador del Pico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción *',
                  hintText: 'Describe este lugar...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lat: ${widget.position.latitude.toStringAsFixed(5)}\n'
                        'Lng: ${widget.position.longitude.toStringAsFixed(5)}',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _guardarSpot,
                icon: const Icon(Icons.save),
                label: const Text('Crear Spot'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}
