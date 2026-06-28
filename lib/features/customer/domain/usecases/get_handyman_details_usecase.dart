import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../entities/handyman_details_entity.dart';
import '../repositories/customer_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class GetHandymanDetailsUseCase {
  final CustomerRepository repository;

  GetHandymanDetailsUseCase(this.repository);

  Future<Either<Failure, HandymanDetailsEntity>> call(
      String handymanId,
      ) {
    return repository.getHandymanDetails(handymanId);
  }
}