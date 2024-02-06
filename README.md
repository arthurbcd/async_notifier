# AsyncNotifier

A ValueNotifier for all async states. Listen, notify, and manage loading, error, and data in one place.

## Usage

`AsyncNotifier` is essentially a `ValueNotifier` with two new setters: `future` and `stream`. All it's states are resolved into an `AsyncSnapshot`. Due to it's nature, it's easily integrated with Flutter own widgets and classes, making it simple and straightforward. Two objects we all know, working together as one.

- Here's a simple overview:

```dart
import 'package:async_notifier/async_notifier.dart';

void main() {
  // Easy side effects.
  final counter = AsyncNotifier(0, onData: .., onError: ..);

  // Listenable.
  counter.addListener(() {
    print("New state: ${counter.snapshot}");
  });

  // The same ValueNotifier we all know ...
  counter.value = 1;

  // ... with two new setters:
  counter.future = Future.value(42);
  counter.stream = Stream.fromIterable([1, 2, 3]);

  // Get all async states in 1 place:
  counter.isLoading
  counter.isReloading
  counter.future
  counter.stream
  counter.requireValue
  counter.hasData
  counter.hasError
  counter.error
  counter.stackTrace

  // Control its states:
  counter.cancel(); // works for future!
  counter.dispose();

  // And resolve them with ease:
  final result = counter.when(
    data: (data) => 'Data $data',
    error: (error, stackTrace) => 'Error $error',
    loading () => 'Loading',
  );
}
```

### Benefits

- Simplified State Management: No need to manually manage separate variables for loading, error, data states and more.
- Easy to Use: Just set the `future` or `stream` and let `AsyncNotifier` handle the rest.
- Reactive: Automatically notifies listeners when the each state changes

### Advanced

Internally, `AsyncNotifier<T>` is an implementation of `AsyncListenableBase<T,Data>`.

Where:

- `T` is the `ValueNotifier<T>`
- `Data` is the `AsyncSnapshot<Data>`
- `Data` extends `T`

So when you are typing `AsyncNotifier<T>` you are also typing `Data` as `T`.

Which is good, and works well with non-nullables like `AsyncNotifier(0)`. But there are cases where you don't have an initial value, and you'd have to do `AsyncNotifier<User?>(null)`.

Doing this will also type the internal `Data` type as `Data?`, resulting in all your getters to be nullable. Ex: `Future<User?>` instead of `Future<User>`, which is bad for type safety.

For those cases use `AsyncNotifier.late<T>`.

The late constructor is an implementation of `AsyncListenableBase<T?, Data>`, which allows you
to work with an optional initial value and later with a non-nullable `Data` in all your async operations!

- TLDR:

```dart
// use AsyncNotifier<T> for value T and data T.
final todos = AsyncNotifier(<Todo>[]);

// use AsyncNotifier.late<T> for value T? and data T.
final user = AsyncNotifier.late<User>();
```

### State Management

You can listen to all AsyncNotifier states directly and bind it to other objects.

```dart
class MyNotifier extends ChangeNotifier {
  MyNotifier() {
    _todos.addListener(notifyListeners); // notifies ChangeNotifier

    getTodos(); // init
  }

  final _todos = AsyncNotifier(<Todo>[]);

  AsyncListenable<List<Todo>> get todosListenable => _todos;

  List<Todo> get todos => _todos.value.toList(); // copy

  void getTodos() {
    _todos.future = _repository.getAllTodos();
  }

  void addTodo(Todo todo) {
    _todos.value = todos..add(todo);
  }

}
```

### Consuming the State

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

        // Use `when` for resolving AsyncNotifier states.
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
    final todosListenable = context.watch<MyNotifier>().todosListenable;

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
