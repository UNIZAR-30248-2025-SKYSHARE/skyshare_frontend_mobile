// widgets/alert_form_screen.dart (updated)
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
    _dateController.dispose();
    _timeController.dispose();
    _valorMinController.dispose();
    _valorMaxController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    if (widget.existingAlert != null) {
      final alert = widget.existingAlert!;
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
      // Default metric now in English if not present
      _weatherMetric = alert.parametroObjetivo ?? 'Cloudiness';
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
        return null;
    }
  }

  bool _validateForm() {
    // Validate specific fields per type
    if (_currentType == 'fase lunar' && _lunarPhase == null) {
      _showError('Please select a lunar phase');
      return false;
    }
    
    if (_currentType == 'meteorologica') {
      if (_weatherMetric == null) {
        _showError('Please select a weather parameter');
        return false;
      }
    }
    
    if (_currentType == 'estrellas' && _starEventType == null) {
      _showError('Please select a constellation or event');
      return false;
    }

    if (_dateController.text.isEmpty) {
      _showError('Please select a date');
      return false;
    }

    return _formKey.currentState?.validate() ?? false;
  }

  AlertModel _createAlertData({required int idUbicacion}) {
    // Alert name is auto-generated from the selected parameter.
    final parametroObjetivo = _getSpecificParameterValue();
    
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
      idUbicacion: idUbicacion,
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
  // Capture repositories/providers that will be used after awaits to avoid
  // using BuildContext across async gaps.
  final locRepo = Provider.of<dashboard_location.LocationRepository>(context, listen: false);

    try {
      
      int idUbicacion = 1; // default fallback
      
      if (widget.existingAlert != null) {
        idUbicacion = widget.existingAlert!.idUbicacion;
      } else {
        try {
          final loc = await LocationService.instance.getCurrentLocation()
              .timeout(const Duration(seconds: 8));

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
            if (kDebugMode) print('Error resolving/creating location: $e');
          }
          
        } catch (e) {
          if (kDebugMode) print('Error getting location, using fallback: $e');
        }
      }

      final alertData = _createAlertData(idUbicacion: idUbicacion);
      
      if (widget.existingAlert != null) {
        if (kDebugMode) print('DEBUG Form: Updating alert...');
        await provider.updateAlert(widget.existingAlert!.idAlerta, alertData)
            .timeout(const Duration(seconds: 10));
        
        if (mounted) {
          if (kDebugMode) print('DEBUG Form: Alert updated successfully');
          _showSuccess('Alert updated successfully');
          Navigator.of(context).pop(true);
        }
      } else {
        if (kDebugMode) print('DEBUG Form: Creating new alert...');
        await provider.addAlert(alertData)
            .timeout(const Duration(seconds: 10));
        
        if (mounted) {
          if (kDebugMode) print('DEBUG Form: Alert created successfully');
          _showSuccess('Alert created successfully');
          Navigator.of(context).pop(true);
        }
      }
    } on TimeoutException catch (e) {
      if (kDebugMode) print('ERROR Form: Timeout - $e');
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('The operation timed out. Check your internet connection.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Error saving: ${e.toString()}');
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
          label: 'LUNAR PHASE',
          child: AlertDropdown<String>(
            hintText: 'Select lunar phase',
            value: _lunarPhase,
            items: const [
              DropdownMenuItem(value: 'New Moon', child: Text('New Moon')),
              DropdownMenuItem(value: 'First Quarter', child: Text('First Quarter')),
              DropdownMenuItem(value: 'Full Moon', child: Text('Full Moon')),
              DropdownMenuItem(value: 'Last Quarter', child: Text('Last Quarter')),
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
      if (parsed == null) return 'Enter a valid number';
      if (metric == 'Cloudiness') {
        if (parsed < 0 || parsed > 100) return 'Range 0-100';
      } else if (metric == 'Light pollution') {
        if (parsed < 0 || parsed > 9) return 'Range 0-9';
      } else if (metric == 'Sky indicator') {
        if (parsed < 0 || parsed > 6) return 'Range 0-6';
      }
      return null;
    }

    final metric = _weatherMetric ?? 'Cloudiness';

    return Column(
      children: [
        AlertChipSelector(
          label: 'WEATHER PARAMETER',
          options: const ['Cloudiness', 'Light pollution', 'Sky indicator'],
          selectedValue: metric,
          onChanged: (value) {
            setState(() {
              _weatherMetric = value;
            });
          },
        ),
        AlertFormField(
          label: 'MINIMUM VALUE',
          child: TextFormField(
            controller: _valorMinController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Minimum value (optional)',
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
          label: 'MAXIMUM VALUE',
          child: TextFormField(
            controller: _valorMaxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Maximum value (optional)',
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
          label: 'CONSTELLATION',
          child: AlertDropdown<String>(
            hintText: 'Select constellation',
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
      case 'meteorologica': return 'WEATHER';
      case 'estrellas': return 'STARS';
      default: return _currentType.toUpperCase();
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'Delete Alert',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this alert? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              setState(() => _isSaving = true);
              
              try {
        final provider = Provider.of<AlertProvider>(context, listen: false);
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        await provider.deleteAlert(widget.existingAlert!.idAlerta);

        if (mounted) {
          messenger.showSnackBar(const SnackBar(
            content: Text('Alert deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ));
          navigator.pop(true);
        }
              } catch (e) {
                if (mounted) {
                  setState(() => _isSaving = false);
                  _showError('Error deleting alert: $e');
                }
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
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
            '${isEditing ? 'EDIT' : 'CREATE'} ALERT ${_getAlertTypeTitle()}',
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
                      // Alert type selector
                      AlertFormField(
                        label: 'ALERT TYPE',
                        child: AlertDropdown<String>(
                          hintText: 'Select type',
                          value: _currentType,
                          items: const [
                            DropdownMenuItem(value: 'estrellas', child: Text('Stars')),
                            DropdownMenuItem(value: 'fase lunar', child: Text('Lunar phase')),
                            DropdownMenuItem(value: 'meteorologica', child: Text('Weather')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _currentType = value ?? _currentType;
                              // Clear type-specific fields on change
                              _lunarPhase = null;
                              _weatherMetric = null;
                              _starEventType = null;
                              _valorMinController.clear();
                              _valorMaxController.clear();
                            });
                          },
                        ),
                      ),

                      // Common fields (NOTE: name field removed - see comment below)
                      AlertCommonFields(
                        dateController: _dateController,
                        timeController: _timeController,
                        onSelectDate: _selectDate,
                        onSelectTime: _selectTime,
                      ),

                      // Type-specific fields
                      _buildTypeSpecificFields(),
                      
                      // Repetition
                      AlertFormField(
                        label: 'FREQUENCY',
                        child: AlertDropdown<String>(
                          hintText: 'Select frequency',
                          value: _repetitionType,
                          items: const [
                            DropdownMenuItem(value: 'UNICA', child: Text('Once')),
                            DropdownMenuItem(value: 'DIARIA', child: Text('Daily')),
                            DropdownMenuItem(value: 'SEMANAL', child: Text('Weekly')),
                            DropdownMenuItem(value: 'MENSUAL', child: Text('Monthly')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _repetitionType = value ?? _repetitionType;
                            });
                          },
                        ),
                      ),

                      // Active / Inactive
                      AlertFormField(
                        label: 'STATUS',
                        child: AlertToggle(
                          label: 'ACTIVE',
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action buttons
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
                                      isEditing ? 'Save changes' : 'Create alert',
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
                                  'Delete',
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
              
              // Loading overlay
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
