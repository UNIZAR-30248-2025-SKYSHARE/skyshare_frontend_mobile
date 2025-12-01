import 'package:flutter/material.dart';
import '../../data/model/alert_model.dart';
import 'alert_info_row_widget.dart';
import 'alert_footer_widget.dart';
import 'alert_style.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/location_repository.dart'
    as dashboard_location;

class AlertCardWidget extends StatefulWidget {
  final AlertModel alert;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

  final dashboard_location.LocationRepository? locationRepository;

  const AlertCardWidget({
    super.key,
    required this.alert,
    this.onTap,
    this.onToggle,
    this.onDelete,
    this.locationRepository,
  });

  @override
  State<AlertCardWidget> createState() => _AlertCardWidgetState();
}

class _AlertCardWidgetState extends State<AlertCardWidget> {
  String? _locationName;
  bool _isLoadingLocation = false;

  String _getAlertTitle(BuildContext context) => 
      widget.alert.parametroObjetivo ?? (AppLocalizations.of(context)?.t('alerts.form.alert') ?? 'Alert');

  String _getRepetitionText(BuildContext context) {
    final tipo = widget.alert.tipoRepeticion.toUpperCase();
    final loc = AppLocalizations.of(context);
    switch (tipo) {
      case 'DIARIA':
        return loc?.t('alerts.freq.daily') ?? 'Every day';
      case 'SEMANAL':
        return loc?.t('alerts.freq.weekly') ?? 'Every week';
      case 'MENSUAL':
        return loc?.t('alerts.freq.monthly') ?? 'Every month';
      case 'UNICA':
      default:
        return loc?.t('alerts.freq.once') ?? 'Once';
    }
  }

  Color _getCardColor() {
    if (widget.alert.activa == false) {
      return kAlertAccent.withAlpha((0.04 * 255).toInt());
    }
    return kAlertAccent.withAlpha((0.12 * 255).toInt());
  }

  Future<void> _resolveLocationName(int? idUbicacion) async {
    if (idUbicacion == null || _isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final repo =
          widget.locationRepository ?? dashboard_location.LocationRepository();
      final loc = await repo.fetchLocationById(idUbicacion);
      if (mounted) {
        setState(() {
          _locationName = loc?.name;
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
    final isActive = widget.alert.activa;
    final repetition = _getRepetitionText(context);
    final loc = AppLocalizations.of(context);

    String subtitleText;
    if (_isLoadingLocation) {
      subtitleText = '${loc?.t('alerts.location.loading') ?? 'Loading location...'} • $repetition';
    } else if (_locationName != null && _locationName!.isNotEmpty) {
      subtitleText = '$_locationName • $repetition';
    } else {
      final defaultText = loc?.t('alerts.location.default', {'id': widget.alert.idUbicacion.toString()}) 
          ?? 'Location #${widget.alert.idUbicacion}';
      subtitleText = '$defaultText • $repetition';
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.white.withAlpha((0.2 * 255).toInt())
                : Colors.grey.withAlpha((0.1 * 255).toInt()),
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
                  backgroundColor: isActive
                      ? kAlertAccent.withAlpha((0.18 * 255).toInt())
                      : Colors.transparent,
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
                      if (widget.alert.tipoAlerta == 'meteorologica') {
                        return Colors.yellow.shade600.withAlpha((0.5 * 255).toInt());
                      }
                      if (widget.alert.tipoAlerta == 'estrellas') return kAlertAccent;
                      return isActive ? kAlertAccent : Colors.grey;
                    }(),
                  ),
                ),
                title: _getAlertTitle(context),
                subtitle: subtitleText,
                isActive: isActive,
                switchValue: isActive,
                onSwitchChanged: widget.onToggle ?? (bool value) {},
              ),
              const SizedBox(height: 12),
              AlertFooterWidget(
                date: widget.alert.fechaObjetivo,
                isActive: isActive,
                onDelete: widget.onDelete ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}