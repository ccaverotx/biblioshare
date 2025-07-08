import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/books_provider.dart';
import '../pages/book_search_page.dart';

class AddBookPage extends ConsumerStatefulWidget {
  const AddBookPage({super.key});

  @override
  ConsumerState<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends ConsumerState<AddBookPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final yearController = TextEditingController();
  final genreController = TextEditingController();
  final descriptionController = TextEditingController();

  String? coverUrl;
  String? error;

  void _openBookSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookSearchPage(
          onBookSelected: (bookData) {
            Navigator.pop(context, bookData);
          },
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        titleController.text = result['title'] ?? '';
        authorController.text = result['author'] ?? '';
        yearController.text = result['publishedYear']?.toString() ?? '';
        coverUrl = result['coverUrl'];
      });
    }
  }

  Future<void> _saveBook() async {
    final bookData = {
      'title': titleController.text,
      'author': authorController.text,
      'coverUrl': coverUrl,
      'publishedYear': int.tryParse(yearController.text),
      'genre': genreController.text,
      'description': descriptionController.text,
      'source': 'open_library',
      // `userId` y `createdAt` serán añadidos por el provider
    };

    try {
      await ref.read(booksProvider.notifier).addBook(bookData);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar libro'),
        actions: [
          IconButton(
            onPressed: _openBookSearch,
            icon: const Icon(Icons.search),
            tooltip: 'Buscar en Open Library',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (coverUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child:
                    Image.network(coverUrl!, height: 180, fit: BoxFit.contain),
              ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Autor'),
            ),
            TextField(
              controller: yearController,
              decoration:
                  const InputDecoration(labelText: 'Año de publicación'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: genreController,
              decoration: const InputDecoration(labelText: 'Género'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveBook,
              child: const Text('Guardar'),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
