import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/dashboard/data/repositories/weather_repository.dart';
import 'features/dashboard/data/repositories/visible_sky_repository.dart';
import 'features/dashboard/data/repositories/location_repository.dart';
import 'core/services/supabase_service.dart';
import 'core/widgets/app_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await SupabaseService.instance.init();
  final supabase = SupabaseService.instance.client;
  runApp(MyApp(supabase: supabase));
}

class MyApp extends StatelessWidget {
  final SupabaseClient supabase;

  const MyApp({required this.supabase, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SupabaseClient>.value(value: supabase),
        Provider<WeatherRepository>(
          create: (ctx) => WeatherRepository(client: ctx.read<SupabaseClient>()),
        ),
        Provider<VisibleSkyRepository>(
          create: (ctx) => VisibleSkyRepository(client: ctx.read<SupabaseClient>()),
        ),

        Provider<LocationRepository>(
          create: (ctx) => LocationRepository(client: ctx.read<SupabaseClient>()),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (ctx) => DashboardProvider(
            weatherRepository: ctx.read<WeatherRepository>(),
            visibleSkyRepository: ctx.read<VisibleSkyRepository>(),
            locationRepository: ctx.read<LocationRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Skyshare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0A0E27),
        ),
        home: const RootApp(),
      ),
    );
  }
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int _selectedIndex = 0;
  int _selectedLocationIndex = 0;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onLocationSelected(int locIndex) {
    final provider = context.read<DashboardProvider>();
    if (locIndex < provider.savedLocations.length) {
      provider.setSelectedLocation(provider.savedLocations[locIndex]);
      provider.loadDashboardData();
    }
    setState(() {
      _selectedLocationIndex = locIndex;
      _selectedIndex = 0;
    });
  }

  void _onAddLocation() {
    // flujo para añadir ubicación (temporal: no-op)
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final locationCount = provider.savedLocations.length;
    final pages = <Widget>[
      const DashboardScreen(),                   
      const Center(child: Text('Luna - placeholder')),
      const Center(child: Text('Mapa - placeholder')), 
      const Center(child: Text('Perfil - placeholder')), 
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: AppNavigation(
        selectedIndex: _selectedIndex,
        onTap: _onTap,
        locationCount: locationCount,
        onAddLocation: _onAddLocation,
        selectedLocationIndex: _selectedLocationIndex,
        onLocationSelected: _onLocationSelected,
      ),
    );
  }
}
