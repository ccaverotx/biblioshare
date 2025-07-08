import 'package:flutter/material.dart';
import '../db/local_database.dart';
import '../db/local_saved_books.dart';

class SavedBooksPage extends StatefulWidget {
  const SavedBooksPage({super.key});

  @override
  State<SavedBooksPage> createState() => _SavedBooksPageState();
}

class _SavedBooksPageState extends State<SavedBooksPage> {
  late Future<List<LocalSavedBook>> _savedBooksFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedBooks();
  }

  void _loadSavedBooks() {
    _savedBooksFuture = LocalDatabase.getSavedBooks();
  }

  Future<void> _removeBook(int id) async {
    await LocalDatabase.deleteSavedBook(id);
    setState(() => _loadSavedBooks());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📤 Libro eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libros guardados'),
      ),
      body: FutureBuilder<List<LocalSavedBook>>(
        future: _savedBooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay libros guardados.'));
          }

          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: book.coverUrl != null
                    ? Image.network(book.coverUrl!,
                        width: 50, fit: BoxFit.cover)
                    : const Icon(Icons.book, size: 40),
                title: Text(book.title),
                subtitle: Text('${book.author} (${book.publishedYear})'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar',
                  onPressed: () => _removeBook(book.id!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
