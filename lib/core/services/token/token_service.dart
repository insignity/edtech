import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenService {
  Future<String?> getAccess();
  Future setAccess(String value);
  Future deleteAccess();
  Future<bool> hasAccessToken();

  Future<String?> getRefresh();
  Future setRefresh(String value);
  Future deleteRefresh();

  Future deleteAll();
}

class TokenServiceImpl implements TokenService {
  final FlutterSecureStorage storage;

  TokenServiceImpl(this.storage);

  static const String _accessKey = "access";
  static const String _refreshKey = "refresh";

  @override
  Future<String?> getAccess() => storage.read(key: _accessKey);

  @override
  Future setAccess(String value) => storage.write(key: _accessKey, value: value);

  @override
  Future deleteAccess() => storage.delete(key: _accessKey);

  @override
  Future<bool> hasAccessToken() async {
    final response = await getAccess();
    return response != null && response.isNotEmpty;
  }

  @override
  Future<String?> getRefresh() => storage.read(key: _refreshKey);

  @override
  Future setRefresh(String value) => storage.write(key: _refreshKey, value: value);

  @override
  Future deleteRefresh() => storage.delete(key: _refreshKey);

  @override
  Future deleteAll() async {
    await deleteAccess();
    await deleteRefresh();
  }
}
