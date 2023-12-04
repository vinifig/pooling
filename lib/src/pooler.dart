import 'package:flutter/foundation.dart';
import 'package:pooling/src/exceptions.dart';
import 'package:pooling/src/types.dart';

enum PoolingStatus {
  created,
  running,
  stopped,
  failed,
}

class Pooler<T> extends ValueNotifier<T?> {
  Pooler({
    required this.fetch,
    required this.interval,
    required this.onChange,
    required this.onException,
  }) : super(null);

  final Duration interval;

  // Events
  final FetchCallback<T?> fetch;
  final ValueChanged<T?> onChange;
  final ExceptionCallback? onException;

  bool _running = false;
  int _runCount = 1;

  bool get running => _running;
  int get runCount => _runCount;

  Future<void> _execute() async {
    do {
      try {
        value = await fetch();
        await Future.delayed(interval);
      } catch (e, stacktrace) {
        _handleException(e, stacktrace);
      }
    } while (_running);
  }

  Pooler<T> start() {
    addListener(_onChangeListener);
    if (_running == false) {
      _running = true;
      _execute();
      _runCount++;
    }
    return this;
  }

  void stop() {
    removeListener(_onChangeListener);
    _running = false;
  }

  void _onChangeListener() {
    onChange(value);
  }

  void _handleException(Object originalException, StackTrace? stacktrace) {
    final exception = ExecutionException(
      runCount,
      originalException,
      stacktrace,
    );
    if (onException == null) {
      throw exception;
    }
    onException?.call(exception);
  }
}
