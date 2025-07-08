import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reviews_provider.dart';
import '../models/book.dart';
import '../db/local_database.dart';
import '../db/local_review.dart';

class AddReviewPage extends ConsumerStatefulWidget {
  final Book book;

  const AddReviewPage({super.key, required this.book});

  @override
  ConsumerState<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends ConsumerState<AddReviewPage> {
  final _controller = TextEditingController();
  String? error;
  int _rating = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final star = index + 1;
        return IconButton(
          onPressed: () {
            setState(() => _rating = star);
          },
          icon: Icon(
            Icons.star,
            color: star <= _rating ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(reviewsProvider.notifier).currentUserId;

    return Scaffold(
      appBar: AppBar(title: Text('Reseña para "${widget.book.title}"')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStarRating(),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Escribe tu reseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final content = _controller.text.trim();
                if (content.isEmpty) {
                  setState(() => error = 'La reseña no puede estar vacía');
                  return;
                }
                if (_rating == 0) {
                  setState(() => error = 'Debes seleccionar una calificación');
                  return;
                }

                try {
                  await ref.read(reviewsProvider.notifier).addReview(
                        bookId: widget.book.id,
                        content: content,
                        rating: _rating,
                      );

                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/feed');
                  }
                } catch (e) {
                  setState(() => error = e.toString());
                }
              },
              child: const Text('Publicar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final content = _controller.text.trim();
                if (content.isEmpty) {
                  setState(() => error = 'La reseña no puede estar vacía');
                  return;
                }
                if (_rating == 0) {
                  setState(() => error = 'Debes seleccionar una calificación');
                  return;
                }
                if (userId == null) {
                  setState(() => error = 'No se pudo obtener el usuario');
                  return;
                }

                final localReview = LocalReview(
                  bookId: widget.book.id,
                  content: content,
                  rating: _rating,
                  createdAt: DateTime.now(),
                  userId: userId,
                );

                await LocalDatabase.insertReview(localReview);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reseña guardada localmente')),
                  );
                }
              },
              child: const Text('Guardar localmente'),
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
