import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The base interface for `AsyncNotifierBase`.
///
/// Exposes [future] and [stream] as [snapshot].
abstract class AsyncListenableBase<T, Data extends T>
    extends ValueListenable<T> {
  /// Enables const constructor for subclasses.
  const AsyncListenableBase();

  /// The current [Stream]. If absent, returns [value] as [Stream.value].
  Stream<Data>? get stream;

  /// The current [Future]. If absent, returns [value] as [Future.value].
  Future<Data>? get future;

  /// The current [AsyncSnapshot] of [future] or [stream].
  AsyncSnapshot<Data> get snapshot;
}
