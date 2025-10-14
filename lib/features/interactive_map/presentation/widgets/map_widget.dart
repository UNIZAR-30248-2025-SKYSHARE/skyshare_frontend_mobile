import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/interactive_map_provider.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final List<Marker> markers;
  final Function(TapPosition, LatLng) onTap;
  final Function(TapPosition, LatLng) onLongPress;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.markers,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<InteractiveMapProvider>(context);
    final hasLocation = mapProvider.currentPosition != null;

    final userMarker = hasLocation
        ? Marker(
            point: mapProvider.currentPosition!,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.my_location,
              color: Colors.blueAccent,
              size: 35,
            ),
          )
        : null;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: hasLocation ? mapProvider.currentPosition : const LatLng(40.4168, -3.7038),
        zoom: hasLocation ? 14.5 : 6.0,
        minZoom: 1.0,
        maxZoom: 18.0,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.miapp',
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