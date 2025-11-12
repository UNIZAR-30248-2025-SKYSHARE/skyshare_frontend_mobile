import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../interactive_map/data/models/spot_model.dart';
import '../../interactive_map/data/repositories/spot_repository.dart';
import '../../../core/i18n/app_localizations.dart';

class EditSpotScreen extends StatefulWidget {
  final Spot spot;

  const EditSpotScreen({super.key, required this.spot});

  @override
  State<EditSpotScreen> createState() => _EditSpotScreenState();
}

class _EditSpotScreenState extends State<EditSpotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = SpotRepository();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _descriptionCtrl;

  XFile? _newImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.spot.nombre);
    _descriptionCtrl = TextEditingController(text: widget.spot.descripcion);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = picked);
    }
  }

  Future<void> _saveChanges() async {
    final localizations = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final ok = await _repo.updateSpot(
      spotId: widget.spot.id,
      nombre: _nameCtrl.text.trim(),
      descripcion: _descriptionCtrl.text.trim(),
      nuevaImagen: _newImage,
    );

      if (!mounted) return;
      setState(() => _saving = false);

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.t('spot.edit.success_update'))),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.t('spot.edit.error_update'))),
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.t('spot.edit.title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _newImage != null
                          ? (kIsWeb
                              ? Image.network(_newImage!.path,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover)
                              : Image.file(File(_newImage!.path),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover))
                          : (widget.spot.urlImagen != null
                              ? Image.network(widget.spot.urlImagen!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover)
                              : Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.camera_alt, size: 60),
                                )),
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black26,
                      ),
                      child: const Center(
                        child: Icon(Icons.edit, color: Colors.white, size: 50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: localizations.t('spot.edit.name_label')),
                validator: (v) => v!.isEmpty ? localizations.t('spot.edit.name_required') : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: InputDecoration(labelText: localizations.t('spot.edit.description_label')),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveChanges,
                  icon: const Icon(Icons.save),
                  label: Text(_saving 
                    ? localizations.t('spot.edit.saving') 
                    : localizations.t('spot.save_changes')
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}