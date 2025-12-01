import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/photo_profile_widget.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class ProfileHeader extends StatelessWidget {
  final AppUser user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        PhotoProfileWidget(
          photoUrl: user.photoUrl,
          radius: 60,
        ),
        const SizedBox(height: 16),
        Text(
          user.username ?? (loc?.t('profile.no_name') ?? 'No name'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.email ?? (loc?.t('profile.no_email') ?? 'No email'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}