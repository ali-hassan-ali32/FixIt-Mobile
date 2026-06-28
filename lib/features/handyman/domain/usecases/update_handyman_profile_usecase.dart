import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../../data/models/requests/update_handyman_profile_request.dart';

import '../repositories/handyman_repository.dart';

@injectable
class UpdateHandymanProfileUseCase {
  final HandymanRepository repository;

  UpdateHandymanProfileUseCase(
      this.repository,
      );

  Future<Either<Failure, void>>
  call(
      UpdateHandymanProfileRequest request,
      ) {
    return repository.updateProfile(
      request,
    );
  }
}