# AsyncNotifier

A ValueNotifier for all async states. Listen, notify, and manage loading, error, and data in one place.

## Usage

`AsyncNotifier` is essentially a `ValueNotifier` with two new setters: `future` and `stream`. All it's states are resolved into an `AsyncSnapshot`. Due to it's nature, it's easily integrated with Flutter own widgets and classes, making it simple and straightforward. Two objects we all know, working together as one.

- Here's a simple overview:

```dart
import 'package:async_notifier/async_notifier.dart';

void main() {
  // No initial value needed. Defaults to AsyncSnapshot.nothing().
  final counter = AsyncNotifier<int>();

  // Listenable.
  counter.addListener(() {
    print("New state: ${counter.snapshot}");
  });

  // You can set a future or stream.
  counter.future = Future.value(42);
  counter.stream = Stream.fromIterable([1, 2, 3]);

  // And get its snapshot.
  final AsyncSnapshot<int> snapshot = counter.snapshot;

  // Check its states with extensions:
  snapshot.isLoading
  snapshot.isReloading
  snapshot.requireData
  snapshot.hasData
  snapshot.hasError
  snapshot.hasNone
  snapshot.error
  snapshot.stackTrace

  // Control its future or stream:
  counter.cancel(); // works for future!
  counter.dispose();

  // And resolve them with ease:
  final result = counter.when(
    data: (data) => 'Data $data',
    error: (error, stackTrace) => 'Error $error',
    loading () => 'Loading',
  );

  // Or even:
  final result = switch (snapshot) {
    AsyncSnapshot(:var data?) => 'Data $data',
    AsyncSnapshot(:var error?) => 'Error $error', 
    _ => 'Loading',
  }
}
```

### Benefits

- Simplified State Management: Resolves the Future and Stream states in the view model layer.
- Easy to Use: Just set the `future` or `stream` and let `AsyncNotifier` handle the rest.
- Reactive: Automatically notifies listeners when the each state changes.

### State Management

You can listen to all AsyncNotifier states directly and bind it to other objects.

```dart
class TodosNotifier extends ChangeNotifier {
  TodosNotifier() {
    _todos.addListener(notifyListeners);
    fetchTodos();
  }

  final _todos = AsyncNotifier<List<Todo>>();

  AsyncSnapshot<List<Todo>> get todosSnapshot => _todos.snapshot;

  void fetchTodos() {
    _todos.future = _repository.fetchTodos();
  }

  void dispose() {
    _todos.dispose();
    super.dispose();
  }
}
```

### Consuming the State

You can use Flutter native solutions like `ListenableBuilder`.

```dart
class TodoList extends StatelessWidget {
  const TodoList({super.key, required this.todosNotifier});
  final TodosNotifier todosNotifier;

  @override
  Widget build(BuildContext context) {

    // This Flutter builder rebuilds whenever our AsyncNotifier changes.
    return ListenableBuilder(
      listenable: todosNotifier,
      builder: (context, _) {

        // Use `when` for resolving AsyncNotifier states.
        return todosNotifier.snapshot.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Text('Error: $error'),
          data: (data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => Text(data[index].title),
          ),
        );
      },
    );
  }
}
```

With `provider`:

```dart
class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todosSnapshot = context.watch<TodosNotifier>().snapshot;

    // Use `when` for resolving AsyncSnapshot states.
    return todosSnapshot.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
      data: (data) => ListView.builder(
        itemCount: todosListenable.value.length,
        itemBuilder: (context, index) => Text(data[index].title),
      ),
    );
  }
}
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
