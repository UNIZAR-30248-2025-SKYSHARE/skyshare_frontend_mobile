import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/repositories/spot_repository.dart';
import '../../data/repositories/location_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skyshare_frontend_mobile/core/widgets/star_background.dart';

class CreateSpotScreen extends StatefulWidget {
  final LatLng position;
  final SpotRepository spotRepository;
  final LocationRepository locationRepository;
  final ImagePicker imagePicker;
  final GoTrueClient authClient;

  const CreateSpotScreen({
    super.key,
    required this.position,
    required this.spotRepository,
    required this.locationRepository,
    required this.imagePicker,
    required this.authClient,
  });

  @override
  State<CreateSpotScreen> createState() => _CreateSpotScreenState();
}

class _CreateSpotScreenState extends State<CreateSpotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  XFile? _imagen;
  bool _isLoading = false;

  SpotRepository get _repo => widget.spotRepository;
  LocationRepository get _locationRepo => widget.locationRepository;
  ImagePicker get _picker => widget.imagePicker;
  GoTrueClient get _authClient => widget.authClient;

  Future<void> _seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)?.t('spot.create.camera') ?? 'Camera'),
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
              title: Text(AppLocalizations.of(context)?.t('spot.create.gallery') ?? 'Gallery'),
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
        SnackBar(content: Text(AppLocalizations.of(context)?.t('spot.create.add_photo') ?? 'Por favor, añade una foto')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = _authClient.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.t('spot.create.not_authenticated') ?? 'Error: Usuario no autenticado')),
      );
      setState(() => _isLoading = false);
      return;
    }

    Map<String, String> datosLocalizacion =
        await _locationRepo.getCityCountryFromCoordinates(
      widget.position.latitude,
      widget.position.longitude,
    );

    if (!mounted) return;

    try {
      final exito = await _repo.insertSpot(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        ciudad: datosLocalizacion['city'] ?? 'Desconocida',
        pais: datosLocalizacion['country'] ?? 'Desconocido',
        lat: widget.position.latitude,
        lng: widget.position.longitude,
        imagen: _imagen!,
        creadorId: user.id,
      );

      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.t('spot.create.created_success') ?? 'Spot creado correctamente')),
        );

        Navigator.pop(context, {
          'nombre': _nombreController.text,
          'lat': widget.position.latitude,
          'lng': widget.position.longitude,
          'imagen': _imagen,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.t('spot.create.create_error') ?? 'Error al crear el spot')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((AppLocalizations.of(context)?.t('spot.create.error_prefix') ?? 'Error: {err}').replaceAll('{err}', e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StarBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 96, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _seleccionarImagen,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.grey, Colors.grey.shade700],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: Colors.grey.shade600, width: 2.5),
                              ),
                              child: ClipOval(
                                child: _imagen == null
                                    ? const SizedBox.shrink()
                                    : (kIsWeb
                                        ? Image.network(
                                            _imagen!.path,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_imagen!.path),
                                            fit: BoxFit.cover,
                                          )),
                              ),
                            ),
                            if (_imagen == null)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.image, size: 46, color: Colors.grey.shade400),
                                  const SizedBox(height: 6),
                                  Text(AppLocalizations.of(context)?.t('spot.create.add_photo_short') ?? 'Add photo',
                                    style: TextStyle(color: Colors.grey.shade400)),
                                ],
                              ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6F00FF),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _nombreController,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)?.t('spot.name') ?? 'Name of the spot',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withAlpha((0.03 * 255).round()),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                      ),
                      validator: (value) =>
                        value == null || value.trim().isEmpty ? (AppLocalizations.of(context)?.t('spot.name_required') ?? 'El nombre es obligatorio') : null,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descripcionController,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)?.t('spot.description') ?? 'Description',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withAlpha((0.03 * 255).round()),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                      ),
                      maxLines: 5,
                      validator: (value) => value == null || value.trim().isEmpty
                        ? (AppLocalizations.of(context)?.t('spot.description_required') ?? 'La descripción es obligatoria')
                        : null,
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.03 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lat: ${widget.position.latitude.toStringAsFixed(5)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lng: ${widget.position.longitude.toStringAsFixed(5)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardarSpot,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6F00FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.t('spot.save_changes_caps') ?? 'SAVE CHANGES',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
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