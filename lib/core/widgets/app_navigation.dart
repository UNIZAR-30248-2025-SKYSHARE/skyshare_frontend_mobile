import 'package:flutter/material.dart';

typedef NavTapCallback = void Function(int index);

class AppNavigation extends StatelessWidget {
  final int selectedIndex;
  final NavTapCallback onTap;
  final int locationCount;
  final int maxLocations;
  final VoidCallback onAddLocation;

  const AppNavigation({
    required this.selectedIndex,
    required this.onTap,
    required this.locationCount,
    this.maxLocations = 3,
    required this.onAddLocation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final showAdd = locationCount < maxLocations;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF131422), Color(0xFF161426)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.03), width: 1)),
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
                icon: Icon(Icons.nights_stay, color: selectedIndex == 0 ? Colors.white : Colors.white70),
              ),
              IconButton(
                onPressed: () => onTap(1),
                icon: Icon(Icons.location_on, color: selectedIndex == 1 ? Colors.white : Colors.white70),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    showAdd ? locationCount + 1 : locationCount,
                    (index) {
                      if (showAdd && index == locationCount) {
                        return GestureDetector(
                          onTap: onAddLocation,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: Icon(Icons.add, size: 12, color: Colors.black)),
                          ),
                        );
                      }
                      final isActive = index == selectedIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: isActive ? 14 : 10,
                        height: isActive ? 14 : 10,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.65),
                          shape: BoxShape.circle,
                          boxShadow: isActive ? [BoxShadow(color: Colors.white.withOpacity(0.12), blurRadius: 6, offset: Offset(0, 2))] : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onTap(3),
                icon: Icon(Icons.group, color: selectedIndex == 3 ? Colors.white : Colors.white70),
              ),
              IconButton(
                onPressed: () => onTap(4),
                icon: Icon(Icons.person, color: selectedIndex == 4 ? Colors.white : Colors.white70),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
