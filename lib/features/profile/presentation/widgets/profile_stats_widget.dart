import 'package:flutter/material.dart';

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

    Widget buildStat(String label, int value, VoidCallback? onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              '$value',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black,
              ),
            ),
          ],
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildStat('Spots', spots, onSpotsTap),
          buildStat('Followers', followers, onFollowersTap),
          buildStat('Following', following, onFollowingTap),
        ],
      ),
    );
  }
}
