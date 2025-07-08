// lib/models/open_library_book.dart
class OpenLibraryBook {
  final String title;
  final List<String> authors;

  OpenLibraryBook({
    required this.title,
    required this.authors,
  });

  factory OpenLibraryBook.fromJson(Map<String, dynamic> json) {
    return OpenLibraryBook(
      title: json['title'] ?? '[Sin título]',
      authors: (json['authors'] as List<dynamic>?)
              ?.map((a) => a['name'] as String)
              .toList() ??
          ['Autor desconocido'],
    );
  }
}
