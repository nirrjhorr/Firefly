import 'package:flutter_test/flutter_test.dart';
import 'package:app.firefly/core/errors/result.dart';

void main() {
  group('Result<T, E> Pattern', () {
    test('Ok holds value and matches Ok instance', () {
      const Result<int, String> result = Ok(42);

      switch (result) {
        case Ok(value: final val):
          expect(val, equals(42));
        case Err():
          fail('Should have matched Ok');
      }
    });

    test('Err holds error and matches Err instance', () {
      const Result<int, String> result = Err('Failure reason');

      switch (result) {
        case Ok():
          fail('Should have matched Err');
        case Err(error: final err):
          expect(err, equals('Failure reason'));
      }
    });
  });
}
