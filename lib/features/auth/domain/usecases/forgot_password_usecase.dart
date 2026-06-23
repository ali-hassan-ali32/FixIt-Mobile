import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../repositories/auth_repository.dart';

import '../../data/models/requests/forgot_password_request.dart';

@injectable
class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(
      this.repository,
      );

  Future<Either<Failure, String>> call(
      ForgotPasswordRequest request,
      ) {
    return repository.forgotPassword(
      request,
    );
  }
}