import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenService {
  Future<String?> getAccess();

  Future setAccess(String value);

  Future deleteAccess();
}

class TokenServiceImpl implements TokenService {
  final FlutterSecureStorage storage;


  TokenServiceImpl(this.storage);

  static const String _accessKey = "access";

  @override
  Future<String?> getAccess() {
    return storage.read(key: _accessKey);
  }

  @override
  Future<dynamic> setAccess(String value) async {
    await storage.write(key: _accessKey, value: value);
  }

  @override
  Future<dynamic> deleteAccess() async {
    await storage.delete(key: _accessKey);
  }
}
