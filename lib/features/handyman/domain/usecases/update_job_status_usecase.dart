import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../../data/models/requests/update_job_status_request.dart';

import '../repositories/handyman_repository.dart';

@injectable
class UpdateJobStatusUseCase {
  final HandymanRepository repository;

  UpdateJobStatusUseCase(
      this.repository,
      );

  Future<Either<Failure, void>>
  call(
      String id,
      UpdateJobStatusRequest request,
      ) {
    return repository.updateJobStatus(
      id,
      request,
    );
  }
}