import 'package:flutter/material.dart';
import 'widgets/user_search_list_widget.dart';
import '../../../core/widgets/star_background.dart';
import '../../profile/data/repositories/follows_repository.dart';
import '../../profile/data/repositories/my_profile_repository.dart';
import '../../../core/i18n/app_localizations.dart';

class DiscoverUsersScreen extends StatelessWidget {
  final FollowsRepository? followsRepository;
  final MyProfileRepository? profileRepository;

  const DiscoverUsersScreen({
    super.key,
    this.followsRepository,
    this.profileRepository,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return StarBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.t('profile.discover_screen.title')),
          centerTitle: true,
        ),
        body: UserSearchList(
          followsRepository: followsRepository ?? FollowsRepository(),
          profileRepository: profileRepository ?? MyProfileRepository(),
        ),
      ),
    );
  }
}