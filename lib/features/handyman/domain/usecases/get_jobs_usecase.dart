import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/handyman_job_summary_entity.dart';
import '../repositories/handyman_repository.dart';

@injectable
class GetJobsUseCase {
  final HandymanRepository repository;

  GetJobsUseCase(
      this.repository,
      );

  Future<Either<Failure, List<HandymanJobSummaryEntity>>>
  call() {
    return repository.getJobs();
  }
}