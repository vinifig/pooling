import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pooling/pooling.dart';

void main() {
  const originalException = FormatException('could not format the input');
  group('exceptions', () {
    test('PoolingException#toString should return the correct value', () {
      const runCount = 4;
      const originalStackTrace = null;
      const exception = PoolingException(
        runCount,
        originalException,
        originalStackTrace,
      );

      expect(
        exception.toString(),
        equals(
          'PoolingException(runCount: $runCount, $originalException, $originalStackTrace)',
        ),
      );
    });
  });

  group('pooler', () {
    test('#start should return the pooler itself', () {
      final pooler = Pooler<int>(
        fetch: () {
          return Future.value(1);
        },
        interval: const Duration(milliseconds: 10),
        onChange: (value) {},
        onException: null,
      );

      final result = pooler.start();
      result.stop();

      expect(pooler, equals(result));
    });

    test(
      'should not rethrow even if an exception is raised without onException',
      () async {
        Object? thrown;
        try {
          final pooler = Pooler<int>(
            fetch: () {
              throw originalException;
            },
            interval: const Duration(milliseconds: 10),
            onChange: (value) {},
            onException: null,
          );

          pooler.start();

          await Future.delayed(const Duration(milliseconds: 20));

          pooler.stop();
        } catch (e) {
          thrown = e;
        }

        expect(thrown, isNull);
      },
    );

    test(
      'should call onException when raised an exception',
      () async {
        Object? exception;
        final pooler = Pooler<int>(
          fetch: () {
            throw originalException;
          },
          interval: const Duration(milliseconds: 10),
          onChange: (value) {},
          onException: (PoolingException e) {
            exception = e;
          },
        );

        pooler.start();
        await Future.delayed(const Duration(milliseconds: 20));
        pooler.stop();

        expect(exception, isA<PoolingException>());
      },
    );

    test('should call onChange only if the value is new', () async {
      int count = 0;
      int fetchTimes = 0;
      var calledValues = [];
      final expectedValues = [1, 2, 3, 4, 5];

      final pooler = Pooler<int>(
        fetch: () async {
          fetchTimes++;
          if (count < 5) {
            count = count + 1;
          }
          return count;
        },
        interval: const Duration(milliseconds: 10),
        onChange: (value) {
          calledValues.add(value!);
        },
        onException: null,
      );
      pooler.start();
      await Future.delayed(const Duration(milliseconds: 100));
      pooler.stop();

      expect(listEquals(calledValues, expectedValues), true);
      expect(fetchTimes, greaterThan(5));
    });
  });
}
