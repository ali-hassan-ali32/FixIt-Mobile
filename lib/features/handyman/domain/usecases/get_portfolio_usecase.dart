import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../entities/handyman_portfolio_entity.dart';
import '../repositories/handyman_repository.dart';

@injectable
class GetPortfolioUseCase {
  final HandymanRepository repository;

  GetPortfolioUseCase(
      this.repository,
      );

  Future<Either<Failure, List<HandymanPortfolioEntity>>> call() {
    return repository.getPortfolio();
  }
}