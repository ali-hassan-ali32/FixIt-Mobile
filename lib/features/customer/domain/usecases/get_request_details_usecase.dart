import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/customer_request_details_entity.dart';
import '../repositories/customer_repository.dart';

@injectable
class GetRequestDetailsUseCase {
  final CustomerRepository repository;

  GetRequestDetailsUseCase(
      this.repository,
      );

  Future<
      Either<
          Failure,
          CustomerRequestDetailsEntity>>
  call(
      String id,
      ) {
    return repository
        .getRequestDetails(
      id,
    );
  }
}