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
  /// For more details, see [AsyncSnapshotExtension.when] documentation.
  R when<R>({
    required R Function(Data data) data,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function() loading,
    R Function()? none,
    bool skipLoading = false,
  }) {
    return snapshot.when(
      skipLoading: skipLoading,
      data: data,
      error: error,
      loading: loading,
      none: none,
    );
  }

  /// Handles different states of this [snapshot] or return null.
  ///
  /// For more details, see [AsyncSnapshotExtension.whenOrNull] documentation.
  R? whenOrNull<R>({
    R Function(Data data)? data,
    R Function(Object error, StackTrace stackTrace)? error,
    R Function()? loading,
    R Function()? none,
    bool skipLoading = false,
  }) {
    return snapshot.whenOrNull(
      skipLoading: skipLoading,
      data: data,
      error: error,
      loading: loading,
      none: none,
    );
  }

  /// Handles different states of this [snapshot] or return [orElse].
  ///
  /// For more details, see [AsyncSnapshotExtension.maybeWhen] documentation.
  R maybeWhen<R>({
    R Function(Data data)? data,
    R Function(Object error, StackTrace stackTrace)? error,
    R Function()? loading,
    R Function()? none,
    required R Function() orElse,
    bool skipLoading = false,
  }) {
    return snapshot.maybeWhen(
      skipLoading: skipLoading,
      data: data,
      error: error,
      loading: loading,
      none: none,
      orElse: orElse,
    );
  }
}

/// Extension for [AsyncListenableBase] with nullable [T] or [Data].
extension AsyncListenableNullableExtension<T, Data extends T>
    on AsyncListenableBase<T?, Data?> {
  /// Returns latest value received, failing if there is no data.
  T get requireValue => value ?? snapshot.requireData!;

  /// Returns latest value received, failing if there is no data.
  @Deprecated('Use `requireValue` instead')
  T get requireData => requireValue;
}
