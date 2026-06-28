import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../../data/models/requests/add_portfolio_request.dart';
import '../repositories/handyman_repository.dart';

@injectable
class AddPortfolioUseCase {
  final HandymanRepository repository;

  AddPortfolioUseCase(
      this.repository,
      );

  Future<Either<Failure, void>> call(
      AddPortfolioRequest request,
      ) {
    return repository.addPortfolio(
      request,
    );
  }
}