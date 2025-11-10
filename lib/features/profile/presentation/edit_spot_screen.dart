import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../interactive_map/data/models/spot_model.dart';
import '../../interactive_map/data/repositories/spot_repository.dart';

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final ok = await _repo.updateSpot(
      spotId: widget.spot.id,
      nombre: _nameCtrl.text.trim(),
      descripcion: _descriptionCtrl.text.trim(),
      nuevaImagen: _newImage,
    );

    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spot updated successfully ✅')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating the spot ❌')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Spot")),
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
                decoration: const InputDecoration(labelText: 'Spot Name'),
                validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveChanges,
                  icon: const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save Changes'),
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
