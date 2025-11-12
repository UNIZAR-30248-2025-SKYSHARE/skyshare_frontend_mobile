import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../interactive_map/data/models/spot_model.dart';
import '../../interactive_map/data/repositories/spot_repository.dart';
import '../../interactive_map/presentation/spot_detail_screen.dart';
import 'edit_spot_screen.dart';
import '../../../core/widgets/star_background.dart';
import '../../../core/i18n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(localizations.t('spot.edit.delete_dialog_title')),
        content: Text(localizations.t('spot.edit.delete_dialog_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.t('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.t('spot.delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _spotRepository.deleteSpot(int.parse(idSpot));

        if (!mounted) return; // ✅ Verifica que el widget siga en el árbol

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.t('spot.edit.deleted_success'))),
        );

        _loadSpots(); 
      } catch (e) {
        if (!mounted) return; 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.t('spot.edit.deleted_error', {'err': e.toString()})
            ),
          ),
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
    final localizations = AppLocalizations.of(context)!;
    final bool isMySpots = _currentUserId == widget.userId;
    
    final String title = isMySpots 
      ? localizations.t('spot.list.my_spots_title')
      : localizations.t('spot.list.user_spots_title');

    return StarBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _spots.isEmpty
                ? Center(
                    child: Text(
                      isMySpots
                          ? localizations.t('spot.list.no_my_spots')
                          : localizations.t('spot.list.no_user_spots'),
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
                            subtitle: Text(spot.descripcion ?? localizations.t('spot.no_description')),
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
                                          tooltip: localizations.t('spot.list.edit_tooltip'),
                                          onPressed: () => _editSpot(spot),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          tooltip: localizations.t('spot.list.delete_tooltip'),
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