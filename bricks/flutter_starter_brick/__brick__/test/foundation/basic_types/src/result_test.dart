import 'package:flutter_test/flutter_test.dart';
import 'package:{{proj_name}}/foundation/basic_types/basic_types.dart';

void main() {
  group('Result', () {
    test('routes success data through the success callback', () {
      final result = Result<String, int>.success(data: 42);

      final value = result.when(
        success: (data) => data,
        failure: (_) => -1,
      );

      expect(value, 42);
    });

    test('routes failure data through the failure callback', () {
      final result = Result<String, int>.failure(data: 'failed');

      final value = result.when(
        success: (_) => 'succeeded',
        failure: (data) => data,
      );

      expect(value, 'failed');
    });
  });
}
