import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/reviews_provider.dart';
import '../db/local_database.dart';
import '../db/local_review.dart';

class MyReviewsPage extends ConsumerStatefulWidget {
  const MyReviewsPage({super.key});

  @override
  ConsumerState<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends ConsumerState<MyReviewsPage> {
  List<LocalReview> localReviews = [];

  @override
  void initState() {
    super.initState();
    _loadLocalReviews();
  }

  Future<void> _loadLocalReviews() async {
    final userId = ref.read(reviewsProvider.notifier).currentUserId;
    final allReviews = await LocalDatabase.getAllReviews();
    setState(() {
      localReviews = allReviews.where((r) => r.userId == userId).toList();
    });
  }

  Future<String> _getBookTitle(String bookId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();
      return doc.data()?['title'] ?? '[Título no encontrado]';
    } catch (_) {
      return '[Error al obtener título]';
    }
  }

  Future<void> _showEditDialog({
    required String initialText,
    required int initialRating,
    required Function(String newText, int newRating) onConfirm,
  }) async {
    final controller = TextEditingController(text: initialText);
    int rating = initialRating;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Editar reseña'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: star <= rating ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () => setDialogState(() => rating = star),
                    );
                  }),
                ),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  final newText = controller.text.trim();
                  if (newText.isNotEmpty && rating > 0) {
                    onConfirm(newText, rating);
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      await _loadLocalReviews();
    }
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          size: 16,
          color: index < rating ? Colors.amber : Colors.grey,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(reviewsProvider);
    final userId = ref.read(reviewsProvider.notifier).currentUserId;
    final myCloudReviews = reviews.where((r) => r.userId == userId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis reseñas ✍️')),
      body: ListView(
        children: [
          if (myCloudReviews.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('📡 Reseñas en línea',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ...myCloudReviews.map((review) => ListTile(
                title: Text(
                  review.bookTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRatingStars(review.rating),
                    const SizedBox(height: 4),
                    Text(review.content),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Editar reseña',
                      onPressed: () {
                        _showEditDialog(
                          initialText: review.content,
                          initialRating: review.rating,
                          onConfirm: (newText, newRating) async {
                            await ref.read(reviewsProvider.notifier).editReview(
                                  id: review.id,
                                  newContent: newText,
                                  newRating: newRating,
                                );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Eliminar reseña',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('¿Eliminar reseña?'),
                            content: Text('Contenido:\n"${review.content}"'),
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
                              .read(reviewsProvider.notifier)
                              .deleteReview(review.id);
                        }
                      },
                    ),
                  ],
                ),
              )),
          if (localReviews.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('📥 Reseñas guardadas localmente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ...localReviews.map((review) => FutureBuilder<String>(
                future: _getBookTitle(review.bookId),
                builder: (context, snapshot) {
                  final title = snapshot.data ?? '[Cargando título...]';
                  return ListTile(
                    title: Text('[local] $title',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRatingStars(review.rating),
                        const SizedBox(height: 4),
                        Text(review.content),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Editar reseña',
                          onPressed: () {
                            _showEditDialog(
                              initialText: review.content,
                              initialRating: review.rating,
                              onConfirm: (newText, newRating) async {
                                await LocalDatabase
                                    .updateReviewContentAndRating(
                                  id: review.id!,
                                  newContent: newText,
                                  newRating: newRating,
                                );
                                await _loadLocalReviews();
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar reseña local',
                          onPressed: () async {
                            await LocalDatabase.deleteReview(review.id!);
                            await _loadLocalReviews();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cloud_upload,
                              color: Colors.green),
                          tooltip: 'Publicar en línea',
                          onPressed: () async {
                            try {
                              await ref
                                  .read(reviewsProvider.notifier)
                                  .addReview(
                                    bookId: review.bookId,
                                    content: review.content,
                                    rating: review.rating,
                                  );
                              await LocalDatabase.deleteReview(review.id!);
                              await _loadLocalReviews();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Reseña publicada')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error al publicar: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/select_book');
        },
        icon: const Icon(Icons.edit),
        label: const Text('Escribir reseña'),
      ),
    );
  }
}
