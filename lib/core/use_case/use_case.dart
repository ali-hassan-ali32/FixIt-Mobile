import '../result/result.dart';

abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

abstract class NoParamsUseCase<Type> {
  Future<Result<Type>> call();
}

class NoParams {
  const NoParams();
}
