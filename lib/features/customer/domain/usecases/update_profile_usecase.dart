import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../../data/models/requests/update_profile_request.dart';

import '../repositories/customer_repository.dart';

@injectable
class UpdateProfileUseCase {
  final CustomerRepository repository;

  UpdateProfileUseCase(
      this.repository,
      );

  Future<Either<Failure, String>>
  call(
      UpdateProfileRequest request,
      ) {
    return repository.updateProfile(
      request,
    );
  }
}