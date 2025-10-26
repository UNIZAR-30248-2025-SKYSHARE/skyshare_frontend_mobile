import 'package:flutter/material.dart';
import '../../data/model/alert_model.dart';
import 'alert_info_row_widget.dart';
import 'alert_footer_widget.dart';
import 'alert_style.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/location_repository.dart'
    as dashboard_location;

/// Card that displays a single alert with a human-friendly location name.
class AlertCardWidget extends StatefulWidget {
  final AlertModel alert;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

  const AlertCardWidget({
    super.key,
    required this.alert,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  State<AlertCardWidget> createState() => _AlertCardWidgetState();
}

class _AlertCardWidgetState extends State<AlertCardWidget> {
  String? _locationName;
  bool _isLoadingLocation = false;

  String _getAlertTitle() => widget.alert.parametroObjetivo ?? 'Alerta';

  String _getRepetitionText() {
    final tipo = (widget.alert.tipoRepeticion ?? '').toUpperCase();
    switch (tipo) {
      case 'DIARIA':
        return 'Todos los días';
      case 'SEMANAL':
        return 'Cada semana';
      case 'MENSUAL':
        return 'Cada mes';
      case 'UNICA':
      default:
        return 'Una vez';
    }
  }

  Color _getCardColor() {
    if (widget.alert.activa == false) {
      return kAlertAccent.withOpacity(0.04);
    }
    return kAlertAccent.withOpacity(0.12);
  }

  Future<void> _resolveLocationName(int? idUbicacion) async {
    if (idUbicacion == null || _isLoadingLocation) return;
    
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final repo = dashboard_location.LocationRepository();
      final loc = await repo.fetchLocationById(idUbicacion);
      if (mounted) {
        setState(() {
          _locationName = loc?.name; // Cambiado de 'nombre' a 'name'
          _isLoadingLocation = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _resolveLocationName(widget.alert.idUbicacion);
  }

  @override
  void didUpdateWidget(AlertCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alert.idUbicacion != widget.alert.idUbicacion) {
      _resolveLocationName(widget.alert.idUbicacion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.alert.activa ?? false;
    final repetition = _getRepetitionText();
    
    String subtitleText;
    if (_isLoadingLocation) {
      subtitleText = 'Cargando ubicación... • $repetition';
    } else if (_locationName != null && _locationName!.isNotEmpty) {
      subtitleText = '$_locationName • $repetition';
    } else {
      subtitleText = 'Ubicación #${widget.alert.idUbicacion ?? '-'} • $repetition';
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AlertInfoRowWidget(
                icon: CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      isActive ? kAlertAccent.withOpacity(0.18) : Colors.transparent,
                  child: Icon(
                    widget.alert.tipoAlerta == 'fase lunar'
                        ? Icons.brightness_2
                        : widget.alert.tipoAlerta == 'meteorologica'
                            ? Icons.cloud
                            : widget.alert.tipoAlerta == 'estrellas'
                                ? Icons.star
                                : Icons.notifications,
                    size: 28,
                    color: () {
                      if (widget.alert.tipoAlerta == 'fase lunar') return Colors.white;
                      if (widget.alert.tipoAlerta == 'meteorologica') return Colors.yellow.shade600;
                      if (widget.alert.tipoAlerta == 'estrellas') return kAlertAccent;
                      return isActive ? kAlertAccent : Colors.grey;
                    }(),
                  ),
                ),
                title: _getAlertTitle(),
                subtitle: subtitleText, // Cambiado de subtitleWidget a subtitle
                isActive: isActive,
                switchValue: isActive,
                onSwitchChanged: widget.onToggle ?? (bool value) {}, // Convertido a no-nullable
              ),
              const SizedBox(height: 12),
              AlertFooterWidget(
                date: widget.alert.fechaObjetivo,
                isActive: isActive,
                onDelete: widget.onDelete ?? () {}, // Convertido a no-nullable
              ),
            ],
          ),
        ),
      ),
    );
  }
}