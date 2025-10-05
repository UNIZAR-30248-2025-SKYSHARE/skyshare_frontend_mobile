import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/light_pollution_repository.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/location_repository.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/visible_sky_repository.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/repositories/weather_repository.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skyshare_frontend_mobile/core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await SupabaseService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherRepository = WeatherRepository();
    final visibleSkyRepository = VisibleSkyRepository();
    final lightPollutionRepository = LightPollutionRepository();
    final locationRepository = LocationRepository();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            weatherRepository: weatherRepository,
            visibleSkyRepository: visibleSkyRepository,
            lightPollutionRepository: lightPollutionRepository,
            locationRepository: locationRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Star Observation App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0A0E27),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}