import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../entities/portfolio_item_entity.dart';
import '../repositories/customer_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class GetHandymanPortfolioUseCase {
  final CustomerRepository repository;

  GetHandymanPortfolioUseCase(this.repository);

  Future<Either<Failure, List<PortfolioItemEntity>>> call(
      String handymanId,
      ) {
    return repository.getHandymanPortfolio(handymanId);
  }
}