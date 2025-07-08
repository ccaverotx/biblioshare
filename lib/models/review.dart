import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String bookId;
  final String bookTitle;
  final String userId;
  final String userEmail;
  final String content;
  final int rating; // ⭐️ Nuevo campo: puntuación del 1 al 5
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
    required this.userEmail,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      content: data['content'] ?? '',
      rating: data['rating'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'userId': userId,
      'userEmail': userEmail,
      'content': content,
      'rating': rating,
      'createdAt': createdAt,
    };
  }
}
