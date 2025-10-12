// test/interactive_map_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/providers/interactive_map_provider.dart';

void main() {
  group('InteractiveMapProvider - tests sin mocks', () {
    late InteractiveMapProvider provider;

    setUp(() {
      provider = InteractiveMapProvider();
    });

    test('Estado inicial', () {
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
      expect(provider.currentPosition, null);
      expect(provider.spotPosition, null);
      expect(provider.city, null);
      expect(provider.country, null);
    });

    test('fetchSpotLocation con LatLng válido actualiza spot y retorna city/country', () async {
      final latLng = LatLng(40.4168, -3.7038);

      // Llamamos al método
      final result = await provider.fetchSpotLocation(latLng);

      // Verificamos que la posición del spot se haya actualizado
      expect(provider.spotPosition, isNotNull);
      expect(provider.spotPosition!.latitude, latLng.latitude);
      expect(provider.spotPosition!.longitude, latLng.longitude);

      // Verificamos que se hayan asignado valores a city y country
      expect(provider.city, isNotNull);
      expect(provider.country, isNotNull);

      // Verificamos que el retorno contenga las claves city y country
      expect(result.keys, containsAll(['city', 'country']));
    });

    test('fetchSpotLocation con LatLng nulo genera error', () async {
      final result = await provider.fetchSpotLocation(null);

      expect(provider.errorMessage, isNotNull);
      expect(result['city'], 'Desconocida');
      expect(result['country'], 'Desconocido');
    });

    test('getCityCountryFromOSM devuelve ciudad y país por defecto si datos vacíos', () async {
      final result = await provider.getCityCountryFromOSM(0, 0);

      expect(result['city'], isNotNull);
      expect(result['country'], isNotNull);
    });
  });
}
