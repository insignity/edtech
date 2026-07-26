import 'package:edtech/core/services/token/jwt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenService {
  Future<String?> getAccess();
  Future setAccess(String value);
  Future deleteAccess();
  Future<bool> hasAccessToken();

  /// Whether the session is still usable — either the access token is live, or
  /// the refresh token is, so the interceptor can renew it on the next call.
  ///
  /// Prefer this over [hasAccessToken] for gating navigation: a stale access
  /// token is still a non-empty string, so presence alone proves nothing.
  Future<bool> hasValidSession();

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
  Future<bool> hasValidSession() async {
    final access = await getAccess();
    if (access != null && access.isNotEmpty && !Jwt.isExpired(access)) {
      return true;
    }
    final refresh = await getRefresh();
    return refresh != null && refresh.isNotEmpty && !Jwt.isExpired(refresh);
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
