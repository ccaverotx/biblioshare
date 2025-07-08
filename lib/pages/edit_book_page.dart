import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../providers/books_provider.dart';

class EditBookPage extends ConsumerStatefulWidget {
  final Book book;

  const EditBookPage({super.key, required this.book});

  @override
  ConsumerState<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends ConsumerState<EditBookPage> {
  late final TextEditingController titleController;
  late final TextEditingController authorController;
  late final TextEditingController yearController;
  late final TextEditingController genreController;
  late final TextEditingController descriptionController;

  String? error;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.book.title);
    authorController = TextEditingController(text: widget.book.author);
    yearController = TextEditingController(
        text: widget.book.publishedYear?.toString() ?? '');
    genreController = TextEditingController(text: widget.book.genre ?? '');
    descriptionController =
        TextEditingController(text: widget.book.description ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    yearController.dispose();
    genreController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updatedData = {
      'title': titleController.text,
      'author': authorController.text,
      'publishedYear': int.tryParse(yearController.text),
      'genre': genreController.text,
      'description': descriptionController.text,
    };

    try {
      await ref
          .read(booksProvider.notifier)
          .updateBook(widget.book.id, updatedData);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar libro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
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
              onPressed: _saveChanges,
              child: const Text('Guardar cambios'),
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
