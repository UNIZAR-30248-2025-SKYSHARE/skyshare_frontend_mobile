import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/constellation_info_panel.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/providers/star_chart_provider.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/background_star_3d.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/star_field_painter.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/data/tutorial_data.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/domain/tutorial_state.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/presentation/tutorial_overlay.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class StarChartContent extends StatefulWidget {
  final StarChartProvider starChartProvider;
  final bool startTutorial;

  const StarChartContent({
    super.key,
    required this.starChartProvider,
    this.startTutorial = false,
  });

  @override
  State<StarChartContent> createState() => _StarChartContentState();
}

class _StarChartContentState extends State<StarChartContent> {
  final List<StreamSubscription<dynamic>> _subs = [];
  vm.Quaternion _deviceOrientation = vm.Quaternion.identity();
  Map<String, dynamic>? _selectedObject;
  final Map<String, Offset> _projectionCache = {};
  final int _frameCount = 0;
  static const int _calculationFrameInterval = 3;
  final List<BackgroundStar3D> _backgroundStars = [];
  static const int _backgroundStarCount = 200;
  double? _initialHeading;
  int _lastGyroTs = 0;
  bool _compassReady = false;

  final TutorialState _tutorialState = TutorialState();
  List<Map<String, dynamic>> _tutorialBodies = [];

  @override
  void initState() {
    super.initState();
    _generateBackgroundStars();
    _waitForFirstCompassReading();
    if (widget.startTutorial) {
      _tutorialState.reset();
    }
    _tutorialState.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(StarChartContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.starChartProvider != widget.starChartProvider) {
      if (!_tutorialState.isActive) {
        _selectedObject = null;
        _projectionCache.clear();
      }
    }
  }

  void _waitForFirstCompassReading() {
    FlutterCompass.events?.first.then((event) {
      if (!mounted) return;
      setState(() {
        _initialHeading = event.heading ?? 0.0;
        _compassReady = true; 
        _tutorialBodies = TutorialData.getMockCelestialBodies(_initialHeading!);
      });
      _initSensors();
    });
  }

  void _initSensors() {
    _subs.add(gyroscopeEventStream().listen(_onGyro));
  }

  void _onGyro(GyroscopeEvent g) {
    if (_initialHeading == null) return;
    final now = g.timestamp.microsecondsSinceEpoch;
    if (_lastGyroTs == 0) {
      _lastGyroTs = now;
      return;
    }
    final dt = (now - _lastGyroTs) / 1e6;
    _lastGyroTs = now;
    final w = vm.Vector3(g.x, -g.y, g.z);
    final angle = w.length * dt;
    if (angle < 1e-9) return;
    final axis = w.normalized();
    final dq = vm.Quaternion.axisAngle(axis, angle);
    setState(() {
      _deviceOrientation = (dq * _deviceOrientation).normalized();
    });
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _projectionCache.clear();
    _tutorialState.dispose(); 
    super.dispose();
  }

  void _generateBackgroundStars() {
    final random = math.Random(42);
    for (int i = 0; i < _backgroundStarCount; i++) {
      final theta = random.nextDouble() * 2 * math.pi;
      final phi = math.acos(2 * random.nextDouble() - 1);
      final alt = (math.pi / 2 - phi) * 180 / math.pi;
      final az = theta * 180 / math.pi;
      final size = 0.3 + random.nextDouble() * 1.5;
      final brightness = 0.2 + random.nextDouble() * 0.6;
      final twinkleSpeed = 0.5 + random.nextDouble() * 2.0;
      _backgroundStars.add(BackgroundStar3D(
        az: az,
        alt: alt,
        size: size,
        brightness: brightness,
        twinkleSpeed: twinkleSpeed,
        baseBrightness: brightness,
      ));
    }
  }

  void _onStarTapped(Map<String, dynamic> object) {
    setState(() => _selectedObject = object);
  }

  double _correctAz(double rawAz) {
    if (_initialHeading == null) return rawAz;
    return (rawAz - _initialHeading!) % 360;
  }

  List<Map<String, double>> _generateConstellationPattern(String name, double azDeg, double altDeg) {
    final seed = name.hashCode;
    final random = math.Random(seed);
    final starCount = 4 + (seed.abs() % 3);
    final pattern = <Map<String, double>>[];
    pattern.add({'az': azDeg, 'alt': altDeg, 'mag': 1.5, 'isMain': 1.0});
    for (int i = 1; i < starCount; i++) {
      final azOffset = (random.nextDouble() - 0.5) * 45;
      final altOffset = (random.nextDouble() - 0.5) * 45;
      final mag = 2.5 + random.nextDouble() * 2.0;
      pattern.add({'az': azDeg + azOffset, 'alt': altDeg + altOffset, 'mag': mag, 'isMain': 0.0});
    }
    return pattern;
  }

  @override
  Widget build(BuildContext context) {
    final bool showTutorial = _tutorialState.isActive;
    
    final stars = showTutorial ? _tutorialBodies : widget.starChartProvider.visibleBodies;
    
    final isLoading = showTutorial 
        ? !_compassReady 
        : (widget.starChartProvider.isLoading || !_compassReady);

    return LayoutBuilder(builder: (context, cons) {
      final size = Size(cons.maxWidth, cons.maxHeight);
      
      bool isTutorialTargetVisible = false;
      if (showTutorial && _compassReady) {
        isTutorialTargetVisible = _checkTargetVisibility(size, stars);
      }

      return Stack(
        children: [
          Container(color: Colors.black),
          
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final tapPosition = details.localPosition;
              final center = Offset(size.width / 2, size.height / 2);
              final rot = _deviceOrientation.asRotationMatrix();
              _findTappedStar(tapPosition, center, rot, stars);
            },
            child: CustomPaint(
              size: size,
              painter: StarFieldPainter(
                deviceOrientation: _deviceOrientation,
                stars: stars,
                backgroundStars: _backgroundStars,
                selectedObject: _selectedObject,
                frameCount: _frameCount,
                calculationFrameInterval: _calculationFrameInterval,
                projectionCache: _projectionCache,
                initialHeading: _initialHeading,
              ),
            ),
          ),
          
          if (isLoading) _buildLoadingOverlay(context),
          
          if (_selectedObject != null)
            ConstellationInfoPanel(
              object: _selectedObject!,
              onClose: () => setState(() => _selectedObject = null),
            ),

          if (showTutorial && !isLoading)
            TutorialOverlay(
              currentStep: _tutorialState.currentStep,
              isTargetVisible: isTutorialTargetVisible,
              onNextStep: () => _tutorialState.nextStep(),
              onSkip: () => _tutorialState.completeTutorial(),
            ),
        ],
      );
    });
  }

  bool _checkTargetVisibility(Size screenSize, List<Map<String, dynamic>> stars) {
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    final rot = _deviceOrientation.asRotationMatrix();
    const double radius = 25.0; 

    for (final obj in stars) {
      if (_tutorialState.isTargetObject(obj['id'])) {
        
        final rawAzDeg = (obj['az'] as num?)?.toDouble() ?? 0.0;
        final azDeg = _correctAz(rawAzDeg); 
        final altDeg = (obj['alt'] as num?)?.toDouble() ?? 0.0;
        
        final az = azDeg * math.pi / 180.0;
        final alt = altDeg * math.pi / 180.0;

        final wx = math.cos(alt) * math.sin(az);
        final wy = -math.sin(alt);
        final wz = -math.cos(alt) * math.cos(az);

        final world = vm.Vector3(wx * radius, wy * radius, wz * radius);
        final rotated = rot * world;

        if (rotated.z >= 0) return false;

        final proj = _project(rotated, center);

        if (proj.dx > 50 && proj.dx < screenSize.width - 50 &&
            proj.dy > 100 && proj.dy < screenSize.height - 150) { 
          return true;
        }
      }
    }
    return false;
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.t('star_chart.loading') ?? 'Cargando mapa estelar...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _findTappedStar(Offset tapPosition, Offset center, vm.Matrix3 rot, List<Map<String, dynamic>> stars) {
    const double radius = 25.0;
    const double tapRadius = 40.0;
    Map<String, dynamic>? closestObject;
    double closestDistance = double.infinity;
    
    final unknown = AppLocalizations.of(context)?.t('star_chart.unknown_object') ?? 'Unknown';

    for (final obj in stars) {
      try {
        if (obj['is_visible'] != true) continue;
        
        if (obj['type'] == 'constellation') {
          final name = obj['name'] as String? ?? unknown;
          final rawAzDeg = (obj['az'] as num?)?.toDouble() ?? 0.0;
          final azDeg = _correctAz(rawAzDeg);
          final altDeg = (obj['alt'] as num?)?.toDouble() ?? 0.0;
          final pattern = _generateConstellationPattern(name, azDeg, altDeg);
          
          for (final star in pattern) {
            final starAz = star['az']!;
            final starAlt = star['alt']!;
            
            final az = starAz * math.pi / 180.0;
            final alt = starAlt * math.pi / 180.0;
            
            final wx = math.cos(alt) * math.sin(az);
            final wy = -math.sin(alt);
            final wz = -math.cos(alt) * math.cos(az);
            
            final world = vm.Vector3(wx * radius, wy * radius, wz * radius);
            final rotated = rot * world;
            
            if (rotated.z >= 0) continue;
            
            final proj = _project(rotated, center);
            final distance = (proj - tapPosition).distance;

            if (distance < tapRadius && distance < closestDistance) {
              closestDistance = distance;
              closestObject = obj;
            }
          }
        } else {
          final rawAzDeg = (obj['az'] as num?)?.toDouble() ?? 0.0;
          final azDeg = _correctAz(rawAzDeg);
          final altDeg = (obj['alt'] as num?)?.toDouble() ?? 0.0;

          final az = azDeg * math.pi / 180.0;
          final alt = altDeg * math.pi / 180.0;
          
          final wx = math.cos(alt) * math.sin(az);
          final wy = -math.sin(alt);
          final wz = -math.cos(alt) * math.cos(az);
          
          final world = vm.Vector3(wx * radius, wy * radius, wz * radius);
          final rotated = rot * world;
          
          if (rotated.z >= 0) continue;
          
          final proj = _project(rotated, center);
          final distance = (proj - tapPosition).distance;

          if (distance < tapRadius && distance < closestDistance) {
            closestDistance = distance;
            closestObject = obj;
          }
        }
      } catch (e) {
        debugPrint('Error finding tapped star: $e');
      }
    }
    
    if (closestObject != null) {
      _onStarTapped(closestObject);
    } else {
      setState(() => _selectedObject = null);
    }
  }

  Offset _project(vm.Vector3 p, Offset center) {
    const eps = 0.0001;
    const focal = 200.0;
    final z = p.z.abs() < eps ? (p.z < 0 ? -eps : eps) : p.z;
    return Offset(
      center.dx + (p.x / -z) * focal,
      center.dy + (p.y / -z) * focal,
    );
  }

  @visibleForTesting
  Map<String, dynamic>? getSelectedObjectForTest(_StarChartContentState state) =>
      state._selectedObject;
}