import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';
import '../entities/user_profile.dart';

/// Use case to update user profile
class UpdateProfile {
  /// Profile repository
  final ProfileRepository repository;
  
  /// Create update profile use case
  UpdateProfile(this.repository);
  
  /// Execute use case to update profile
  /// 
  /// Returns updated profile or failure
  Future<Either<Failure, UserProfile>> call(UserProfile profile) async {
    // Validate profile data
    final validation = _validateProfile(profile);
    if (validation.isLeft()) {
      return validation;
    }
    
    // Update profile
    return repository.updateProfile(profile);
  }
  
  /// Validate profile data
  /// 
  /// Returns right unit if valid, left failure if invalid
  Either<Failure, Unit> _validateProfile(UserProfile profile) {
    // Validate email format if provided
    if (profile.email != null && profile.email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(profile.email!)) {
        return Left(ValidationFailure(
          message: 'Invalid email format',
          field: 'email',
        ));
      }
    }
    
    // Validate phone format if provided
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
      if (!phoneRegex.hasMatch(profile.phoneNumber!)) {
        return Left(ValidationFailure(
          message: 'Invalid phone number format',
          field: 'phoneNumber',
        ));
      }
    }
    
    // Validate name if provided
    if (profile.name != null) {
      if (profile.name!.isEmpty) {
        return Left(ValidationFailure(
          message: 'Name cannot be empty',
          field: 'name',
        ));
      }
      
      if (profile.name!.length < 2) {
        return Left(ValidationFailure(
          message: 'Name is too short',
          field: 'name',
        ));
      }
    }
    
    return const Right(unit);
  }
}