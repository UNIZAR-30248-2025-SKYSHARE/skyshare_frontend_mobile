import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../data/repositories/my_profile_repository.dart';
import '../data/repositories/follows_repository.dart';
import 'widgets/profile_header_widget.dart';
import 'widgets/profile_stats_widget.dart';
import 'widgets/info_card_widget.dart';
import 'followers_screen.dart';
import 'spots_screen.dart';
import 'discover_new_users_screen.dart';
import '../../../../features/auth/data/repositories/auth_repository.dart';
import '../../../../features/interactive_map/data/repositories/spot_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/star_background.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final MyProfileRepository? profileRepository;
  final FollowsRepository? followsRepository;
  final SpotRepository? spotRepository;

  const ProfileScreen({super.key, this.userId, this.profileRepository, this.followsRepository, this.spotRepository});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

Future<void> _signOut(BuildContext context) async {
  try {
    final client = Supabase.instance.client;
    final authRepo = AuthRepository(client: client);

    await authRepo.signOut();

    if (context.mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (route) => false);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error signing out: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final MyProfileRepository _repository;
  late final FollowsRepository _followsRepo;

  AppUser? _user;
  AppUser? _currentUser;
  bool _isLoading = true;
  bool _isMyProfile = false;
  bool _isFollowing = false;
  int _followers = 0;
  int _following = 0;
  int _spots = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.profileRepository ?? MyProfileRepository();
    _followsRepo = widget.followsRepository ?? FollowsRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final currentUser = await _repository.getCurrentUserProfile();
    _currentUser = currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final viewedUserId = widget.userId ?? currentUser.id;
    _isMyProfile = (viewedUserId == currentUser.id);

    final user = await _repository.getUserProfileById(viewedUserId);
    if (user != null) {
      final data = await _repository.getFollowersData(viewedUserId);
      final spots = await _repository.getSpotsCount(viewedUserId);

      if (!_isMyProfile) {
        _isFollowing =
            await _followsRepo.isFollowing(currentUser.id, viewedUserId);
      }

      setState(() {
        _user = user;
        _followers = data['followers'] ?? 0;
        _following = data['following'] ?? 0;
        _spots = spots;
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _toggleFollow() async {
    if (_currentUser == null || _user == null) return;

    final followerId = _currentUser!.id;
    final followedId = _user!.id;

    if (_isFollowing) {
      await _followsRepo.unfollowUser(followerId, followedId);
      setState(() {
        _isFollowing = false;
        _followers--;
      });
    } else {
      await _followsRepo.followUser(followerId, followedId);
      setState(() {
        _isFollowing = true;
        _followers++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Could not load profile')),
      );
    }

    return StarBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            _isMyProfile
                ? 'My Profile'
                : '${_user!.username ?? ''}\'s Profile',
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ProfileHeader(user: _user!),
                const SizedBox(height: 25),

                if (!_isMyProfile) ...[
                  ElevatedButton.icon(
                    key: const Key('followButton'),
                    onPressed: _toggleFollow,
                    icon: Icon(_isFollowing ? Icons.check : Icons.person_add),
                    label: Text(_isFollowing ? 'Following' : 'Follow'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFollowing ? Colors.grey.shade300 : Colors.green,
                      foregroundColor:
                          _isFollowing ? Colors.black87 : Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],

                ProfileStats(
                  spots: _spots,
                  followers: _followers,
                  following: _following,
                  onFollowersTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FollowersScreen(
                          userId: _user!.id,
                          showFollowers: true,
                          followsRepository:  FollowsRepository(),
                          profileRepository: MyProfileRepository()
                        ),
                      ),
                    );
                  },
                  onFollowingTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FollowersScreen(
                          userId: _user!.id,
                          showFollowers: false,
                          followsRepository:  FollowsRepository(),
                          profileRepository: MyProfileRepository()
                        ),
                      ),
                    );
                  },
                  onSpotsTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpotsScreen(
                          userId: _user!.id,
                          spotRepository: SpotRepository()
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                InfoCard(user: _user!),
                const SizedBox(height: 20),

                if (_isMyProfile) ...[
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiscoverUsersScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Discover Users'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

