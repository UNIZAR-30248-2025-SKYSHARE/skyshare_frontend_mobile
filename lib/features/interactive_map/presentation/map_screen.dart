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

  @override
  void initState() {
    super.initState();
    // Al iniciar, obtenemos la ubicación del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InteractiveMapProvider>(context, listen: false)
          .fetchUserLocation();
    });
  }

  /// Muestra un diálogo al hacer tap en el mapa para crear un nuevo spot
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

  /// Navega a la pantalla de creación de spot y agrega el marcador si se confirma
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

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<InteractiveMapProvider>(context);

    final initialCenter = mapProvider.currentPosition ?? LatLng(40.4168, -3.7038);
    final hasLocation = mapProvider.currentPosition != null;

    // Marcador azul para la ubicación del usuario
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
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: hasLocation ? 14.0 : 6.0,
              minZoom: 1.0,
              maxZoom: 18.0,
              keepAlive: true,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  if (userMarker != null) userMarker,
                  ..._markers,
                ],
              ),
            ],
          ),

          // Indicador de carga
          if (mapProvider.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Error de ubicación
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

          // Botón flotante para centrar el mapa en la ubicación del usuario
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                mapProvider.fetchUserLocation();
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla para crear un nuevo Spot con imagen, nombre y descripción
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
              // Selector de imagen circular
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

              // Campo nombre
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

              // Campo descripción
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

              // Información de ubicación
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

              // Botón guardar
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
