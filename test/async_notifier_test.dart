// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:async_notifier/async_notifier.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AsyncNotifier.value', () {
    int? data = 0;
    final n = AsyncNotifier.late<int>(value: data, onData: (d) => data = d);
    expect(data, 0);
    expect(n.value, 0);
    expect(n.snapshot, const AsyncSnapshot.withData(ConnectionState.none, 0));

    n.value = 1;
    expect(data, 1);
    expect(n.value, 1);
    expect(n.snapshot, const AsyncSnapshot.withData(ConnectionState.none, 1));

    n.value = null;
    expect(data, null);
    expect(n.value, null);
    expect(n.snapshot, const AsyncSnapshot<int>.nothing());
  });

  group('AsyncNotifier.future', () {
    int? data;
    final n = AsyncNotifier.late<int>(onData: (d) => data = d);
    // final b = ValueNotifier(data).asAsync<int>();
    test('ConnectionState.none', () async {
      expect(data, null);
      expect(n.value, null);
      expect(n.isLoading, false);
      expect(n.snapshot, const AsyncSnapshot<int>.nothing());
    });

    test('ConnectionState.waiting', () async {
      n.future = Future.delayed(const Duration(milliseconds: 100), () => 1);
      expect(data, null);
      expect(n.value, null);
      expect(n.isLoading, true);
      expect(n.snapshot, const AsyncSnapshot<int>.waiting());
    });

    test('ConnectionState.done', () async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(data, 1);
      expect(n.value, 1);
      expect(n.snapshot, AsyncSnapshot.withData(ConnectionState.done, data));
    });
  });

  test('AsyncNotifier.future with error', () async {
    final e = Error();
    bool? data;
    Object? error;
    StackTrace? stackTrace;

    final n = AsyncNotifier.late<bool>(
      onData: (d) => data = d,
      onError: (e, s) {
        error = e;
        stackTrace = s;
      },
    );

    n.future = Future.delayed(const Duration(seconds: 1), () => throw e);
    expect(data, null);
    expect(n.value, null);
    expect(n.isLoading, true);
    expect(n.hasError, false);
    expect(n.error, null);
    expect(n.connectionState, ConnectionState.waiting);
    expect(n.snapshot, const AsyncSnapshot<bool>.waiting());

    await Future<void>.delayed(const Duration(seconds: 1));
    expect(data, null);
    expect(n.value, null);
    expect(n.isLoading, false);
    expect(n.hasError, true);
    expect(n.error, error);
    expect(n.error, isA<Error>());
    expect(n.connectionState, ConnectionState.done);

    final snapshotWithError = AsyncSnapshot<bool>.withError(
      ConnectionState.done,
      error!,
      stackTrace!,
    );
    expect(n.snapshot, snapshotWithError);
  });

  test('AsyncNotifier.future with new future', () async {
    int? data;
    final n = AsyncNotifier.late<int>(onData: (d) => data = d);

    // First future.
    n.future = Future.delayed(const Duration(milliseconds: 100), () => 1);
    expect(data, null);
    expect(n.value, null);
    expect(n.isLoading, true);
    expect(n.snapshot, const AsyncSnapshot<int>.waiting());

    // Second future.
    n.future = Future.delayed(const Duration(milliseconds: 200), () => 2);
    expect(data, null);
    expect(n.value, null);
    expect(n.isLoading, true);
    expect(n.snapshot, const AsyncSnapshot<int>.waiting());

    // First future has no time to complete. It's overriden by second future.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(data, isNot(1));
    expect(n.value, isNot(1));
    expect(n.isLoading, true);
    expect(n.snapshot, const AsyncSnapshot<int>.waiting());

    // Second future completes normally.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(data, 2);
    expect(n.value, 2);
    expect(n.isLoading, false);
    expect(n.snapshot, AsyncSnapshot.withData(ConnectionState.done, data));
  });

  group('AsyncNotifier.stream', () {
    int? data;
    final n = AsyncNotifier.late<int>(onData: (d) => data = d);
    test('ConnectionState.none', () async {
      expect(data, null);
      expect(n.value, null);
      expect(n.isLoading, false);
      expect(n.snapshot, const AsyncSnapshot<int>.nothing());
    });

    test('ConnectionState.waiting', () async {
      /// will stream 0, 1, 2
      n.stream = Stream.periodic(const Duration(seconds: 1), (i) => i).take(3);
      expect(data, null);
      expect(n.value, null);
      expect(n.isLoading, true);
      expect(n.snapshot, const AsyncSnapshot<int>.waiting());
    });

    test('ConnectionState.active', () async {
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(data, 1);
      expect(n.value, 1);
      expect(n.snapshot, AsyncSnapshot.withData(ConnectionState.active, data));
    });

    test('ConnectionState.done', () async {
      await Future<void>.delayed(const Duration(seconds: 3));
      expect(data, 2);
      expect(n.value, 2);
      expect(n.snapshot, AsyncSnapshot.withData(ConnectionState.done, data));
    });
  });

  test('AsyncNotifier.stream with error', () async {
    final e = Object();
    int? data;
    Object? error;
    StackTrace? stackTrace;
    final controller = StreamController<int>();

    final n = AsyncNotifier.late<int>(
      onData: (d) => data = d,
      onError: (e, s) {
        error = e;
        stackTrace = s;
      },
    );

    n.stream = controller.stream;

    expect(data, null);
    expect(n.value, null);
    expect(n.isLoading, true);
    expect(n.hasError, false);
    expect(n.error, null);
    expect(n.connectionState, ConnectionState.waiting);
    expect(n.snapshot, const AsyncSnapshot<int>.waiting());

    controller.add(1);
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(data, 1);
    expect(n.value, 1);
    expect(n.isReloading, true);
    expect(n.hasError, false);
    expect(n.error, null);
    expect(n.connectionState, ConnectionState.active);
    expect(n.snapshot, AsyncSnapshot.withData(ConnectionState.active, data));

    controller.addError(e);
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(data, 1);
    expect(n.value, 1);
    expect(n.isLoading, true);
    expect(n.hasError, true);
    expect(n.error, error);
    expect(n.connectionState, ConnectionState.active);

    final snapshotWithError = AsyncSnapshot<int>.withError(
      ConnectionState.active,
      error!,
      stackTrace!,
    );
    expect(n.snapshot, snapshotWithError);

    controller.add(2);
    await controller.close();

    await Future<void>.delayed(const Duration(seconds: 1));

    expect(data, 2);
    expect(n.value, 2);
    expect(n.isLoading, false);
    expect(n.hasError, false);
    expect(n.error, null);
    expect(n.connectionState, ConnectionState.done);
    expect(n.snapshot, AsyncSnapshot.withData(ConnectionState.done, data));
  });

  test('AsyncNotifier.stream with new stream', () async {
    int? data;
    final error = Error();
    final completer = Completer<void>();

    final n = AsyncNotifier.late<int>(
      onData: (d) => data = d,
      onError: (error, stackTrace) {
        completer.complete();
      },
    );

    // First stream.
    n.stream = Stream.periodic(const Duration(seconds: 1), (_) => throw error);
    expect(data, null);
    expect(n.value, null);
    expect(n.isLoading, true);
    expect(n.snapshot, const AsyncSnapshot<int>.waiting());

    // Second stream.
    n.stream = Stream.periodic(const Duration(seconds: 1), (i) => 1).take(1);
    expect(data, null);
    expect(n.value, null);
    expect(n.isLoading, true);
    expect(n.snapshot, const AsyncSnapshot<int>.waiting());

    // First stream has no time to throw. It's overriden by second stream.
    await Future<void>.delayed(const Duration(seconds: 1));
    expect(data, 1);
    expect(n.value, 1);
    expect(n.error, isNot(error));
    expect(n.hasError, false);
    expect(n.isLoading, true);
    expect(n.isReloading, true);
    expect(n.snapshot, AsyncSnapshot.withData(ConnectionState.active, data));

    await Future<void>.delayed(const Duration(seconds: 1));
    expect(n.snapshot, AsyncSnapshot.withData(ConnectionState.done, data));

    // Error never called.
    expect(completer.isCompleted, false);
  });

  test('AsyncNotifier.when', () async {
    final state = AsyncNotifier.late<String>();

    String when() {
      return state.when(
        skipLoading: true,
        data: (data) => '${state.isReloading ? 'reloading' : 'data'}: $data',
        error: (e, s) => 'error $e',
        loading: () => 'loading',
        none: () => 'none',
      );
    }

    expect(when(), 'none');

    state.future = Future.value('✅');
    expect(when(), 'loading');

    await state.future;
    expect(when(), 'data: ✅');

    state.stream = Stream.value('🔁');
    expect(when(), 'reloading: ✅');

    await state.stream!.single;
    expect(when(), 'data: 🔁');

    state.future = Future.error('❌');
    expect(when(), 'reloading: 🔁');

    await state.future!.catchError((_) => '');
    expect(when(), 'error ❌');

    state.future = null;
    expect(when(), 'data: 🔁');

    state.value = null;
    expect(when(), 'none');
    expect(state.hasNone, true);

    state.stream = const Stream.empty();
    expect(when(), 'loading');

    await state.stream?.toList();
    expect(when(), 'none');

    state.stream = Stream.error('❌');
    expect(when(), 'loading');

    await state.stream!.single.catchError((_) => '');
    expect(when(), 'error ❌');
  });

  test('AsyncNotifier.when nullable', () async {
    final state = AsyncNotifier<String?>(null);

    String when() {
      return state.when(
        skipLoading: true,
        data: (data) => '${state.isReloading ? 'reloading' : 'data'}: $data',
        error: (e, s) => 'error $e',
        loading: () => 'loading',
        none: () => 'none',
      );
    }

    expect(when(), 'none');

    state.future = Future.value('✅');
    expect(when(), 'loading');

    await state.future;
    expect(when(), 'data: ✅');

    state.stream = Stream.value('🔁');
    expect(when(), 'reloading: ✅');

    await state.stream!.single;
    expect(when(), 'data: 🔁');

    state.future = Future.error('❌');
    expect(when(), 'reloading: 🔁');

    await state.future!.catchError((_) => '');
    expect(when(), 'error ❌');

    state.future = null;
    expect(when(), 'data: 🔁');

    state.value = null;
    expect(when(), 'none');
    expect(state.hasNone, true);

    state.stream = const Stream.empty();
    expect(when(), 'loading');

    await state.stream?.toList();
    expect(when(), 'data: null');

    state.stream = Stream.error('❌');
    expect(when(), 'loading');

    await state.stream!.single.catchError((_) => '');
    expect(when(), 'error ❌');
  });

  test('AsyncNotifier.when <void>', () async {
    final state = AsyncNotifier.late<void>();

    String when() {
      return state.when(
        skipLoading: true,
        data: (_) => '${state.isReloading ? 'reloading' : 'data'}: ✅',
        error: (e, s) => '${state.isReloading ? 'reloading' : 'error'}: $e',
        loading: () => 'loading',
        none: () => 'none',
      );
    }

    expect(when(), 'none');

    state.future = Future.value();
    expect(when(), 'loading');

    await state.future;
    expect(when(), 'data: ✅');

    state.future = Future.error('❌');
    expect(when(), 'loading');

    await state.future!.catchError((_) => '');
    expect(when(), 'error: ❌');

    // settings a new Future resets, so it's loading again.
    // ? maybe it should be reloading
    state.future = Future.error('❌❌');
    expect(when(), 'reloading: ❌');

    await state.future!.catchError((_) => '');
    expect(when(), 'error: ❌❌');

    state.future = null;
    expect(when(), 'none');

    state.value = null;
    expect(when(), 'none');
    expect(state.hasNone, true);
  });

  group('extension', () {
    final state = ValueNotifier(0);
    test('ValueNotifier.setValue', () {
      expect(state.value, 0);
      state.setValue(1);
      expect(state.value, 1);
    });

    test('ValueListenable.listen', () {
      num count = 0;
      expect(state.hasListeners, false);

      final remover = state.listen((n) => count = n);
      expect(state.hasListeners, true);

      state.value = 2;
      expect(count, 2);

      remover();
      expect(state.hasListeners, false);
    });

    test('Listenable.sync', () {
      var called = 0;
      final notifier = ChangeNotifier();
      notifier.addListener(() => called++);

      final state = ValueNotifier(false).sync(notifier);
      expect(called, 0);
      expect(state.value, false);

      state.value = true;
      expect(called, 1);
      expect(state.value, true);
    });
  });
}
