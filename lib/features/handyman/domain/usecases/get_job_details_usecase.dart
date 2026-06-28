import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/handyman_job_details_entity.dart';
import '../repositories/handyman_repository.dart';

@injectable
class GetJobDetailsUseCase {
  final HandymanRepository repository;

  GetJobDetailsUseCase(
      this.repository,
      );

  Future<
      Either<
          Failure,
          HandymanJobDetailsEntity>>
  call(
      String id,
      ) {
    return repository.getJobDetails(
      id,
    );
  }
}