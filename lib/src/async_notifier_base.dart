import 'dart:async';

import 'package:flutter/widgets.dart';

import 'async_listenable_base.dart';

/// Signature for callbacks that report data.
typedef DataChanged<T> = void Function(T data);

/// Signature for callbacks that report errors.
typedef ErrorCallback = void Function(Object error, StackTrace? stackTrace);

/// Base class for `AsyncNotifier` and `AsyncNotifierLate`.
abstract class AsyncNotifierBase<T, Data extends T> extends ValueNotifier<T>
    implements AsyncListenableBase<T, Data> {
  /// Base constructor for `AsyncNotifier` and `AsyncNotifierLate`.
  AsyncNotifierBase(super._value, {this.onData, this.onError})
      : _snapshot = _value is Data
            ? AsyncSnapshot.withData(ConnectionState.none, _value)
            : const AsyncSnapshot.nothing();

  /// Called when [AsyncSnapshot] resolves with new data.
  final DataChanged<Data>? onData;

  /// Called whenever [AsyncSnapshot] resolves with error.
  final ErrorCallback? onError;

  Future<Data>? _future;
  Stream<Data>? _stream;
  AsyncSnapshot<Data> _snapshot;
  StreamSubscription<Data>? _subscription;

  @override
  AsyncSnapshot<Data> get snapshot => _snapshot;

  @override
  set value(T value) {
    if (super.value == value) return;
    snapshot = value is Data
        ? AsyncSnapshot.withData(snapshot.connectionState, value)
        : AsyncSnapshot<Data>.nothing().inState(snapshot.connectionState);
  }

  @visibleForTesting
  set snapshot(AsyncSnapshot<Data> snapshot) {
    if (_snapshot == snapshot) return;
    final data = (_snapshot = snapshot).data;

    if (data is T && data != value && !snapshot.hasError) {
      super.value = data;
      onData?.call(data);
      return; // prevent notifyListeners since super.value already did.
    }
    notifyListeners();
  }

  @override
  Future<Data>? get future {
    final future = value is Data ? Future.value(value as Data) : null;
    return _future ?? future;
  }

  @override
  Stream<Data>? get stream {
    final stream = value is Data ? Stream.value(value as Data) : null;
    return _stream ?? stream?.asBroadcastStream();
  }

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
  set future(Future<Data>? future) {
    if (_future == future) return;
    if (future == null) return cancel();
    _unsubscribe();

    _future = future;
    snapshot = value is Data
        ? AsyncSnapshot.withData(ConnectionState.waiting, value as Data)
        : const AsyncSnapshot.waiting();

    _future?.then(
      (data) {
        if (_future != future) return;
        snapshot = AsyncSnapshot.withData(ConnectionState.done, data);
      },
      onError: (Object e, StackTrace s) {
        if (_future != future) return;
        snapshot = AsyncSnapshot.withError(ConnectionState.done, e, s);
        onError?.call(e, s);
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
  set stream(Stream<Data>? stream) {
    if (_stream == stream) return;
    if (stream == null) return cancel();
    _unsubscribe();

    _stream = stream.asBroadcastStream();
    snapshot = value is Data
        ? AsyncSnapshot.withData(ConnectionState.waiting, value as Data)
        : const AsyncSnapshot.waiting();

    _subscription = _stream?.listen(
      (data) {
        snapshot = AsyncSnapshot.withData(ConnectionState.active, data);
      },
      onError: (Object e, StackTrace s) {
        snapshot = AsyncSnapshot.withError(ConnectionState.active, e, s);
        onError?.call(e, s);
      },
      onDone: () {
        snapshot = _snapshot.inState(ConnectionState.done);
      },
    );
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _stream = null;
    _future = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}
