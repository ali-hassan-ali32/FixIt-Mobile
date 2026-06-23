import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/customer_profile_entity.dart';
import '../repositories/customer_repository.dart';

@injectable
class GetProfileUseCase {
  final CustomerRepository repository;

  GetProfileUseCase(
      this.repository,
      );

  Future<
      Either<
          Failure,
          CustomerProfileEntity>>
  call() {
    return repository.getProfile();
  }
}