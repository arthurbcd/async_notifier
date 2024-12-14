import 'package:flutter/foundation.dart';

import '../async_notifier.dart';

/// Extension adapter for [ValueListenable].
extension AsyncValueListenableExtension<T> on ValueListenable<T> {
  /// Creates [AsyncNotifier] with value `T` and async data `T`.
  AsyncNotifier<T> asAsync({bool? cancelOnError}) {
    return AsyncNotifier(data: value, cancelOnError: cancelOnError);
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
