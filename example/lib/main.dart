import 'dart:async';

import 'package:async_notifier/async_notifier.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(MainApp(notifier: TodosNotifier()));
}

class Book {
  const Book({required this.id, required this.title});
  final String title;
  final int id;

  @override
  operator ==(Object other) => other is Book && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class BookRepository {
  static final _books = {
    const Book(id: 0, title: 'The Book of Spells'),
    const Book(id: 1, title: 'The Darkhold'),
    const Book(id: 2, title: "The Hitchhiker's Guide to the Galaxy"),
    const Book(id: 3, title: 'The Dark Note'),
    const Book(id: 4, title: 'Book of Cagliostro'),
    const Book(id: 5, title: 'Tome of Stilled Tongue'),
  };

  Future<void> saveBooks(List<Book> books) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _books.clear();
    _books.addAll(books);
  }

  Stream<List<Book>> streamBooks() async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield _books.toList();
  }

  Future<List<Book>> getBooks() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return _books.toList();
  }
}

class TodosNotifier extends ChangeNotifier {
  TodosNotifier() {
    _books.addListener(notifyListeners);
  }

  final _repository = BookRepository();

  // Use `>>` to bind your ValueNotifier to this ChangeNotifier
  // Use ValueNotifier for synchronous data
  var _ascending = false;
  StreamSubscription<List<Book>>? _booksSubscription;

  // Use AsyncNotifier for asynchronous data
  final _books = AsyncNotifier<List<Book>>();

  AsyncSnapshot<List<Book>> get snapshot => _books.snapshot
      .mapData((list) => isAscending ? list : list.reversed.toList());

  bool get isAscending => _ascending;

  void toggleSort() {
    _ascending = !_ascending;
    notifyListeners();
  }

  void fetchBooks() {
    _books.future = _repository.getBooks();
  }

  void streamBooks() {
    _booksSubscription = _repository.streamBooks().listen(setBooks);
  }

  void setBooks(List<Book> books) {
    _books.value = AsyncSnapshot.withData(ConnectionState.done, books);
  }

  void addBook(Book book) {
    // repository.saveBooks([...books, book]);
    fetchBooks();
  }

  void removeBook(Book book) {}

  @override
  void dispose() {
    _books.dispose();
    _booksSubscription?.cancel();
    super.dispose();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.notifier});

  final TodosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // scaffoldMessengerKey: notifier.messengerkey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AsyncNotifier'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: notifier.fetchBooks,
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () => notifier.toggleSort(),
            ),
          ],
        ),
        body: Center(
          child: RefreshIndicator(
            onRefresh: () async => notifier.fetchBooks(),
            child: ListenableBuilder(
              listenable: notifier,
              builder: (context, _) {
                final list = notifier.snapshot.data ?? [];
                if (notifier.snapshot.isLoading) {
                  return const CircularProgressIndicator();
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final todo = list[index];

                    return ListTile(
                      title: Text(todo.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => notifier.removeBook(todo),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            notifier.addBook(
              const Book(id: 7, title: 'The 7 Wonders'),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
