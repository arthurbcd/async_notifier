import 'package:flutter/widgets.dart';

/// Extension on [AsyncSnapshot] to handle its various states
extension AsyncSnapshotExtension<T> on AsyncSnapshot<T> {
  /// Allows you to define custom behavior for different states of an [AsyncSnapshot]
  /// by providing callbacks for `data`, `error`, `loading`, and `none`.
  ///
  /// - [data] Callback invoked when the snapshot contains data of type [T].
  /// - [error] Callback invoked when the snapshot contains an error.
  /// - [loading] Callback invoked when the snapshot is waiting for data.
  /// - [none] Optional callback invoked when the snapshot has no data or error.
  ///
  /// Example:
  /// ```dart
  /// snapshot.when(
  ///   none: () => Text('No error or data'),
  ///   data: (data) => Text('Data: $data'),
  ///   error: (error, stack) => Text('Error: $error'),
  ///   loading: () => CircularProgressIndicator(),
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
        return none?.call() ?? data(requireData);
    }
  }

  /// Returns whether this snapshot has neither data nor error.
  bool get hasNone => !hasData && !hasError;
}
