import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../entities/handyman_review_entity.dart';
import '../repositories/handyman_repository.dart';

@injectable
class GetReviewsUseCase {
  final HandymanRepository repository;

  GetReviewsUseCase(
      this.repository,
      );

  Future<
      Either<
          Failure,
          List<HandymanReviewEntity>>>
  call() {
    return repository.getReviews();
  }
}