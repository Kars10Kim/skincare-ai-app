import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

/// Confirmation phrase for account deletion
const String kAccountDeletionConfirmationPhrase = 'DELETE MY ACCOUNT';

/// Use case to delete user account
class DeleteAccount {
  /// Profile repository
  final ProfileRepository repository;
  
  /// Create delete account use case
  DeleteAccount(this.repository);
  
  /// Execute use case to delete account
  /// 
  /// Returns success or specific failure reason
  /// Account deletion is a staged process that may not be immediate
  Future<Either<Failure, Unit>> call({
    required String userId,
    required String confirmationPhrase,
    required String password,
  }) async {
    // Verify confirmation phrase
    if (confirmationPhrase != kAccountDeletionConfirmationPhrase) {
      return Left(AccountDeletionFailure(
        message: 'Incorrect confirmation phrase',
        reason: 'confirmation',
      ));
    }
    
    // Verify credentials
    final credentialsResult = await repository.verifyCredentials(userId, password);
    
    // Return early if credential verification failed
    if (credentialsResult.isLeft()) {
      return Left(AccountDeletionFailure(
        message: 'Authentication failed',
        reason: 'authentication',
      ));
    }
    
    // Check if credentials are valid
    final isValid = credentialsResult.getOrElse(() => false);
    if (!isValid) {
      return Left(AccountDeletionFailure(
        message: 'Incorrect password',
        reason: 'authentication',
      ));
    }
    
    // Request account deletion
    final result = await repository.deleteAccount(userId, confirmationPhrase);
    
    // If account deletion was successful, request verification
    if (result.isRight()) {
      await repository.requestAccountDeletionVerification(userId);
    }
    
    return result;
  }
}