import 'package:edtech/features/auth/models/token_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenModel', () {
    test('fromJson parses access and refresh', () {
      final model = TokenModel.fromJson({
        'access': 'access-token',
        'refresh': 'refresh-token',
      });

      expect(model.access, 'access-token');
      expect(model.refresh, 'refresh-token');
    });

    test('fromJson throws when refresh missing', () {
      expect(
        () => TokenModel.fromJson({'access': 'only-access'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
