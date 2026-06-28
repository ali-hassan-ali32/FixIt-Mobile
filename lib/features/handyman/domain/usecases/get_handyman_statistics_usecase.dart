import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../entities/handyman_statistics_entity.dart';
import '../repositories/handyman_repository.dart';

@injectable
class GetHandymanStatisticsUseCase {
  final HandymanRepository repository;

  GetHandymanStatisticsUseCase(
      this.repository,
      );

  Future<Either<Failure, HandymanStatisticsEntity>> call() {
    return repository.getStatistics();
  }
}