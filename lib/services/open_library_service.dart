// lib/services/open_library_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenLibraryService {
  static const String baseUrl = 'https://openlibrary.org/search.json';

  static Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    final url = Uri.parse('$baseUrl?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final docs = data['docs'] as List<dynamic>;

      return docs.map<Map<String, dynamic>>((doc) {
        return {
          'title': doc['title'] ?? 'Sin título',
          'author':
              (doc['author_name'] != null && doc['author_name'].isNotEmpty)
                  ? doc['author_name'][0]
                  : 'Desconocido',
          'publishedYear': doc['first_publish_year'],
          'coverUrl': doc['cover_i'] != null
              ? 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-L.jpg'
              : null,
        };
      }).toList();
    } else {
      throw Exception('Error al buscar libros');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPopularBooks() async {
    final url =
        Uri.parse('https://openlibrary.org/subjects/popular.json?limit=10');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final works = data['works'] as List<dynamic>;

      return works.map<Map<String, dynamic>>((work) {
        return {
          'title': work['title'] ?? 'Sin título',
          'author': (work['authors'] != null && work['authors'].isNotEmpty)
              ? work['authors'][0]['name']
              : 'Desconocido',
          'coverUrl': work['cover_id'] != null
              ? 'https://covers.openlibrary.org/b/id/${work['cover_id']}-L.jpg'
              : null,
        };
      }).toList();
    } else {
      throw Exception('Error al obtener libros populares');
    }
  }
}
