import 'package:flutter/widgets.dart';

/// Extension on [AsyncSnapshot] to handle its various states
extension AsyncSnapshotExtension<T> on AsyncSnapshot<T> {
  /// Allows you to define custom behavior for different states of an [AsyncSnapshot]
  /// by providing callbacks for `data`, `error`, `loading`, and `none`.
  ///
  /// - [data] Callbacks when snapshot has [T] data.
  /// - [error] Callbacks when snapshot [hasError].
  /// - [loading] Callbacks when snapshot [isLoading] and [hasNone].
  /// - [none] Optionally callbacks when snapshot not [isLoading] and [hasNone].
  ///
  /// Use [none] for uncommon scenarios where [data], [error], and [loading] are
  /// not applicable. For instance, to display a widget when there's no data, no
  /// error, and no ongoing loading, or when a [Stream] is cancelled without
  /// emitting any data or error (e.g [Stream.empty]).
  ///
  /// If [none] is not provided:
  /// - [loading] will be called when init [hasNone].
  /// - [StateError] will be thrown when done [hasNone].
  ///
  /// Example:
  /// ```dart
  /// snapshot.when(
  ///   data: (data) => Text('Data: $data'),
  ///   error: (error, stack) => Text('Error: $error'),
  ///   loading: () => CircularProgressIndicator(),
  ///   none: () => Text('No error or data'),
  /// );
  /// ```
  R when<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function() loading,
    R Function()? none,
  }) {
    if (hasError) return error(this.error!, stackTrace ?? StackTrace.empty);
    if (this.data is T) return data(this.data as T);

    switch (connectionState) {
      case ConnectionState.none:
        return none?.call() ?? loading();

      case ConnectionState.waiting:
        return loading();

      case ConnectionState.active:
        return loading();

      case ConnectionState.done:
        return none?.call() ?? data(requireData); //throws StateError
    }
  }

  /// Returns whether this snapshot has neither data nor error.
  bool get hasNone => !hasData && !hasError;

  /// Returns whether this snapshot is computing.
  bool get isLoading =>
      connectionState == ConnectionState.waiting ||
      connectionState == ConnectionState.active;

  /// Returns whether this snapshot is computing and [hasData].
  bool get isReloading => (hasData || hasError) && isLoading;
}
