import 'package:biblioshare/pages/book_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/books_provider.dart';
//import 'edit_book_page.dart';

class BookListPage extends ConsumerWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis libros 📚')),
      body: booksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return const Center(child: Text('No hay libros aún.'));
          }
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: book.coverUrl != null
                    ? Image.network(book.coverUrl!,
                        width: 40, fit: BoxFit.cover)
                    : const Icon(Icons.book),
                title: Text(book.title),
                subtitle: Text('Autor: ${book.author}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //IconButton(
                    //  icon: const Icon(Icons.edit, color: Colors.blue),
                    //  onPressed: () {
                    //    Navigator.push(
                    //      context,
                    //      MaterialPageRoute(
                    //        builder: (_) => EditBookPage(book: book),
                    //      ),
                    //    );
                    //  },
                    //),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: Text('¿Eliminar "${book.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(booksProvider.notifier)
                              .deleteBook(book.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (_) => BookSearchPage(
                onBookSelected: (bookData) {
                  Navigator.pop(context, bookData);
                },
              ),
            ),
          );

          if (result != null && context.mounted) {
            final books = ref.read(booksStreamProvider).value ?? [];

            final alreadyExists = books.any((b) =>
                b.title.toLowerCase().trim() ==
                    result['title'].toString().toLowerCase().trim() &&
                b.author.toLowerCase().trim() ==
                    result['author'].toString().toLowerCase().trim());

            if (alreadyExists) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('⚠️ Este libro ya está en tu lista.')),
              );
              return;
            }

            try {
              await ref.read(booksProvider.notifier).addBook({
                'title': result['title'],
                'author': result['author'],
                'coverUrl': result['coverUrl'],
                'publishedYear': result['publishedYear'],
                'source': 'open_library',
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📚 Libro agregado exitosamente')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al guardar: $e')),
              );
            }
          }
        },
        tooltip: 'Buscar y agregar libro',
        child: const Icon(Icons.search),
      ),
    );
  }
}
