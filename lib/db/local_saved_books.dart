class LocalSavedBook {
  final int? id;
  final String title;
  final String author;
  final int publishedYear;
  final String? coverUrl;
  final DateTime savedAt;
  final String userId;

  LocalSavedBook({
    this.id,
    required this.title,
    required this.author,
    required this.publishedYear,
    this.coverUrl,
    required this.savedAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publishedYear': publishedYear,
      'coverUrl': coverUrl,
      'savedAt': savedAt.toIso8601String(),
      'userId': userId,
    };
  }

  static LocalSavedBook fromMap(Map<String, dynamic> map) {
    return LocalSavedBook(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      publishedYear: map['publishedYear'],
      coverUrl: map['coverUrl'],
      savedAt: DateTime.parse(map['savedAt']),
      userId: map['userId'],
    );
  }
}
