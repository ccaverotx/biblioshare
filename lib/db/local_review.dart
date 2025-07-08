class LocalReview {
  final int? id;
  final String bookId;
  final String content;
  final DateTime createdAt;
  final String userId;
  final int rating; // ⭐️ nuevo campo obligatorio

  LocalReview({
    this.id,
    required this.bookId,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.rating, // ⭐️ obligatorio
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'rating': rating, // ⭐️ agregado
    };
  }

  factory LocalReview.fromMap(Map<String, dynamic> map) {
    return LocalReview(
      id: map['id'],
      bookId: map['bookId'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      userId: map['userId'] ?? '',
      rating: map['rating'] ?? 0, // ⭐️ manejo defensivo
    );
  }
}
