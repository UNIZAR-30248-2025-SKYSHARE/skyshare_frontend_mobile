import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skyshare_frontend_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:skyshare_frontend_mobile/features/auth/presentation/auth_screen.dart';
import 'package:skyshare_frontend_mobile/features/auth/providers/auth_provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/phase_lunar_screen.dart';
import 'package:skyshare_frontend_mobile/features/push_notifications/services/one_signal_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/dashboard/data/repositories/weather_repository.dart';
import 'features/dashboard/data/repositories/visible_sky_repository.dart';
import 'features/dashboard/data/repositories/location_repository.dart' as location_repository_dashboard;
import 'features/phase_lunar/data/repositories/lunar_phase_repository.dart';
import 'features/phase_lunar/data/repositories/location_repository.dart' as location_repository_lunar;
import 'features/phase_lunar/providers/lunar_phase_provider.dart';
import 'features/interactive_map/data/repositories/location_repository.dart' as location_repository_map;
import 'core/services/supabase_service.dart';
import 'core/widgets/app_navigation.dart';
import 'features/interactive_map/presentation/map_screen.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/providers/interactive_map_provider.dart';
import 'features/alerts_configurable/presentation/alerts_list_screen.dart';
import 'features/alerts_configurable/providers/alert_provider.dart';
import 'features/alerts_configurable/data/repository/alerts_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await SupabaseService.instance.init();
  final supabase = SupabaseService.instance.client;

  if(!kIsWeb){ 
    await OneSignalService().init();
    await OneSignalService().requestPermission();

    final user = supabase.auth.currentUser;
    if(user != null){
      await OneSignalService().sendPlayerId(supabase, user.id);
    }
  }

  if (kDebugMode) {
    final devEmail = dotenv.env['DEV_EMAIL'];
    final devPassword = dotenv.env['DEV_PASSWORD'];
    if (devEmail != null && devPassword != null && devEmail.isNotEmpty && devPassword.isNotEmpty) {
      try {
        final response = await supabase.auth.signInWithPassword(
          email: devEmail,
          password: devPassword,
        );

        if (response.user != null) {
          final uid = response.user!.id;
          print('[DEBUG] Usuario dev autenticado: $uid');
          if (!kIsWeb) {
            print('[DEBUG] Enviando playerId a Supabase tras login dev...');
            await OneSignalService().sendPlayerId(supabase, uid);
          }
        } else {
          print('[DEBUG] No se pudo autenticar el usuario dev (respuesta sin user).');
        }
      } catch (e, st) {
        print('[DEBUG] Error al iniciar sesión en Supabase: $e\n$st');
      }
    } else {
      print('[DEBUG] DEV_EMAIL o DEV_PASSWORD no están definidas en el .env. Comprueba el fichero .env');
    }
  }
  
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
        Provider<location_repository_dashboard.LocationRepository>(
          create: (ctx) => location_repository_dashboard.LocationRepository(client: ctx.read<SupabaseClient>()),
        ),
        Provider<location_repository_lunar.LocationRepository>(
          create: (ctx) => location_repository_lunar.LocationRepository(client: ctx.read<SupabaseClient>()),
        ),
        Provider<LunarPhaseRepository>(
          create: (ctx) => LunarPhaseRepository(client: ctx.read<SupabaseClient>()),
        ),
        ChangeNotifierProvider<LunarPhaseProvider>(
          create: (ctx) => LunarPhaseProvider(
            lunarPhaseRepo: ctx.read<LunarPhaseRepository>(),
            locationRepo: ctx.read<location_repository_lunar.LocationRepository>(),
          ),
        ),
        Provider<location_repository_map.LocationRepository>(
          create: (ctx) => location_repository_map.LocationRepository(),
        ),
        Provider<AuthRepository>(
          create: (ctx) => AuthRepository(client: ctx.read<SupabaseClient>()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(authRepo: ctx.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => InteractiveMapProvider(
            locationRepository: ctx.read<location_repository_map.LocationRepository>()
          )
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (ctx) => DashboardProvider(
            weatherRepository: ctx.read<WeatherRepository>(),
            visibleSkyRepository: ctx.read<VisibleSkyRepository>(),
            locationRepository: ctx.read<location_repository_dashboard.LocationRepository>(),
          ),
        ),
        // ✅ AGREGADO: AlertRepository y AlertProvider disponibles globalmente
        Provider<AlertRepository>(
          create: (ctx) => AlertRepository(client: ctx.read<SupabaseClient>()),
        ),
        ChangeNotifierProvider<AlertProvider>(
          create: (ctx) => AlertProvider(
            repository: ctx.read<AlertRepository>(),
          )..loadAlerts(), // Cargar alertas al inicio
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
        // ✅ CAMBIADO: Ya no necesitas el Provider local, usa el global
        home: kDebugMode
            ? const AlertsListScreen()
            : const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isLoggedIn) {
      return const RootApp();
    } 
    else {
      return const AuthScreen();
    }
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

  void _onAddLocation() {}

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final locationCount = provider.savedLocations.length;
    final pages = <Widget>[
      const DashboardScreen(),                   
      const PhaseLunarScreen(),
      const MapScreen(),
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