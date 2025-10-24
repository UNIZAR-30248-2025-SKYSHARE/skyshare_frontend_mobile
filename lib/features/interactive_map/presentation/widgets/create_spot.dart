import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/repositories/spot_repository.dart'; // Asegúrate de la ruta correcta
import 'package:supabase_flutter/supabase_flutter.dart';

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
  XFile? _imagen; // Cambiado a XFile
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final SpotRepository _repo = SpotRepository();

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
                  setState(() => _imagen = foto);
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
                  setState(() => _imagen = foto);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarSpot() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, añade una foto')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
                  if (user == null) {
                    // Manejar usuario no logueado
                    return;
                  }

    try {
      final exito = await _repo.insertSpot(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        ciudad: 'Desconocida', 
        pais: 'Desconocido',   
        lat: widget.position.latitude,
        lng: widget.position.longitude,
        imagen: _imagen!,
        creadorId: user.id,
      );

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spot creado correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el spot')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Spot'),
        backgroundColor: Colors.grey[900],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                                child: kIsWeb
                                    ? Image.network(
                                        _imagen!.path,
                                        fit: BoxFit.cover,
                                        width: 200,
                                        height: 200,
                                      )
                                    : Image.file(
                                        File(_imagen!.path),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lat: ${widget.position.latitude.toStringAsFixed(5)}',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lng: ${widget.position.longitude.toStringAsFixed(5)}',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _guardarSpot,
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
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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
