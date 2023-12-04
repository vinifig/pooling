import 'package:pooling/src/exceptions.dart';

/// Callback triggered every time a Pooling Run is started
///
/// `() async {`
/// `  return await service.fetchData();`
/// `}`
///
/// or else
///
/// `() {`
/// `  return service.fetchData();`
/// `}`
typedef FetchCallback<T> = Future<T> Function();

/// Callback triggered when an error happens in a Pooling Run
///
/// `(exception) {`
/// `  ...`
/// `}`
typedef ExceptionCallback = void Function(PoolingException);
