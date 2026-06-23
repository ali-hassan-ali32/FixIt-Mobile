import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

import '../../data/models/requests/register_handyman_request.dart';

@injectable
class RegisterHandymanUseCase {
  final AuthRepository repository;

  RegisterHandymanUseCase(
      this.repository,
      );

  Future<Either<Failure, AuthUser>> call(
      RegisterHandymanRequest request,
      ) {
    return repository.registerHandyman(
      request,
    );
  }
}