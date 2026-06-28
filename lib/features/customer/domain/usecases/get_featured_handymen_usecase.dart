import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../entities/handyman_list_entity.dart';
import '../repositories/customer_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class GetFeaturedHandymenUseCase {
  final CustomerRepository repository;

  GetFeaturedHandymenUseCase(this.repository);

  Future<Either<Failure, List<HandymanListEntity>>> call() {
    return repository.getFeaturedHandymen();
  }
}