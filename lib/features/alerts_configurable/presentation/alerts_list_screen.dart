import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/star_background.dart';
import '../providers/alert_provider.dart';
import 'widgets/alert_card_widget.dart';
import 'widgets/empty_alerts_widget.dart';
import 'widgets/alerts_header_widget.dart';
import 'widgets/alert_style.dart';
import 'alert_form_screen.dart';
import 'widgets/alert_error_widget.dart';
import 'widgets/delete_alert_dialog.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<AlertProvider>(context, listen: false);
      provider.loadAlerts();
    });
  }

  void _handleAlertTap(dynamic alert) {
    final typeStr = (alert?.tipoAlerta ?? 'estrellas').toString().toLowerCase();
    final provider = Provider.of<AlertProvider>(context, listen: false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AlertFormScreen(
          alertType: typeStr,
          existingAlert: alert,
        ),
      ),
    ).then((result) {
      if (result == true) {
        provider.loadAlerts();
      }
    });
  }

  void _handleDeleteAlert(int alertId) {
    final provider = Provider.of<AlertProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => DeleteAlertDialog(
        onConfirm: () async {
          Navigator.of(context).pop();
          
          try {
            await provider.deleteAlert(alertId);
            if (mounted) {
              _showSuccessMessage('Alert deleted successfully');
            }
          } catch (e) {
            if (mounted) {
              _showErrorMessage('Error deleting alert');
            }
          }
        },
      ),
    );
  }

  void _handleCreateAlert() {
    final provider = Provider.of<AlertProvider>(context, listen: false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AlertFormScreen(alertType: 'estrellas'),
      ),
    ).then((result) {
      if (result == true) {
        provider.loadAlerts();
      }
    });
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StarBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Consumer<AlertProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const _LoadingWidget();
            }

            if (provider.error != null) {
              return AlertErrorWidget(
                error: provider.error!,
                onRetry: provider.loadAlerts,
              );
            }

            if (provider.alerts.isEmpty) {
              return const EmptyAlertsWidget();
            }

            return _buildAlertsList(provider);
          },
        ),
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'My Alerts',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            final provider = Provider.of<AlertProvider>(context, listen: false);
            provider.loadAlerts();
          },
          tooltip: 'Reload alerts',
        ),
      ],
    );
  }

  Widget _buildAlertsList(AlertProvider provider) {
    return Column(
      children: [
        AlertsHeaderWidget(
          totalAlerts: provider.alerts.length,
          activeAlerts: provider.activeAlertsCount,
        ),
        Expanded(
          child: _AlertsListView(
            alerts: provider.alerts,
            onAlertTap: _handleAlertTap,
            onToggle: (alertId, value) async {
              try {
                await provider.toggleAlert(alertId, value);
                if (mounted) {
                  _showSuccessMessage(
                    value ? 'Alert activated' : 'Alert deactivated'
                  );
                }
              } catch (e) {
                if (mounted) {
                  _showErrorMessage('Error changing alert status');
                }
              }
            },
            onDelete: _handleDeleteAlert,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      heroTag: null,
      onPressed: _handleCreateAlert,
      backgroundColor: kAlertAccent,
      tooltip: 'Nueva alerta',
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }
}

class _AlertsListView extends StatelessWidget {
  final List<dynamic> alerts;
  final Function(dynamic) onAlertTap;
  final Function(int, bool) onToggle;
  final Function(int) onDelete;

  const _AlertsListView({
    required this.alerts,
    required this.onAlertTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final provider = Provider.of<AlertProvider>(context, listen: false);
        await provider.loadAlerts();
      },
      color: kAlertAccent,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
  separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return AlertCardWidget(
            alert: alert,
            onTap: () => onAlertTap(alert),
            onToggle: (value) => onToggle(alert.idAlerta, value),
            onDelete: () => onDelete(alert.idAlerta),
          );
        },
      ),
    );
  }
}