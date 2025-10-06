import 'package:flutter/material.dart';

typedef NavTapCallback = void Function(int index);
typedef LocationSelectCallback = void Function(int locationIndex);

class AppNavigation extends StatelessWidget {
  final int selectedIndex;
  final NavTapCallback onTap;
  final int locationCount;
  final int maxLocations;
  final VoidCallback onAddLocation;
  final int selectedLocationIndex;
  final LocationSelectCallback? onLocationSelected;

  const AppNavigation({
    required this.selectedIndex,
    required this.onTap,
    required this.locationCount,
    required this.onAddLocation,
    this.maxLocations = 3,
    this.selectedLocationIndex = 0,
    this.onLocationSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final showAdd = locationCount < maxLocations;
    final dotsCount = showAdd ? locationCount + 1 : locationCount;
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
              IconButton(
                onPressed: () => onTap(0),
                icon: Icon(Icons.dashboard, color: selectedIndex == 0 ? Colors.white : Colors.white70),
              ),
              IconButton(
                onPressed: () => onTap(1),
                icon: Icon(Icons.nights_stay, color: selectedIndex == 1 ? Colors.white : Colors.white70),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    dotsCount,
                    (index) {
                      if (showAdd && index == locationCount) {
                        return GestureDetector(
                          onTap: onAddLocation,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.95),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: Icon(Icons.add, size: 12, color: Colors.black)),
                          ),
                        );
                      }
                      final isActive = index == selectedLocationIndex;
                      return GestureDetector(
                        onTap: () {
                          if (onLocationSelected != null) {
                            onLocationSelected!(index);
                          }
                          onTap(0);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: isActive ? 16 : 12,
                          height: isActive ? 16 : 12,
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFFFFFFF) : const Color.fromRGBO(255, 255, 255, 0.65),
                            shape: BoxShape.circle,
                            boxShadow: isActive
                            ? [const BoxShadow(color: Color.fromRGBO(255, 255, 255, 0.12), blurRadius: 6, offset: Offset(0, 2))]
                            : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onTap(2),
                icon: Icon(Icons.map, color: selectedIndex == 2 ? Colors.white : Colors.white70),
              ),
              IconButton(
                onPressed: () => onTap(3),
                icon: Icon(Icons.person, color: selectedIndex == 3 ? Colors.white : Colors.white70),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
