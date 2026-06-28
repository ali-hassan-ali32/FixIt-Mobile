import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/handyman_profile_entity.dart';
import '../repositories/handyman_repository.dart';

@injectable
class GetHandymanProfileUseCase {
  final HandymanRepository repository;

  GetHandymanProfileUseCase(
      this.repository,
      );

  Future<
      Either<
          Failure,
          HandymanProfileEntity>>
  call() {
    return repository.getProfile();
  }
}