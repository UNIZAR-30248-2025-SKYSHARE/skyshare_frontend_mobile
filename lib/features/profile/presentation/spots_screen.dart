import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../interactive_map/data/models/spot_model.dart';
import '../../interactive_map/data/repositories/spot_repository.dart';
import '../../interactive_map/presentation/spot_detail_screen.dart';
import 'edit_spot_screen.dart';
import '../../../core/widgets/star_background.dart';

class SpotsScreen extends StatefulWidget {
  final String userId;
  final SpotRepository spotRepository;
  final String? currentUserId;
  const SpotsScreen({super.key, required this.userId, required this.spotRepository, this.currentUserId});

  @override
  State<SpotsScreen> createState() => _SpotsScreenState();
}

class _SpotsScreenState extends State<SpotsScreen> {
  late final SpotRepository _spotRepository;
  List<Map<String, dynamic>> _spots = [];
  bool _isLoading = true;
  String? _currentUserId; 

  @override
  void initState() {
    super.initState();
        _spotRepository = widget.spotRepository;

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    setState(() {
      _currentUserId = user?.id;
    });

    await _loadSpots();
  }

  Future<void> _loadSpots() async {
    setState(() => _isLoading = true);
    final result = await _spotRepository.getSpotsByUser(widget.userId);
    setState(() {
      _spots = result;
      _isLoading = false;
    });
  }

  Future<void> _deleteSpot(String idSpot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Spot'),
        content: const Text('Are you sure you want to delete this spot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _spotRepository.deleteSpot(int.parse(idSpot));

        if (!mounted) return; // ✅ Verifica que el widget siga en el árbol

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spot successfully deleted')),
        );

        _loadSpots(); 
      } catch (e) {
        if (!mounted) return; 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting spot: $e')),
        );
      }
    }
  }

  void _editSpot(Spot spot) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditSpotScreen(spot: spot)),
    );

    if (updated == true) {
      _loadSpots(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMySpots = _currentUserId == widget.userId;

    return StarBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(isMySpots ? 'My Spots' : 'User\'s Spots'),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _spots.isEmpty
                ? Center(
                    child: Text(
                      isMySpots
                          ? 'You haven\'t posted any spots yet'
                          : 'This user hasn\'t posted any spots yet',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSpots,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _spots.length,
                      itemBuilder: (context, index) {
                        final spotMap = _spots[index];
                        final spot = Spot.fromMap(spotMap);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: (spot.urlImagen != null &&
                                    spot.urlImagen!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      spot.urlImagen!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.location_on, size: 40),
                            title: Text(spot.nombre),
                            subtitle: Text(spot.descripcion ?? 'No description'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SpotDetailScreen(spot: spot),
                                ),
                              );
                            },
                            trailing: isMySpots
                                ? Wrap(
                                    spacing: 8,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        tooltip: 'Edit',
                                        onPressed: () => _editSpot(spot),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        tooltip: 'Delete',
                                        onPressed: () =>
                                            _deleteSpot(spot.id.toString()),
                                      ),
                                    ],
                                  )
                                : null, 
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

