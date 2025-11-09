import 'package:flutter/material.dart';
import '../../../../../core/models/user_model.dart';
import '../../data/repositories/my_profile_repository.dart';
import '../../data/repositories/follows_repository.dart';
import '../profile_screen.dart';

class UserSearchList extends StatefulWidget {
  final FollowsRepository followsRepository;
  final MyProfileRepository profileRepository;

  const UserSearchList({
    super.key,
    required this.followsRepository,
    required this.profileRepository,
  });

  @override
  State<UserSearchList> createState() => _UserSearchListState();
}

class _UserSearchListState extends State<UserSearchList> {
  late final FollowsRepository _repository;
  late final MyProfileRepository _profileRepository;

  List<AppUser> _users = [];
  List<AppUser> _filteredUsers = [];
  String? _currentUserId;
  bool _loading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _repository = widget.followsRepository;
    _profileRepository = widget.profileRepository;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);

    final currentUser = await _profileRepository.getCurrentUserProfile();
    _currentUserId = currentUser?.id;

    final all = await _repository.getAllUsers();
    _users = _currentUserId != null
        ? all.where((u) => u.id != _currentUserId).toList()
        : all;

    _filteredUsers = _users;
    setState(() => _loading = false);
  }

  void _filterUsers(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredUsers = _users
          .where((u) => (u.username ?? "").toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  Future<void> _toggleFollow(AppUser user) async {
    if (_currentUserId == null || user.id == _currentUserId) return;

    final isFollowing = await _repository.isFollowing(_currentUserId!, user.id);

    if (isFollowing) {
      await _repository.unfollowUser(_currentUserId!, user.id);
    } else {
      await _repository.followUser(_currentUserId!, user.id);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: TextField(
            onChanged: _filterUsers,
            decoration: InputDecoration(
              hintText: 'Search users by name…',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadUsers,
            child: _loading
                ? ListView.builder(
                    itemCount: 6,
                    itemBuilder: (_, _) => _buildLoadingCard(),
                  )
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("No users found"),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(14),
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (_, i) {
                          final user = _filteredUsers[i];
                          return FutureBuilder<bool>(
                            future: _currentUserId == null
                                ? Future.value(false)
                                : _repository.isFollowing(_currentUserId!, user.id),
                            builder: (ctx, snapshot) {
                              final following = snapshot.data ?? false;
                              return _userCard(user, following);
                            },
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _userCard(AppUser user, bool following) {
    final isOwnProfile = _currentUserId == user.id;

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
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
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
                    user.username ?? "User",
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000080)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? "",
                    style: const TextStyle(color: Colors.black87),
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
                child: Text(following ? "Following" : "Follow"),
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
