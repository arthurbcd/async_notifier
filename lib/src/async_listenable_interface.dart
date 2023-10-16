import 'async_listenable_base.dart';

/// An interface for `AsyncNotifier` value `T` and async data `T`.
abstract class AsyncListenable<T> implements AsyncListenableBase<T, T> {
  /// Enables const constructor for subclasses.
  const AsyncListenable();
}

/// An interface for `AsyncNotifierLate` value `T?` and async data `T`.
abstract class AsyncListenableLate<T> implements AsyncListenableBase<T?, T> {
  /// Enables const constructor for subclasses.
  const AsyncListenableLate();
}
