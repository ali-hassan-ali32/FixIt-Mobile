import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../repositories/auth_repository.dart';

import '../../data/models/requests/verify_otp_request.dart';

@injectable
class VerifyOtpUseCase {

  final AuthRepository repository;

  VerifyOtpUseCase(this.repository,);

  Future<Either<Failure, String>>
  call(VerifyOtpRequest request,) {return repository.verifyOtp(request,);}
}