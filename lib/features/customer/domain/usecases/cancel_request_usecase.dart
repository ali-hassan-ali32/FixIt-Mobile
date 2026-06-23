import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../repositories/customer_repository.dart';

@injectable
class CancelRequestUseCase {
  final CustomerRepository repository;

  CancelRequestUseCase(
      this.repository,
      );

  Future<Either<Failure, void>>
  call(
      String id,
      ) {
    return repository.cancelRequest(
      id,
    );
  }
}