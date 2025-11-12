import 'package:flutter/material.dart';
import '../../../../../core/i18n/app_localizations.dart';

class ProfileStats extends StatelessWidget {
  final int spots;
  final int followers;
  final int following;
  final VoidCallback? onSpotsTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  const ProfileStats({
    super.key,
    required this.spots,
    required this.followers,
    required this.following,
    this.onSpotsTap,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    Widget buildStat(String labelKey, int value, VoidCallback? onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                localizations.t(labelKey),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildStat('profile.stats.spots', spots, onSpotsTap),
          buildStat('profile.stats.followers', followers, onFollowersTap),
          buildStat('profile.stats.following', following, onFollowingTap),
        ],
      ),
    );
  }
}