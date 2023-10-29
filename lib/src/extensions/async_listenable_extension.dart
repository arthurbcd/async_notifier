import 'package:flutter/widgets.dart';

import '../../async_notifier.dart';
import '../async_listenable_base.dart';
import 'async_snapshot_extension.dart';

/// Extension for [AsyncListenableBase].
extension AsyncListenableBaseExtension<T, Data extends T>
    on AsyncListenableBase<T, Data> {
  /// Returns whether [future] or [stream] is computing.
  bool get isLoading => snapshot.isLoading;

  /// Returns whether [future] or [stream] is computing and [hasData].
  bool get isReloading => snapshot.isReloading;

  /// Returns whether [future] or [stream] has an error.
  bool get hasError => snapshot.hasError;

  /// Returns whether [future] or [stream] has data.
  bool get hasData => snapshot.hasData;

  /// Returns whether this snapshot has neither data nor error.
  bool get hasNone => snapshot.hasNone;

  /// The current error of [future] or [stream].
  Object? get error => snapshot.error;

  /// The current [StackTrace] of [future] or [stream].
  StackTrace? get stackTrace => snapshot.stackTrace;

  /// The current [ConnectionState] of [future] or [stream].
  ConnectionState get connectionState => snapshot.connectionState;

  /// Handles different states of this [snapshot].
  ///
  /// For more details, see the documentation for [AsyncSnapshotExtension.when].
  R when<R>({
    required R Function(Data data) data,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function() loading,
    R Function()? none,
  }) {
    return snapshot.when(
      data: data,
      error: error,
      loading: loading,
      none: none,
    );
  }
}

/// Extension for [AsyncListenableBase] with nullable [T] or [Data].
extension AsyncListenableNullableExtension<T, Data extends T>
    on AsyncListenableBase<T?, Data?> {
  /// Returns latest data received, failing if there is no data.
  T get requireData => value ?? snapshot.requireData!;
}
