import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
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
      _showSnackbar(AppLocalizations.of(context)?.t('spot.name_required') ?? 'El nombre no puede estar vacío.', Colors.red);
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
        _showSnackbar(AppLocalizations.of(context)?.t('spot.updated_success') ?? 'Spot actualizado correctamente!', Colors.green);
      } else {
        _showSnackbar(AppLocalizations.of(context)?.t('spot.update_error') ?? 'Error al actualizar el spot.', Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackbar((AppLocalizations.of(context)?.t('spot.save_error') ?? 'Error al guardar cambios: {err}').replaceAll('{err}', e.toString()), Colors.red);
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
    Navigator.pop(context); 

    showDialog(
      context: context,
      builder: (confirmContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.t('spot.confirm_delete') ?? 'Confirmar Eliminación'),
          content: Text(AppLocalizations.of(context)?.t('spot.confirm_delete_content') ?? '¿Estás seguro de que quieres eliminar este spot de forma permanente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmContext),
              child: Text(AppLocalizations.of(context)?.t('cancel') ?? 'Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(confirmContext);
                await _handleDelete();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)?.t('spot.delete') ?? 'Eliminar', style: const TextStyle(color: Colors.white)),
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
  title: Text(AppLocalizations.of(context)?.t('spot.edit_spot') ?? 'Editar Spot', style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.t('spot.name') ?? 'Nombre', labelStyle: const TextStyle(color: Colors.white70)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.t('spot.description') ?? 'Descripción', labelStyle: const TextStyle(color: Colors.white70)),
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)?.t('spot.image_label') ?? 'Imagen:', style: const TextStyle(color: Colors.white70)),
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
            TextButton.icon(
              icon: const Icon(Icons.photo, color: Colors.blue),
              label: Text(_pickedFile != null ? (AppLocalizations.of(context)?.t('spot.change_image') ?? 'Cambiar imagen') : (AppLocalizations.of(context)?.t('spot.select_new_image') ?? 'Seleccionar nueva imagen'), style: const TextStyle(color: Colors.blue)),
              onPressed: _pickImage,
            ),
            const Divider(color: Colors.white30),
            const SizedBox(height: 10),
            TextButton.icon(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: Text(AppLocalizations.of(context)?.t('spot.delete_spot_permanent') ?? 'Eliminar Spot (Permanente)', style: const TextStyle(color: Colors.red)),
              onPressed: _confirmDelete,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)?.t('cancel') ?? 'Cancelar', style: const TextStyle(color: Colors.white70)),
        ),
        FilledButton(
          onPressed: _handleSaveEdit,
          child: Text(AppLocalizations.of(context)?.t('spot.save_changes') ?? 'Guardar Cambios'),
        ),
      ],
    );
  }
}