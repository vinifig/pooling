import 'package:flutter/foundation.dart';

@immutable
abstract class PoolingException implements Exception {
  const PoolingException(
    this.runCount,
    this.originalException,
    this.originalStackTrace,
  );

  final int runCount;
  final Object? originalException;
  final StackTrace? originalStackTrace;

  @override
  String toString() {
    return "PoolingException(runCount: $runCount, $originalException, $originalStackTrace)";
  }
}

class ExecutionException extends PoolingException {
  const ExecutionException(
    super.runCount,
    super.originalException,
    super.originalStackTrace,
  );
}
