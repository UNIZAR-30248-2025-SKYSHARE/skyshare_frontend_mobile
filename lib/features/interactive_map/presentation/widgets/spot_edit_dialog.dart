import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/spot_model.dart';
import '../../data/repositories/spot_repository.dart';

class SpotEditDialog extends StatefulWidget {
  final Spot spot;
  final VoidCallback onSpotUpdated;
  final SpotRepository spotRepo;

  const SpotEditDialog({
    super.key,
    required this.spot,
    required this.onSpotUpdated,
    required this.spotRepo,
  });

  @override
  State<SpotEditDialog> createState() => _SpotEditDialogState();
}

class _SpotEditDialogState extends State<SpotEditDialog> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  XFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.spot.nombre);
    _descripcionController = TextEditingController(text: widget.spot.descripcion);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _pickedFile = file;
      });
    }
  }

  Future<void> _handleSaveEdit() async {
    final newNombre = _nombreController.text.trim();
    final newDescripcion = _descripcionController.text.trim();

    if (newNombre.isEmpty) {
      _showSnackbar('El nombre no puede estar vacío.', Colors.red);
      return;
    }

    if (!mounted) return;
    Navigator.pop(context); 

    try {
      final success = await widget.spotRepo.updateSpot(
        spotId: widget.spot.id,
        nombre: newNombre,
        descripcion: newDescripcion,
        nuevaImagen: _pickedFile,
      );

      if (!mounted) return;

      if (success) {
        widget.onSpotUpdated();
        _showSnackbar('Spot actualizado correctamente!', Colors.green);
      } else {
        _showSnackbar('Error al actualizar el spot.', Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Error al guardar cambios: $e', Colors.red);
    }
  }
  
  void _showSnackbar(String message, Color color) {
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
  }

  void _confirmDelete() {
    if (!mounted) return;
    Navigator.pop(context); // Cierra el diálogo de edición

    showDialog(
      context: context,
      builder: (confirmContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este spot de forma permanente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(confirmContext);
                await _handleDelete();
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDelete() async {
     final success = await widget.spotRepo.deleteSpot(widget.spot.id);
     
     if (!mounted) return;

    if (success) {
      widget.onSpotUpdated(); 
      _showSnackbar('Spot eliminado permanentemente.', Colors.green);
    } else {
      _showSnackbar('Error al eliminar el spot.', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Editar Spot', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo Nombre
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.white70)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            // Campo Descripción
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción', labelStyle: TextStyle(color: Colors.white70)),
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Visualizador de Imagen
            const Text('Imagen:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: _pickedFile != null 
                        ? FileImage(File(_pickedFile!.path)) as ImageProvider
                        : (widget.spot.urlImagen != null && widget.spot.urlImagen!.isNotEmpty ? NetworkImage(widget.spot.urlImagen!) : const AssetImage('assets/placeholder.png')),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Botón de Seleccionar Imagen
            TextButton.icon(
              icon: const Icon(Icons.photo, color: Colors.blue),
              label: Text(_pickedFile != null ? 'Cambiar imagen' : 'Seleccionar nueva imagen', style: TextStyle(color: Colors.blue)),
              onPressed: _pickImage,
            ),
            const Divider(color: Colors.white30),
            const SizedBox(height: 10),
            // Opción de Eliminar
            TextButton.icon(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('Eliminar Spot (Permanente)', style: TextStyle(color: Colors.red)),
              onPressed: _confirmDelete,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        FilledButton(
          onPressed: _handleSaveEdit,
          child: const Text('Guardar Cambios'),
        ),
      ],
    );
  }
}