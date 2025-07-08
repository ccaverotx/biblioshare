import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/review.dart';

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, List<Review>>((ref) {
  return ReviewsNotifier();
});

class ReviewsNotifier extends StateNotifier<List<Review>> {
  ReviewsNotifier() : super([]) {
    _loadReviews();
  }

  final _firestore = FirebaseFirestore.instance;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  void _loadReviews() {
    _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final reviews = snapshot.docs.map((doc) {
        return Review.fromMap(doc.data(), doc.id);
      }).toList();
      state = reviews;
    });
  }

  Future<void> addReview({
    required String bookId,
    required String content,
    required int rating, // ⭐️ Nuevo parámetro
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (rating < 1 || rating > 5) throw Exception('Rating inválido');

    final bookDoc = await _firestore.collection('books').doc(bookId).get();
    final bookTitle = bookDoc.data()?['title'] ?? 'Libro desconocido';

    final newReview = Review(
      id: '',
      bookId: bookId,
      bookTitle: bookTitle,
      userId: user.uid,
      userEmail: user.email ?? 'anónimo',
      content: content,
      rating: rating,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('reviews').add(newReview.toMap());
  }

  Future<void> deleteReview(String id) async {
    await _firestore.collection('reviews').doc(id).delete();
  }

  Future<void> editReview({
    required String id,
    required String newContent,
    required int newRating, // ⭐️ También editable
  }) async {
    if (newRating < 1 || newRating > 5) throw Exception('Rating inválido');

    await _firestore.collection('reviews').doc(id).update({
      'content': newContent,
      'rating': newRating,
    });

    _loadReviews();
  }
}
