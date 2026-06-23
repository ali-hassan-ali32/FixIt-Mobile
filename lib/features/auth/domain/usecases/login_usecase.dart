import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

import '../../data/models/requests/login_request.dart';

@injectable
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call(
      LoginRequest request,
      ) {
    return repository.login(request);
  }
}