import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section.dart';
import '../widgets/skin_preferences_section.dart';
import '../widgets/account_settings_section.dart';

/// Profile screen
class ProfileScreen extends StatefulWidget {
  /// User ID
  final String userId;
  
  /// Create profile screen
  const ProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit _profileCubit;
  
  @override
  void initState() {
    super.initState();
    _profileCubit = sl<ProfileCubit>();
    _loadProfile();
  }
  
  /// Load user profile
  Future<void> _loadProfile() async {
    // In a real implementation, this would fetch the profile from repository
    // For now, we'll create a dummy profile for demonstration
    final profile = UserProfile(
      id: widget.userId,
      name: 'John Doe',
      email: 'john.doe@example.com',
      skinType: SkinType.combination,
      skinConcerns: ['Acne', 'Dryness'],
      allergies: ['Fragrance'],
      joinDate: DateTime.now().subtract(const Duration(days: 30)),
      hasCompletedOnboarding: true,
    );
    
    await _profileCubit.loadProfile(profile);
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to settings screen
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ],
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ProfileLoaded) {
              return _buildProfileContent(context, state.profile);
            } else if (state is ProfileError) {
              return Center(
                child: Text('Error: ${state.message}'),
              );
            } else {
              return const Center(
                child: Text('Loading profile...'),
              );
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(profile: profile),
          const SizedBox(height: 24),
          
          ProfileSection(
            title: 'Personal Information',
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Name'),
                subtitle: Text(profile.displayName),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditNameDialog(context, profile),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(profile.email ?? 'Not set'),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditEmailDialog(context, profile),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(profile.phoneNumber ?? 'Not set'),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditPhoneDialog(context, profile),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SkinPreferencesSection(profile: profile),
          
          const SizedBox(height: 16),
          
          AccountSettingsSection(profile: profile),
        ],
      ),
    );
  }
  
  void _showEditNameDialog(BuildContext context, UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                context.read<ProfileCubit>().updateProfileName(newName);
              }
              Navigator.of(context).pop();
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
  
  void _showEditEmailDialog(BuildContext context, UserProfile profile) {
    final emailController = TextEditingController(text: profile.email);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Email'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final newEmail = emailController.text.trim();
              if (newEmail.isNotEmpty) {
                context.read<ProfileCubit>().updateProfileEmail(newEmail);
              }
              Navigator.of(context).pop();
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
  
  void _showEditPhoneDialog(BuildContext context, UserProfile profile) {
    final phoneController = TextEditingController(text: profile.phoneNumber);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Phone'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone',
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final newPhone = phoneController.text.trim();
              if (newPhone.isNotEmpty) {
                context.read<ProfileCubit>().updateProfilePhone(newPhone);
              }
              Navigator.of(context).pop();
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}