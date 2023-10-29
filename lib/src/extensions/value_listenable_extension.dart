import 'package:flutter/foundation.dart';

import '../async_notifier_base.dart';
import '../async_notifier_impl.dart';

/// Extension adapter for [ValueListenable].
extension AsyncValueListenableExtension<T> on ValueListenable<T> {
  /// Creates [AsyncNotifier] with value `T` and async data `T`.
  AsyncNotifier<T> asAsync({
    DataChanged<T>? onData,
    ErrorCallback? onError,
  }) {
    return AsyncNotifier(value, onData: onData, onError: onError);
  }

  /// Creates [AsyncNotifierLate] with value `T?` and async data `T`.
  AsyncNotifierLate<T> asAsyncLate({
    DataChanged<T>? onData,
    ErrorCallback? onError,
  }) {
    return AsyncNotifierLate(value: value, onData: onData, onError: onError);
  }

  /// Listens to [ValueListenable] and returns a [VoidCallback] remover.
  ///
  /// Example:
  /// ```dart
  /// final notifier = ValueNotifier(0);
  ///
  /// final remover = notifier.listen((value) => print(value));
  /// notifier.value = 1; // prints 1
  ///
  /// remover(); // removes the listener
  /// notifier.value = 2; // does not print
  /// ```
  VoidCallback listen(ValueChanged<T> onValue) {
    void listener() {
      onValue(value);
    }

    addListener(listener);
    return () => removeListener(listener);
  }
}
