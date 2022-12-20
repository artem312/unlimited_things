import 'dart:async';

class RequestQueue<TResult> {
  Completer<TResult>? _completer;

  /// if true, then the result of the last request will be returned,
  /// if previous requests are not completed.
  ///
  /// has no effect if force argument of [request] is false
  final bool alwaysActualResult;

  /// Create request queue that prevent execute multiple requests at the same time
  /// while first request is not completed
  RequestQueue({
    this.alwaysActualResult = false,
  });

  /// Return future that will be completed when request function is completed.
  /// If request function is already running, then this function will return
  /// future that will be completed when first request function is completed.
  ///
  /// If [force] is true, then request function will be executed immediately
  /// and if[alwaysActualResult] is true, old futures that are waiting for
  /// request function will be completed with result of new request function
  Future<TResult> request(
    FutureOr<TResult> Function() request, {
    bool force = false,
  }) {
    if ((_completer?.isCompleted ?? true) || force) {
      final oldCompleter = _completer;
      final newCompleter = Completer<TResult>();
      if (alwaysActualResult && !(oldCompleter?.isCompleted ?? true)) {
        oldCompleter!.complete(newCompleter.future);
      }
      final result = request();
      if (result is Future<TResult>) {
        result.then(
          (value) => _completeIfNotCompleted(newCompleter, value),
          onError: (error, stackTrace) =>
              _completeErrorIfNotCompleted(newCompleter, error, stackTrace),
        );
      } else {
        newCompleter.complete(result);
      }
      _completer = newCompleter;
    }
    return _completer!.future;
  }

  /// complete completer if it is not completed
  void _completeIfNotCompleted(Completer<TResult> completer, TResult result) {
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  /// if any error occurs, complete completer with error if it is not completed
  void _completeErrorIfNotCompleted(
    Completer<TResult> completer,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (!completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }
}

class DebouncedRequestQueue<TResult> extends RequestQueue<TResult> {
  late DateTime _lastRequestTime;

  /// delay duration before execute request after last request
  final Duration duration;

  ///[RequestQueue] that will wait [duration] before executing the request,
  ///if a new request is made before the [duration] is over, function will return last completed result.
  DebouncedRequestQueue({
    required this.duration,
    super.alwaysActualResult = false,
  }) : _lastRequestTime = DateTime.now().subtract(duration);

  @override
  Future<TResult> request(
    FutureOr<TResult> Function() request, {
    bool force = false,
  }) {
    if (_completer != null &&
        !force &&
        DateTime.now().difference(_lastRequestTime) < duration) {
      return _completer!.future;
    }
    return super.request(request, force: force).whenComplete(() {
      _lastRequestTime = DateTime.now();
    });
  }
}
