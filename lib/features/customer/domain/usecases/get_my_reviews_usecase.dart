import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../entities/review_entity.dart';
import '../repositories/customer_repository.dart';

@injectable
class GetMyReviewsUseCase {
  final CustomerRepository repository;

  GetMyReviewsUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call() {
    return repository.getMyReviews();
  }
}