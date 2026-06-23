import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../../data/models/requests/create_service_request.dart';

import '../repositories/customer_repository.dart';

@injectable
class CreateRequestUseCase {
  final CustomerRepository repository;

  CreateRequestUseCase(
      this.repository,
      );

  Future<Either<Failure, String>>
  call(
      CreateServiceRequest request,
      ) {
    return repository.createRequest(
      request,
    );
  }
}