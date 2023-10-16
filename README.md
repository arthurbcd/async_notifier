# AsyncNotifier

A ValueNotifier extension for all async states. Listen, notify, and manage loading, error, and data in one place.

## Usage

`AsyncNotifier` is essentially a `ValueNotifier` with two new setters: `future` and `stream`. All it's states are resolved into an `AsyncSnapshot`. Due to it's nature, it's easily integrated with Flutter own widgets and classes, making it simple and native.

Here's a simple overview example to demonstrate how to use `AsyncNotifier`.

```dart
import 'package:async_notifier/async_notifier.dart';

void main() {
  // easy side effects.
  final notifier = AsyncNotifier(0, onData: (data) {}, onError: (e,s) {});

  // listen to all snapshots.
  notifier.addListener(() {
    print("New state: ${notifier.snapshot}");
  });

  // Set a Future
  notifier.future = Future.value(42);

  await notifier.future.then(print); // 42
  print (notifier.value) // 42

  // Set a Stream
  notifier.stream = Stream.fromIterable([1, 2, 3]);
}
```

### Benefits

- Simplified State Management: No need to manually manage separate variables for loading, error, and data states.
- Easy to Use: Just set the Future or Stream and let AsyncNotifier handle the rest.
- Reactive: Automatically notifies listeners when the state changes

### State Management

You can listen to all AsyncNotifier states directly and bind it to other objects.

```dart
class MyNotifier extends ChangeNotifier {
  MyNotifier() {
    // binds to ChangeNotifier to propagate its changes.
    _todos.addListener(notifyListeners);
  }

  final _todos = AsyncNotifier(<Todo>[]);

  //all states
  bool get isLoading => _todos.isLoading;
  Future<List<Todo>> get todosFuture => _todos.future;
  Stream<List<Todo>> get todosStream => _todos.stream;
  Object? get error => _todos.error;

  //or as listenable
  AsyncListenable<List<Todo>> get todosListenable => _todos;
  List<Todo> todos => _todos.value.toList(); // copy.

  void addTodo(Todo todo) {
    _todos.value = todos..add(todo);
  }

  void getTodos() {
    _todos.future = _repository.getAllTodos();
  }
}
```

### Consuming the state

You can use Flutter native solutions like `ListenableBuilder`.

```dart
class TodoList extends StatelessWidget {
  const TodoList({super.key, required this.todosListenable});

  final AsyncListenable<List<Todo>> todosListenable;

  @override
  Widget build(BuildContext context) {

    // This Flutter builder rebuilds whenever our AsyncNotifier changes.
    return ListenableBuilder(
      listenable: todosListenable,
      builder: (context, _) {

        // Use `when` for resolving AsyncSnapshot states.
        return todosListenable.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Text('Error: $error'),
          data: (data) => ListView.builder(
            itemCount: todosListenable.value.length,
            itemBuilder: (context, index) => Text(data[index].title),
          ),
        );
      },
    );
  }
}
```

With provider:

```dart
class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todosListenable = context.watch<AsyncListenable<List<Todo>>>;

    // Use `when` for resolving AsyncSnapshot states.
    return todosListenable.when(
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
