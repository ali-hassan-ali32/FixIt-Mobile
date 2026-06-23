import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/customer_request_summary_entity.dart';
import '../repositories/customer_repository.dart';

@injectable
class GetRequestsUseCase {
  final CustomerRepository repository;

  GetRequestsUseCase(
      this.repository,
      );

  Future<
      Either<
          Failure,
          List<
              CustomerRequestSummaryEntity>>>
  call() {
    return repository.getRequests();
  }
}