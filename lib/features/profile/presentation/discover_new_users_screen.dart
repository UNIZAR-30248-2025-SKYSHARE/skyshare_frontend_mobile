import 'package:flutter/material.dart';
import 'widgets/user_search_list_widget.dart'; 
import '../../../core/widgets/star_background.dart';
import '../../profile/data/repositories/follows_repository.dart';
import '../../profile/data/repositories/my_profile_repository.dart';

class DiscoverUsersScreen extends StatelessWidget {
  const DiscoverUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instancias reales de repositorios
    final followsRepository = FollowsRepository();
    final profileRepository = MyProfileRepository();

    return StarBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Discover Users"),
          centerTitle: true,
        ),
        body: UserSearchList(
          followsRepository: followsRepository,
          profileRepository: profileRepository,
        ),
      ),
    );
  }
}
