import 'package:flutter/widgets.dart';

/// Extension on [AsyncSnapshot] to handle its various states
extension AsyncSnapshotExtension<T> on AsyncSnapshot<T> {
  /// Allows you to define custom behavior for different states of an [AsyncSnapshot]
  /// by providing callbacks for `data`, `error`, `loading`, `reloading`, and `idle`.
  ///
  /// - [data] Callback invoked when the snapshot contains data of type [T].
  /// - [error] Callback invoked when the snapshot contains an error.
  /// - [loading] Callback invoked when the snapshot is waiting for data.
  /// - [reloading] Optional callback invoked when the snapshot is active and contains data.
  /// - [none] Optional callback invoked when the snapshot !hasData and !hasError.
  ///
  /// Example:
  /// ```dart
  /// snapshot.when(
  ///   none: () => Text('Idle'),
  ///   data: (data) => Text('Data: $data'),
  ///   error: (error, stack) => Text('Error: $error'),
  ///   loading: () => CircularProgressIndicator(),
  ///   reloading: (data) => Text('Reloading: $data'),
  /// );
  /// ```
  /// The extension performs type checks and assertions to ensure data consistency.
  ///
  /// - `ConnectionState.active` and `ConnectionState.done` expects data of type [T].
  /// As [AsyncSnapshot] documentation states, it expects either data or error.
  R when<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function() loading,
    R Function(T data)? reloading,
    R Function()? none,
  }) {
    if (hasError) return error(this.error!, stackTrace ?? StackTrace.current);

    switch (connectionState) {
      case ConnectionState.none:
        if (this.data is! T) return none?.call() ?? loading();
        return data(this.data as T);

      case ConnectionState.waiting:
        if (this.data is! T) return loading();
        return reloading?.call(this.data as T) ?? loading();

      case ConnectionState.active:
        assert(this.data is T, _unexpectedSnapshotMessage);
        if (this.data is! T) return loading();
        return reloading?.call(this.data as T) ?? data(this.data as T);

      case ConnectionState.done:
        assert(this.data is T || none != null, _unexpectedSnapshotMessage);
        if (this.data is! T) return none?.call() ?? data(requireData);
        return data(this.data as T);
    }
  }

  String get _unexpectedSnapshotMessage =>
      'Unexpected Snapshot: Expected $T or error, but got ${data.runtimeType} on $connectionState';
}
