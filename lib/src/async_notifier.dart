import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Signature for callbacks that report data.
typedef DataChanged<T> = void Function(T data);

/// Signature for callbacks that report errors.
typedef ErrorCallback = void Function(Object error, StackTrace stackTrace);

/// Signature for a read-only [AsyncSnapshot] listener.
typedef AsyncListenable<T> = ValueListenable<AsyncSnapshot<T>>;

/// A `ValueNotifier<T>` that listens to [Future] and [Stream] snapshot.
class AsyncNotifier<T> extends ValueNotifier<AsyncSnapshot<T>> {
  /// Creates an `AsyncNotifier` instance with an initial value of type [T].
  ///
  /// The `AsyncNotifier` is designed to work with asynchronous operations that
  /// also produce data of type [T].
  ///
  /// - `data`: The initial [AsyncSnapshot.data].
  /// - `error`: The initial [AsyncSnapshot.error].
  /// - `stackTrace`: The initial [AsyncSnapshot.stackTrace].
  /// - `state`: The initial [AsyncSnapshot.connectionState].
  /// - `onData`: Invoked when new data is available.
  /// - `onError`: Invoked when an error occurs during an asynchronous operation.
  ///
  /// Example:
  /// ```dart
  /// final notifier = AsyncNotifier(<Todo>[], onData: (todos) {
  ///   print('Todos changed: ${todos.length}');
  /// }, onError: (error, stackTrace) {
  ///   print('An error occurred: $error');
  /// });
  /// ```
  AsyncNotifier({
    T? data,
    Object? error,
    StackTrace stackTrace = StackTrace.empty,
    ConnectionState state = ConnectionState.none,
    this.onData,
    this.onError,
    this.cancelOnError,
  })  : assert(data == null || error == null),
        super(
          error != null
              ? AsyncSnapshot.withError(state, error, stackTrace)
              : data is T
                  ? AsyncSnapshot.withData(state, data)
                  : AsyncSnapshot<T>.nothing().inState(state),
        );

  /// Called when [AsyncSnapshot] resolves with new data.
  final DataChanged<T>? onData;

  /// Called whenever [AsyncSnapshot] resolves with error.
  final ErrorCallback? onError;

  /// Whether the subscription should be canceled when an error occurs.
  final bool? cancelOnError;

  Future<T>? _future;
  Stream<T>? _stream;
  StreamSubscription<T>? _subscription;

  @override
  @visibleForTesting
  @Deprecated('Use `snapshot` instead')
  AsyncSnapshot<T> get value => super.value;

  @override
  @visibleForTesting
  set value(AsyncSnapshot<T> value) {
    final previous = super.value;
    final next = super.value = value;

    if (next.data is T && next.data != previous.data && !next.hasError) {
      onData?.call(next.data as T);
    }
    if (next.hasError && next.error != previous.error) {
      onError?.call(next.error!, next.stackTrace!);
    }
  }

  /// The [Future] currently being listened to.
  Future<T>? get future => _future;

  /// The [Stream] currently being listened to.
  Stream<T>? get stream => _stream;

  /// Sets the [Future] for this `AsyncNotifier`, updating its state.
  ///
  /// Stop listening to any existing future and listens to the new one.
  /// - On start: Updates [snapshot] to 'waiting'.
  /// - On completion: Updates [snapshot] with done state and data.
  /// - On error: Updates [snapshot] with error and invokes [onError].
  ///
  /// No action is taken if the new future is identical to the current one.
  ///
  /// Example:
  /// ```dart
  /// final _user = AsyncNotifier.late<User>();
  /// _user.future = someUserFuture;
  /// ```
  set future(Future<T>? future) {
    if (_future == future) return;
    if (future == null) return cancel();
    _unsubscribe();

    _future = future;
    value = snapshot.inState(ConnectionState.waiting);

    _future?.then(
      (data) {
        if (_future != future) return;
        value = AsyncSnapshot.withData(ConnectionState.done, data);
      },
      onError: (Object e, StackTrace s) {
        if (_future != future) return;
        value = AsyncSnapshot.withError(ConnectionState.done, e, s);
      },
    );
  }

  /// Sets the [Stream] for this `AsyncNotifier`, updating its state.
  ///
  /// Unsubscribes from any existing stream and subscribes to the new one.
  /// - On start: Updates [snapshot] to 'waiting'.
  /// - On new data: Updates [snapshot] with active state and data.
  /// - On error: Updates [snapshot] with error and invokes [onError].
  /// - On done: Updates [snapshot] to done state.
  ///
  /// No action is taken if the new stream is identical to the current one.
  ///
  /// Example:
  /// ```dart
  /// final _user = AsyncNotifier.late<User>();
  /// _user.stream = someUserStream;
  /// ```
  set stream(Stream<T>? stream) {
    if (_stream == stream) return;
    if (stream == null) return cancel();
    _unsubscribe();

    _stream = stream;
    value = snapshot.inState(ConnectionState.waiting);

    _subscription = _stream?.listen(
      cancelOnError: cancelOnError,
      (data) {
        value = AsyncSnapshot.withData(ConnectionState.active, data);
      },
      onError: (Object e, StackTrace s) {
        value = AsyncSnapshot.withError(ConnectionState.active, e, s);
      },
      onDone: () {
        value = snapshot.inState(ConnectionState.done);
      },
    );
  }

  /// Unsubscribes to existing [Future] or [Stream] and sets [snapshot] to 'none'.
  ///
  /// Any data/error will be retained. Just as in Future/Stream builder.
  void cancel() {
    _unsubscribe();
    value = snapshot.inState(ConnectionState.none);
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = _stream = _future = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}

/// [AsyncListenable] extension.
extension AsyncListenableExtension<T> on AsyncListenable<T> {
  /// The current [AsyncSnapshot] of the [AsyncListenable].
  AsyncSnapshot<T> get snapshot => value;
}
