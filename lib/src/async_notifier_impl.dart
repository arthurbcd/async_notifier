import 'dart:async';

import '../async_notifier.dart';
import 'async_listenable_interface.dart';
import 'async_notifier_base.dart';

/// A `ValueNotifier<T>` that listens to [Future] and [Stream] `T` data.
class AsyncNotifier<T> extends AsyncNotifierBase<T, T>
    implements AsyncListenable<T> {
  /// Creates an `AsyncNotifier` instance with an initial value of type [T].
  ///
  /// The `AsyncNotifier` is designed to work with asynchronous operations that
  /// also produce data of type [T].
  ///
  /// - `_value`: The initial data for this notifier.
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
  ///
  /// This constructor is ideal for scenarios where the initial value is readily available
  /// at the time of object creation.
  AsyncNotifier(super._value, {super.onData, super.onError});

  /// Shortcut constructor for creating an `AsyncNotifierLate` instance.
  ///
  /// For more details, see the documentation for [AsyncNotifierLate].
  static AsyncNotifierLate<T> late<T>({
    T? value,
    DataChanged<T>? onData,
    ErrorCallback? onError,
  }) {
    return AsyncNotifierLate(value: value, onData: onData, onError: onError);
  }
}

/// A `ValueNotifier<T?>` that listens to [Future] and [Stream] `T` data.
class AsyncNotifierLate<T> extends AsyncNotifierBase<T?, T>
    implements AsyncListenableLate<T> {
  /// Creates an [AsyncNotifierLate] instance with an initial [value] nullable.
  ///
  /// The [AsyncNotifierLate] is designed to start as `T?` value and be populated
  /// with non-nullable data of type `T` at a later time through asynchronous operations.
  ///
  /// This constructor is particularly useful in scenarios where the initial value is not
  /// available at the time of object creation but is guaranteed to be non-nullable when
  /// set later.
  ///
  /// Example:
  /// ```dart
  /// final _user = AsyncNotifier.late<User>();
  /// ```
  ///
  /// The asynchronous operations that populate this notifier, such as [Future] or [Stream],
  /// are expected to produce non-nullable data of type [T]:
  ///
  /// ```dart
  /// _user.future = Future<User>.value(User());
  /// _user.future = Future<User?>.value(null); // lint error
  /// ```
  AsyncNotifierLate({T? value, super.onData, super.onError}) : super(value);
}
