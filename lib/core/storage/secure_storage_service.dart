import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String tokenKey = 'token';
  static const String roleKey = 'role';

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: tokenKey,
      value: token,
    );
  }

  Future<String?> getToken() async {
    return await _storage.read(
      key: tokenKey,
    );
  }

  Future<void> saveRole(String role) async {
    await _storage.write(
      key: roleKey,
      value: role,
    );
  }

  Future<String?> getRole() async {
    return await _storage.read(
      key: roleKey,
    );
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}