import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../data/repositories/follows_repository.dart';
import '../data/repositories/my_profile_repository.dart';
import 'profile_screen.dart';
import '../../../core/widgets/star_background.dart';
import '../../../core/i18n/app_localizations.dart';


class FollowersScreen extends StatefulWidget {
  final String userId;
  final bool showFollowers; // true = followers, false = following
  final FollowsRepository followsRepository;
  final MyProfileRepository profileRepository;

  const FollowersScreen({
    super.key,
    required this.userId,
    this.showFollowers = true,
    required this.followsRepository,
    required this.profileRepository,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  late final FollowsRepository _followsRepository;
  late final MyProfileRepository _profileRepository;

  List<AppUser> _users = [];
  String? _currentUserId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _followsRepository = widget.followsRepository;
    _profileRepository = widget.profileRepository;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);

    final currentUser = await _profileRepository.getCurrentUserProfile();
    _currentUserId = currentUser?.id;

    final result = widget.showFollowers
        ? await _followsRepository.getUsuariosSeguidores(widget.userId) 
        : await _followsRepository.getUsuariosSeguidos(widget.userId);

    _users = result;

    setState(() => _loading = false);
  }

  Future<void> _toggleFollow(AppUser user) async {
    // Forzamos un rebuild para actualizar el estado del botón en la lista
    await _loadUsers(); 
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    final String title = widget.showFollowers 
      ? localizations.t('profile.followers_screen.title') 
      : localizations.t('profile.following_screen.title');

    return StarBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),
        body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: _loading
            ? ListView.builder(
                // Esto es solo un placeholder, no necesita i18n
                itemCount: 6,
                itemBuilder: (_, _) => _buildLoadingCard(),
              )
            : _users.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        widget.showFollowers
                            ? localizations.t('profile.followers_screen.empty')
                            : localizations.t('profile.following_screen.empty'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemCount: _users.length,
                    itemBuilder: (_, i) {
                      final user = _users[i];
                      
                      // Si el ID de usuario actual es nulo o si es el perfil propio, no necesitamos FutureBuilder
                      if (_currentUserId == null || user.id == _currentUserId) {
                        return _userCard(user, false, isOwnProfile: true);
                      }
                      
                      return FutureBuilder<bool>(
                        future: _followsRepository.isFollowing(
                          _currentUserId!,
                          user.id,
                        ),
                        builder: (ctx, snapshot) {
                          final following = snapshot.data ?? false;
                          return _userCard(user, following);
                        },
                      );
                    },
                  ),
        ),
      ),
    );
  }

  Widget _userCard(AppUser user, bool following, {bool isOwnProfile = false}) {
    final localizations = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: user.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, size: 32)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username ?? localizations.t('profile.info.unknown'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: const TextStyle(color: Color.fromARGB(255, 44, 39, 70)),
                  ),
                ],
              ),
            ),
            if (!isOwnProfile)
              ElevatedButton(
                onPressed: () => _toggleFollow(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      following ? Colors.grey.shade300 : Colors.green,
                  foregroundColor: following ? Colors.black87 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(90, 38),
                ),
                child: Text(
                  following 
                    ? localizations.t('profile.following_button') 
                    : localizations.t('profile.follow_button')
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade200,
      ),
    );
  }
}