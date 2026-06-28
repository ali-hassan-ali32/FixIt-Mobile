import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../entities/handyman_list_entity.dart';
import '../repositories/customer_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class GetHandymenUseCase {
  final CustomerRepository repository;

  GetHandymenUseCase(this.repository);

  Future<Either<Failure, List<HandymanListEntity>>> call({
    String? search,
    String? categoryId,
    bool? availableOnly,
  }) {
    return repository.getHandymen(
      search: search,
      categoryId: categoryId,
      availableOnly: availableOnly,
    );
  }
}