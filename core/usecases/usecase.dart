import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base usecase interface
abstract class UseCase<Type, Params> {
  /// Execute the usecase
  Future<Either<Failure, Type>> call(Params params);
}

/// No parameters class for use cases that don't require parameters
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}