// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/foundation.dart';

///
extension ListenableSyncExtension<T extends Listenable> on T {
  /// Sends notifications to a [ChangeNotifier].
  T operator >>(ChangeNotifier other) {
    addListener(other.notifyListeners);
    return this;
  }
}

///
extension ChangeNotifierSyncExtension<T extends ChangeNotifier> on T {
  /// Receives notifications from a [Listenable].
  T operator <<(Listenable other) {
    other.addListener(notifyListeners);
    return this;
  }
}
