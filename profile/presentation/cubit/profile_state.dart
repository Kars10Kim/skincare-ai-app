import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

/// Profile state
abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Profile initial state
class ProfileInitial extends ProfileState {}

/// Profile loading state
class ProfileLoading extends ProfileState {}

/// Profile loaded state
class ProfileLoaded extends ProfileState {
  /// User profile
  final UserProfile profile;
  
  /// Whether the profile is being updated
  final bool isUpdating;
  
  /// Create profile loaded state
  ProfileLoaded({
    required this.profile,
    this.isUpdating = false,
  });
  
  @override
  List<Object?> get props => [profile, isUpdating];
  
  /// Create copy with modified fields
  ProfileLoaded copyWith({
    UserProfile? profile,
    bool? isUpdating,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

/// Profile error state
class ProfileError extends ProfileState {
  /// Error message
  final String message;
  
  /// Error code
  final int? code;
  
  /// Create profile error state
  ProfileError({
    required this.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
}

/// Profile image upload state
class ProfileImageUploading extends ProfileState {}

/// Profile image upload success state
class ProfileImageUploadSuccess extends ProfileState {
  /// Image path
  final String imagePath;
  
  /// Create profile image upload success state
  ProfileImageUploadSuccess({
    required this.imagePath,
  });
  
  @override
  List<Object?> get props => [imagePath];
}

/// Profile image upload error state
class ProfileImageUploadError extends ProfileState {
  /// Error message
  final String message;
  
  /// Create profile image upload error state
  ProfileImageUploadError({
    required this.message,
  });
  
  @override
  List<Object?> get props => [message];
}

/// Account deletion state
class AccountDeletionInProgress extends ProfileState {}

/// Account deletion success state
class AccountDeletionSuccess extends ProfileState {}

/// Account deletion error state
class AccountDeletionError extends ProfileState {
  /// Error message
  final String message;
  
  /// Error reason
  final String reason;
  
  /// Create account deletion error state
  AccountDeletionError({
    required this.message,
    required this.reason,
  });
  
  @override
  List<Object?> get props => [message, reason];
}