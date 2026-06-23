import 'package:injectable/injectable.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Kept dependency-free so this training project can compile without adding
/// connectivity_plus. Repository still falls back to cache when remote calls fail.
@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async => true;
}
