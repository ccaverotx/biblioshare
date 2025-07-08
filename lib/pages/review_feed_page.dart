import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/reviews_provider.dart';
import '../models/review.dart';

class ReviewsFeedPage extends ConsumerWidget {
  const ReviewsFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(reviewsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas públicas')),
      body: reviews.isEmpty
          ? const Center(child: Text('No hay reseñas todavía'))
          : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final Review review = reviews[index];
                return FutureBuilder<Map<String, String>>(
                  future: _getBookInfo(review.bookId),
                  builder: (context, snapshot) {
                    final bookInfo = snapshot.data ??
                        {'title': '[Cargando título]', 'author': '[...]'};

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          bookInfo['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Autor: ${bookInfo['author']}',
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            _buildRatingStars(review.rating),
                            const SizedBox(height: 4),
                            Text(review.content),
                            const SizedBox(height: 4),
                            Text('por: ${review.userEmail}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Text(
                          _formatDate(review.createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<Map<String, String>> _getBookInfo(String bookId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();
      final data = doc.data() ?? {};
      return {
        'title': data['title'] ?? '[Sin título]',
        'author': data['author'] ?? '[Sin autor]',
      };
    } catch (e) {
      return {
        'title': '[Error al obtener título]',
        'author': '[Error]',
      };
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
}
