// screens/alert_form_screen.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/star_background.dart';
import '../data/model/alert_model.dart';
import '../providers/alert_provider.dart';
import '../../../core/services/location_service.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/location_repository.dart' as dashboard_location;
import 'widgets/alert_form_field.dart';
import 'widgets/alert_dropdown.dart';
import 'widgets/alert_toggle.dart';
import 'widgets/alert_chip_selector.dart';
import 'widgets/alert_common_fields.dart';

class AlertFormScreen extends StatefulWidget {
  final String alertType;
  final AlertModel? existingAlert;

  const AlertFormScreen({
    super.key,
    required this.alertType,
    this.existingAlert,
  });

  @override
  State<AlertFormScreen> createState() => _AlertFormScreenState();
}

class _AlertFormScreenState extends State<AlertFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  String _repetitionType = 'UNICA';
  bool _isActive = true;
  late String _currentType;

  String? _lunarPhase;
  String? _weatherMetric;
  String? _starEventType;
  final TextEditingController _valorMinController = TextEditingController();
  final TextEditingController _valorMaxController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentType = widget.existingAlert?.tipoAlerta ?? widget.alertType;
    _loadExistingData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _valorMinController.dispose();
    _valorMaxController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    if (widget.existingAlert != null) {
      final alert = widget.existingAlert!;
      _nameController.text = alert.parametroObjetivo ?? '';
      _repetitionType = alert.tipoRepeticion;
      _isActive = alert.activa;
      _currentType = alert.tipoAlerta;

      final date = alert.fechaObjetivo;
      _dateController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

      if (alert.horaObjetivo != null) {
        _timeController.text = alert.horaObjetivo!;
      }

      _loadSpecificParameters();
    }
  }

  void _loadSpecificParameters() {
    final alert = widget.existingAlert;
    if (alert == null) return;
    
    final tipo = alert.tipoAlerta;
    if (tipo == 'fase lunar') {
      _lunarPhase = alert.parametroObjetivo;
    } else if (tipo == 'meteorologica') {
      _weatherMetric = alert.parametroObjetivo ?? 'Nubosidad';
      if (alert.valorMinimo != null) {
        _valorMinController.text = alert.valorMinimo.toString();
      }
      if (alert.valorMaximo != null) {
        _valorMaxController.text = alert.valorMaximo.toString();
      }
    } else if (tipo == 'estrellas') {
      _starEventType = alert.parametroObjetivo;
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }
    return DateTime.now();
  }

  String? _getSpecificParameterValue() {
    switch (_currentType) {
      case 'fase lunar':
        return _lunarPhase;
      case 'meteorologica':
        return _weatherMetric;
      case 'estrellas':
        return _starEventType;
      default:
        return _nameController.text.isNotEmpty ? _nameController.text : null;
    }
  }

  bool _validateForm() {
    // Validar campos específicos según tipo
    if (_currentType == 'fase lunar' && _lunarPhase == null) {
      _showError('Por favor selecciona una fase lunar');
      return false;
    }
    
    if (_currentType == 'meteorologica') {
      if (_weatherMetric == null) {
        _showError('Por favor selecciona un parámetro meteorológico');
        return false;
      }
    }
    
    if (_currentType == 'estrellas' && _starEventType == null) {
      _showError('Por favor selecciona una constelación');
      return false;
    }

    if (_dateController.text.isEmpty) {
      _showError('Por favor selecciona una fecha');
      return false;
    }

    return _formKey.currentState?.validate() ?? false;
  }

  AlertModel _createAlertData({required int idUbicacion}) {
    final parametroObjetivo = _currentType == 'meteorologica'
        ? _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : _getSpecificParameterValue()
        : _getSpecificParameterValue() ?? _nameController.text.trim();
    
    double? minV;
    double? maxV;
    if (_currentType == 'meteorologica') {
      if (_valorMinController.text.isNotEmpty) {
        minV = double.tryParse(_valorMinController.text);
      }
      if (_valorMaxController.text.isNotEmpty) {
        maxV = double.tryParse(_valorMaxController.text);
      }
    }

    return AlertModel(
      idAlerta: widget.existingAlert?.idAlerta ?? 0,
      idUsuario: widget.existingAlert?.idUsuario ?? 'user123',
      idUbicacion: idUbicacion, // ✅ Usar ID en vez de nombre
      tipoAlerta: _currentType,
      parametroObjetivo: parametroObjetivo,
      tipoRepeticion: _repetitionType,
      fechaObjetivo: _dateController.text.isNotEmpty 
          ? _parseDate(_dateController.text) 
          : DateTime.now(),
      horaObjetivo: _timeController.text.isNotEmpty ? _timeController.text : null,
      activa: _isActive,
      valorMinimo: minV,
      valorMaximo: maxV,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveAlert() async {
    if (_isSaving) return;

    if (!_validateForm()) {
      return;
    }

    setState(() => _isSaving = true);

    final provider = Provider.of<AlertProvider>(context, listen: false);

    try {
      
      int idUbicacion = 1; // Fallback por defecto
      
      if (widget.existingAlert != null) {
        idUbicacion = widget.existingAlert!.idUbicacion;
      } else {
        try {
          final loc = await LocationService.instance.getCurrentLocation()
              .timeout(const Duration(seconds: 8));
          
          final locRepo = Provider.of<dashboard_location.LocationRepository>(context, listen: false);

          try {
            final existing = await locRepo.findLocationByName(loc.city, loc.country);
            if (existing != null) {
              idUbicacion = existing.id;
            } else {
              final created = await locRepo.createLocation(
                latitude: loc.latitude,
                longitude: loc.longitude,
                name: loc.city,
                country: loc.country,
              );

              if (created != null) {
                idUbicacion = created.id;
                await locRepo.createUserLocationAssociation(userId: null, locationId: idUbicacion);
              }
            }
          } catch (e) {
            if (kDebugMode) print('Error al resolver/crear ubicación: $e');
          }
          
        } catch (e) {
          if (kDebugMode) print('Error obteniendo ubicación, usando fallback: $e');
        }
      }

      final alertData = _createAlertData(idUbicacion: idUbicacion);
      
      if (widget.existingAlert != null) {
        if (kDebugMode) print('DEBUG Form: Actualizando alerta...');
        await provider.updateAlert(widget.existingAlert!.idAlerta, alertData)
            .timeout(const Duration(seconds: 10));
        
        if (mounted) {
          if (kDebugMode) print('DEBUG Form: Alerta actualizada exitosamente');
          _showSuccess('Alerta actualizada correctamente');
          Navigator.of(context).pop(true);
        }
      } else {
        if (kDebugMode) print('DEBUG Form: Creando nueva alerta...');
        await provider.addAlert(alertData)
            .timeout(const Duration(seconds: 10));
        
        if (mounted) {
          if (kDebugMode) print('DEBUG Form: Alerta creada exitosamente');
          _showSuccess('Alerta creada correctamente');
          Navigator.of(context).pop(true);
        }
      }
    } on TimeoutException catch (e) {
      if (kDebugMode) print('ERROR Form: Timeout - $e');
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('La operación tardó demasiado. Verifica tu conexión a internet.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Error al guardar: ${e.toString()}');
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1a1a2e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      setState(() {
        _dateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1a1a2e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      setState(() {
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildLunarFields() {
    return Column(
      children: [
        AlertFormField(
          label: 'FASE LUNAR',
          child: AlertDropdown<String>(
            hintText: 'Seleccionar fase lunar',
            value: _lunarPhase,
            items: const [
              DropdownMenuItem(value: 'Luna Nueva', child: Text('Luna Nueva')),
              DropdownMenuItem(value: 'Cuarto Creciente', child: Text('Cuarto Creciente')),
              DropdownMenuItem(value: 'Luna Llena', child: Text('Luna Llena')),
              DropdownMenuItem(value: 'Cuarto Menguante', child: Text('Cuarto Menguante')),
            ],
            onChanged: (value) {
              setState(() {
                _lunarPhase = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherFields() {
    String? validateValue(String? v, String metric) {
      if (v == null || v.isEmpty) return null;
      final parsed = double.tryParse(v);
      if (parsed == null) return 'Introduce un número válido';
      if (metric == 'Nubosidad') {
        if (parsed < 0 || parsed > 100) return 'Rango 0-100';
      } else if (metric == 'Contaminación lumínica') {
        if (parsed < 0 || parsed > 9) return 'Rango 0-9';
      } else if (metric == 'Indicador del cielo') {
        if (parsed < 0 || parsed > 6) return 'Rango 0-6';
      }
      return null;
    }

    final metric = _weatherMetric ?? 'Nubosidad';

    return Column(
      children: [
        AlertChipSelector(
          label: 'PARÁMETRO METEOROLÓGICO',
          options: const ['Nubosidad', 'Contaminación lumínica', 'Indicador del cielo'],
          selectedValue: metric,
          onChanged: (value) {
            setState(() {
              _weatherMetric = value;
            });
          },
        ),
        AlertFormField(
          label: 'VALOR MÍNIMO',
          child: TextFormField(
            controller: _valorMinController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Valor mínimo (opcional)',
              hintStyle: const TextStyle(color: Colors.white54),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6C63FF)),
              ),
            ),
            validator: (v) => validateValue(v, metric),
          ),
        ),
        AlertFormField(
          label: 'VALOR MÁXIMO',
          child: TextFormField(
            controller: _valorMaxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Valor máximo (opcional)',
              hintStyle: const TextStyle(color: Colors.white54),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6C63FF)),
              ),
            ),
            validator: (v) => validateValue(v, metric),
          ),
        ),
      ],
    );
  }

  Widget _buildStarsFields() {
    return Column(
      children: [
        AlertFormField(
          label: 'CONSTELACIÓN',
          child: AlertDropdown<String>(
            hintText: 'Seleccionar constelación',
            value: _starEventType,
            items: const [
              DropdownMenuItem(value: 'Virgo', child: Text('Virgo')),
              DropdownMenuItem(value: 'Libra', child: Text('Libra')),
              DropdownMenuItem(value: 'Vela', child: Text('Vela')),
              DropdownMenuItem(value: 'Gemini', child: Text('Gemini')),
              DropdownMenuItem(value: 'Aquarius', child: Text('Aquarius')),
              DropdownMenuItem(value: 'Taurus', child: Text('Taurus')),
              DropdownMenuItem(value: 'Pisces', child: Text('Pisces')),
              DropdownMenuItem(value: 'Capricornius', child: Text('Capricornius')),
            ],
            onChanged: (value) {
              setState(() {
                _starEventType = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (_currentType) {
      case 'fase lunar':
        return _buildLunarFields();
      case 'meteorologica':
        return _buildWeatherFields();
      case 'estrellas':
        return _buildStarsFields();
      default:
        return const SizedBox();
    }
  }

  String _getAlertTypeTitle() {
    switch (_currentType) {
      case 'fase lunar': return 'LUNAR';
      case 'meteorologica': return 'METEOROLÓGICA';
      case 'estrellas': return 'DE ESTRELLAS';
      default: return _currentType.toUpperCase();
    }
  }

  String _getExampleName() {
    switch (_currentType) {
      case 'fase lunar': return 'Próxima Luna Llena';
      case 'meteorologica': return 'Tormenta en Barcelona';
      case 'estrellas': return 'Perseidas 2024';
      default: return 'Mi Alerta';
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'Eliminar Alerta',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta alerta? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              setState(() => _isSaving = true);
              
              try {
                await Provider.of<AlertProvider>(context, listen: false)
                    .deleteAlert(widget.existingAlert!.idAlerta);
                
                if (mounted) {
                  _showSuccess('Alerta eliminada correctamente');
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isSaving = false);
                  _showError('Error al eliminar la alerta: $e');
                }
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAlert != null;
    
    return StarBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '${isEditing ? 'EDITAR' : 'CREAR'} ALERTA ${_getAlertTypeTitle()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Selector de tipo de alerta (sin "evento")
                      AlertFormField(
                        label: 'TIPO DE ALERTA',
                        child: AlertDropdown<String>(
                          hintText: 'Seleccionar tipo',
                          value: _currentType,
                          items: const [
                            DropdownMenuItem(value: 'estrellas', child: Text('Estrellas')),
                            DropdownMenuItem(value: 'fase lunar', child: Text('Fase lunar')),
                            DropdownMenuItem(value: 'meteorologica', child: Text('Meteorológica')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _currentType = value ?? _currentType;
                              // Limpiar campos específicos al cambiar tipo
                              _lunarPhase = null;
                              _weatherMetric = null;
                              _starEventType = null;
                              _valorMinController.clear();
                              _valorMaxController.clear();
                            });
                          },
                        ),
                      ),

                      // Campos comunes
                      AlertCommonFields(
                        nameController: _nameController,
                        dateController: _dateController,
                        timeController: _timeController,
                        onSelectDate: _selectDate,
                        onSelectTime: _selectTime,
                        exampleNameGetter: _getExampleName,
                      ),

                      // Campos específicos del tipo
                      _buildTypeSpecificFields(),
                      
                      // Repetición
                      AlertFormField(
                        label: 'FRECUENCIA',
                        child: AlertDropdown<String>(
                          hintText: 'Seleccionar frecuencia',
                          value: _repetitionType,
                          items: const [
                            DropdownMenuItem(value: 'UNICA', child: Text('Única vez')),
                            DropdownMenuItem(value: 'DIARIA', child: Text('Diaria')),
                            DropdownMenuItem(value: 'SEMANAL', child: Text('Semanal')),
                            DropdownMenuItem(value: 'MENSUAL', child: Text('Mensual')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _repetitionType = value ?? _repetitionType;
                            });
                          },
                        ),
                      ),

                      // Activa / Inactiva
                      AlertFormField(
                        label: 'ESTADO',
                        child: AlertToggle(
                          label: 'ACTIVA',
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveAlert,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isEditing ? 'Guardar cambios' : 'Crear alerta',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          if (isEditing) const SizedBox(width: 12),
                          if (isEditing)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving ? null : _showDeleteConfirmation,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              
              // Overlay de carga
              if (_isSaving)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  }