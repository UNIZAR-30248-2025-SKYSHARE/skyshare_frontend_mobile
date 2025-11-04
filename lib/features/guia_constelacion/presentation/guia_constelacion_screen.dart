import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/core/widgets/star_background.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/providers/guia_constelacion_provider.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/banner_constelacion.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/descripcion_constelacion.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/imagen_principal.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/pasos_observacion.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/referencia_constelacion.dart';

class GuiaConstelacionScreen extends StatefulWidget {
  final String nombreConstelacion;
  final String temporada;
  final DateTime? fecha;

  const GuiaConstelacionScreen({
    super.key,
    required this.nombreConstelacion,
    required this.temporada,
    this.fecha,
  });

  @override
  State<GuiaConstelacionScreen> createState() => _GuiaConstelacionScreenState();
}

class _GuiaConstelacionScreenState extends State<GuiaConstelacionScreen> {
  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback en lugar de Future.microtask
    // para evitar usar el BuildContext de forma insegura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<GuiaConstelacionProvider>();
      provider.fetchGuiaPorNombreYTemporada(
        nombreConstelacion: widget.nombreConstelacion,
        temporada: widget.temporada,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuiaConstelacionProvider>();
    final guia = provider.guia;

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            provider.error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (guia == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró la guía')),
      );
    }

    return Scaffold(
      body: StarBackground(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: BannerConstelacionDelegate(
                guia: guia,
                minExtent: 120,
                maxExtent: 220,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DescripcionConstelacion(guia: guia),
                    const SizedBox(height: 32),
                    ImagenPrincipal(guia: guia),
                    const SizedBox(height: 32),
                    ReferenciaConstelacion(guia: guia),
                    PasosObservacion(guia: guia),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
