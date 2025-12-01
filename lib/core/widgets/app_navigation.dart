import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart'; 

typedef NavTapCallback = void Function(int index);
typedef LocationSelectCallback = void Function(int locationIndex);

class AppNavigation extends StatelessWidget {
  final int selectedIndex;
  final NavTapCallback onTap;
  final int locationCount;
  final int selectedLocationIndex;
  final LocationSelectCallback? onLocationSelected;

  const AppNavigation({
    required this.selectedIndex,
    required this.onTap,
    required this.locationCount,
    this.selectedLocationIndex = 0,
    this.onLocationSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF131422), Color(0xFF161426)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(top: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.03), width: 1)),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 6),
              Expanded(
                child: Center(
                  child: IconButton(
                    onPressed: () => onTap(0),
                    icon: Icon(Icons.dashboard, color: selectedIndex == 0 ? Colors.white : Colors.white70),
                    tooltip: loc?.t('nav.dashboard') ?? 'Dashboard',
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: IconButton(
                    onPressed: () => onTap(1),
                    icon: Icon(Icons.nights_stay, color: selectedIndex == 1 ? Colors.white : Colors.white70),
                    tooltip: loc?.t('nav.night_sky') ?? 'Night Sky',
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: IconButton(
                    onPressed: () => onTap(2),
                    icon: Icon(Icons.notifications, color: selectedIndex == 2 ? Colors.white : Colors.white70),
                    tooltip: loc?.t('nav.alerts') ?? 'Alerts',
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: IconButton(
                    onPressed: () => onTap(3),
                    icon: Icon(Icons.map, color: selectedIndex == 3 ? Colors.white : Colors.white70),
                    tooltip: loc?.t('nav.map') ?? 'Map',
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: IconButton(
                    onPressed: () => onTap(4),
                    icon: Icon(Icons.group, color: selectedIndex == 4 ? Colors.white : Colors.white70),
                    tooltip: loc?.t('nav.chats') ?? 'Chats',
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: IconButton(
                    onPressed: () => onTap(5),
                    icon: Icon(Icons.person, color: selectedIndex == 5 ? Colors.white : Colors.white70),
                    tooltip: loc?.t('nav.profile') ?? 'Profile',
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}