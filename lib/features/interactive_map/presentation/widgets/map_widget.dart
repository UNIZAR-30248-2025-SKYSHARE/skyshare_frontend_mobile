import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/interactive_map_provider.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final List<Marker> markers;
  final void Function(TapPosition, LatLng) onTap;
  final void Function(TapPosition, LatLng) onLongPress;
  final String? urlTemplate;
  final TileProvider? tileProvider;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.markers,
    required this.onTap,
    required this.onLongPress,
    this.urlTemplate,
    this.tileProvider,
  });

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<InteractiveMapProvider>(context);
    final hasLocation = mapProvider.currentPosition != null;
    final Marker? userMarker = hasLocation
        ? Marker(
            point: mapProvider.currentPosition!,
            width: 40,
            height: 40,
            child: const Icon(Icons.my_location, color: Colors.blueAccent, size: 35),
          )
        : null;
    final defaultUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: hasLocation ? mapProvider.currentPosition! : const LatLng(40.4168, -3.7038),
        initialZoom: hasLocation ? 14.5 : 6.0,
        minZoom: 1.0,
        maxZoom: 18.0,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
      children: [
        TileLayer(
          urlTemplate: urlTemplate ?? defaultUrl,
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.miapp',
          tileProvider: tileProvider ?? NetworkTileProvider(),
        ),
        MarkerLayer(
          markers: [
            if (userMarker != null) userMarker,
            ...markers,
          ],
        ),
      ],
    );
  }
}
