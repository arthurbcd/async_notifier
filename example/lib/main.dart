import 'dart:async';

import 'package:async_notifier/async_notifier.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MainApp(notifier: BooksNotifier()));
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

  Future<void> addBook(Book book) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _books.add(book);
  }

  Future<void> removeBook(Book book) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _books.remove(book);
  }

  Stream<List<Book>> streamBooks() async* {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    yield _books.toList();
  }

  Future<List<Book>> getBooks() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _books.toList();
  }
}

class BooksNotifier extends ChangeNotifier {
  BooksNotifier() {
    _books.addListener(notifyListeners);
  }

  final _repository = BookRepository();

  // states
  final _books = AsyncNotifier<List<Book>>();
  var _ascending = false;

  AsyncSnapshot<List<Book>> get books => _books.snapshot.whenData(_sorted);

  List<Book> _sorted(List<Book> books) {
    final list = [...books];
    list.sort((a, b) =>
        isAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    return list;
  }

  bool get isAscending => _ascending;

  void toggleSort() {
    _ascending = !_ascending;
    notifyListeners();
  }

  Future<void> fetchBooks() => _books.future = _repository.getBooks();

  Stream<void> streamBooks() => _books.stream = _repository.streamBooks();

  Future<void> addBook(Book book) async {
    await _repository.addBook(book).whenComplete(fetchBooks);
  }

  Future<void> removeBook(Book book) async {
    await _repository.removeBook(book).whenComplete(fetchBooks);
  }

  @override
  void dispose() {
    _books.dispose();
    super.dispose();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.notifier});
  final BooksNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: notifier.fetchBooks,
                  child: ListenableBuilder(
                    listenable: notifier,
                    builder: (context, _) {
                      final list = notifier.books.data ?? [];
                      if (notifier.books.isLoading &&
                          !notifier.books.isReloading) {
                        return const CircularProgressIndicator();
                      }
                      return Stack(
                        children: [
                          if (notifier.books.isReloading)
                            const Align(
                              alignment: Alignment.topCenter,
                              child: LinearProgressIndicator(),
                            ),
                          ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final book = list[index];

                              return ListTile(
                                title: Text(book.title),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => notifier.removeBook(book),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
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
