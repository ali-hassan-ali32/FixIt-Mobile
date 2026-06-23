import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/customer_statistics_entity.dart';
import '../repositories/customer_repository.dart';

@injectable
class GetStatisticsUseCase {
  final CustomerRepository repository;

  GetStatisticsUseCase(
      this.repository,
      );

  Future<
      Either<
          Failure,
          CustomerStatisticsEntity>>
  call() {
    return repository.getStatistics();
  }
}