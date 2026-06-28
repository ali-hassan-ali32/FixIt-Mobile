import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../repositories/handyman_repository.dart';

@injectable
class DeletePortfolioUseCase {
  final HandymanRepository repository;

  DeletePortfolioUseCase(
      this.repository,
      );

  Future<Either<Failure, void>> call(
      String id,
      ) {
    return repository.deletePortfolio(
      id,
    );
  }
}