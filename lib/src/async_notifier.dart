// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
  /// - `cancelOnError`: Whether the subscription should be canceled when an error occurs.
  ///
  /// Example:
  /// ```dart
  /// final notifier = AsyncNotifier<List<Todo>>();
  /// ```
  AsyncNotifier({
    T? data,
    Object? error,
    StackTrace stackTrace = StackTrace.empty,
    ConnectionState state = ConnectionState.none,
    void Function(T data)? onData,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
    this.cancelOnError,
  })  : _callbacks = (onData: onData, onError: onError, onDone: onDone),
        assert(data == null || error == null),
        super(
          error != null
              ? AsyncSnapshot.withError(state, error, stackTrace)
              : data is T
                  ? AsyncSnapshot.withData(state, data)
                  : AsyncSnapshot<T>.nothing().inState(state),
        ) {
    observer?.onCreate(this);
  }

  /// The current global observer for [AsyncNotifier] instances.
  static AsyncNotifierObserver? observer;

  /// Whether the subscription should be canceled when an error occurs.
  final bool? cancelOnError;
  final _AsyncCallbacks<T>? _callbacks;

  // async states
  Future<T>? _future;
  Stream<T>? _stream;
  StreamSubscription<T>? _subscription;

  /// The [Future] currently being listened to.
  Future<T>? get future => _future;

  /// The [Stream] currently being listened to.
  Stream<T>? get stream => _stream;

  /// The current [AsyncSnapshot] of this [AsyncListenable].
  AsyncSnapshot<T> get snapshot => super.value;

  @override
  @Deprecated('Use snapshot instead')
  AsyncSnapshot<T> get value => super.value;

  @override
  @protected
  set value(AsyncSnapshot<T> newValue) {
    if (observer != null && super.value != newValue) {
      observer?.onChange(this, super.value, newValue);
    }
    super.value = newValue;
  }

  /// Sets the [Future] for this `AsyncNotifier`, updating its state.
  ///
  /// Stop listening to any existing future and listens to the new one.
  /// - On start: Updates snapshot to 'waiting'.
  /// - On completion: Updates snapshot with done state and data.
  /// - On error: Updates snapshot with error.
  ///
  /// No action is taken if the new future is identical to the current one.\
  ///
  /// Example:
  /// ```dart
  /// final _user = AsyncNotifier<User>();
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
        onData(data);
        onDone();
      },
      onError: (Object e, StackTrace s) {
        if (_future != future) return;
        value = AsyncSnapshot.withError(ConnectionState.done, e, s);
        onError(e, s);
        onDone();
      },
    );
  }

  /// Sets the [Stream] for this `AsyncNotifier`, updating its state.
  ///
  /// Unsubscribes from any existing stream and subscribes to the new one.
  /// - On start: Updates snapshot to 'waiting'.
  /// - On new data: Updates snapshot with active state and data.
  /// - On error: Updates snapshot with error.
  /// - On done: Updates snapshot to done state.
  ///
  /// No action is taken if the new stream is identical to the current one.
  ///
  /// Example:
  /// ```dart
  /// final _user = AsyncNotifier<User>();
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
        onData(data);
      },
      onError: (Object e, StackTrace s) {
        value = AsyncSnapshot.withError(ConnectionState.active, e, s);
        onError(e, s);
      },
      onDone: () {
        value = snapshot.inState(ConnectionState.done);
        onDone();
      },
    );
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = _stream = _future = null;
  }

  /// Callback when new data is available.
  @protected
  @mustCallSuper
  void onData(T data) {
    _callbacks?.onData?.call(data);
    observer?.onData(this, data);
  }

  /// Callback when an error occurs.
  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    _callbacks?.onError?.call(error, stackTrace);
    observer?.onError(this, error, stackTrace);
  }

  /// Callback when the async operation is done.
  @protected
  @mustCallSuper
  void onDone() {
    _callbacks?.onDone?.call();
    observer?.onDone(this);
  }

  /// Unsubscribes to existing [Future] or [Stream] and sets snapshot to 'none'.
  ///
  /// Any data/error will be retained. Just as in Future/Stream builder.
  @mustCallSuper
  void cancel() {
    _unsubscribe();
    value = snapshot.inState(ConnectionState.none);
  }

  @override
  void dispose() {
    _unsubscribe();
    observer?.onDispose(this);
    super.dispose();
  }
}

typedef _AsyncCallbacks<T> = ({
  void Function(T data)? onData,
  void Function(Object error, StackTrace stackTrace)? onError,
  void Function()? onDone,
});

/// {@template async_notifier_observer}
/// An interface for observing the behavior of [AsyncNotifier] instances.
/// {@endtemplate}
abstract class AsyncNotifierObserver {
  /// {@macro async_notifier_observer}
  const AsyncNotifierObserver();

  /// Called whenever an [AsyncNotifier] is instantiated.
  @protected
  @mustCallSuper
  void onCreate(AsyncNotifier<dynamic> it) {}

  /// Called whenever a change occurs in any [AsyncNotifier].
  @protected
  @mustCallSuper
  void onChange(
    AsyncNotifier<dynamic> it,
    AsyncSnapshot<dynamic> prev,
    AsyncSnapshot<dynamic> next,
  ) {}

  /// Called whenever new data is available in any [AsyncNotifier].
  @protected
  @mustCallSuper
  void onData(AsyncNotifier<dynamic> it, Object? data) {}

  /// Called whenever an [error] is thrown in any [AsyncNotifier].
  /// The [stackTrace] argument may be [StackTrace.empty] if an error
  /// was received without a stack trace.
  @protected
  @mustCallSuper
  void onError(
    AsyncNotifier<dynamic> it,
    Object error,
    StackTrace stackTrace,
  ) {}

  /// Called whenever a [AsyncNotifier] is done with its async operation.
  @protected
  @mustCallSuper
  void onDone(AsyncNotifier<dynamic> it) {}

  /// Called whenever a [AsyncNotifier] is disposed.
  @protected
  @mustCallSuper
  void onDispose(AsyncNotifier<dynamic> it) {}
}
