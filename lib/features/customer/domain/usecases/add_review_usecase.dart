import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../../data/models/requests/review_request.dart';
import '../repositories/customer_repository.dart';

@injectable
class AddReviewUseCase {
  final CustomerRepository repository;

  AddReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(
      String requestId,
      ReviewRequest request,
      ) {
    return repository.addReview(
      requestId,
      request,
    );
  }
}