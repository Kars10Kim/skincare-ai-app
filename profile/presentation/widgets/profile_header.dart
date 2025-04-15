import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/user_profile.dart';
import 'profile_avatar.dart';

/// Profile header widget
class ProfileHeader extends StatelessWidget {
  /// User profile
  final UserProfile profile;
  
  /// Create profile header
  const ProfileHeader({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              ProfileAvatar(profile: profile),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile.email != null) ...[
                      Text(
                        profile.email!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                    ],
                    _buildMemberSince(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProfileCompleteness(context),
        ],
      ),
    );
  }
  
  Widget _buildMemberSince() {
    if (profile.joinDate == null) return const SizedBox();
    
    final joinDateFormatted = DateFormat.yMMMd().format(profile.joinDate!);
    return Text(
      'Member since $joinDateFormatted',
      style: const TextStyle(
        fontSize: 12,
        fontStyle: FontStyle.italic,
      ),
    );
  }
  
  Widget _buildProfileCompleteness(BuildContext context) {
    // Calculate profile completeness percentage
    int totalFields = 10; // Total number of profile fields we consider
    int filledFields = 0;
    
    if (profile.name != null) filledFields++;
    if (profile.email != null) filledFields++;
    if (profile.phoneNumber != null) filledFields++;
    if (profile.profileImagePath != null) filledFields++;
    if (profile.skinType != SkinType.normal) filledFields++;
    if (profile.skinConcerns.isNotEmpty) filledFields++;
    if (profile.allergies.isNotEmpty) filledFields++;
    if (profile.preferredIngredients.isNotEmpty) filledFields++;
    if (profile.avoidedIngredients.isNotEmpty) filledFields++;
    if (profile.ageRange != null) filledFields++;
    
    final completenessPercentage = (filledFields / totalFields) * 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completeness',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${completenessPercentage.round()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completenessPercentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ],
    );
  }
}