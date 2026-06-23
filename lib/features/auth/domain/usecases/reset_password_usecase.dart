import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../repositories/auth_repository.dart';

import '../../data/models/requests/reset_password_request.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(
      this.repository,
      );

  Future<Either<Failure, String>> call(
      ResetPasswordRequest request,
      ) {
    return repository.resetPassword(
      request,
    );
  }
}