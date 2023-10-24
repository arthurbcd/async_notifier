import 'package:async_notifier/async_notifier.dart';
import 'package:flutter/material.dart';

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

  Future<List<Book>> fetchBooks() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return _books.toList();
  }
}

class TodosNotifier extends ChangeNotifier {
  TodosNotifier() {
    _books.addListener(notifyListeners);
    fetchBooks();
  }

  final _repository = BookRepository();
  final messengerkey = GlobalKey<ScaffoldMessengerState>();

  // all async states
  late final _books = AsyncNotifier(<Book>[], onData: _onData);

  void _onData(List<Book> books) async {
    await _repository.saveBooks(books);
    messengerkey.currentState?.showSnackBar(
      const SnackBar(content: Text('Saved books with success!')),
    );
  }

  List<Book> get books => _books.value.toList();

  String? get errorMessage => _books.error?.toString();

  bool get isLoading => _books.isLoading;

  void fetchBooks() {
    _books.stream = _repository.streamBooks();
  }

  void streamBooks() {
    _books.future = _repository.fetchBooks();
  }

  void addBook(Book book) {
    _books.value = books..add(book);
  }

  void removeBook(Book book) {
    _books.value = books..remove(book);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.notifier});

  final TodosNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: notifier.messengerkey,
      home: Scaffold(
        body: Center(
          child: RefreshIndicator(
            onRefresh: () async => notifier.fetchBooks(),
            child: ListenableBuilder(
                listenable: notifier,
                builder: (context, _) {
                  if (notifier.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ListView.builder(
                    itemCount: notifier.books.length,
                    itemBuilder: (context, index) {
                      final todo = notifier.books[index];

                      return ListTile(
                        title: Text(todo.title),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => notifier.removeBook(todo),
                        ),
                      );
                    },
                  );
                }),
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
