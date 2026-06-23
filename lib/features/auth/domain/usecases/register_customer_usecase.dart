import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

import '../../data/models/requests/register_customer_request.dart';

@injectable
class RegisterCustomerUseCase {
  final AuthRepository repository;

  RegisterCustomerUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call(
      RegisterCustomerRequest request,
      ) {
    return repository.registerCustomer(
      request,
    );
  }
}