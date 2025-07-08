// lib/pages/book_search_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookSearchPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onBookSelected;

  const BookSearchPage({super.key, required this.onBookSelected});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _searchBooks() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _loading = true);
    try {
      final url = Uri.parse('https://openlibrary.org/search.json?q=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List docs = data['docs'];

        final books = docs.map<Map<String, dynamic>>((doc) {
          return {
            'title': doc['title'] ?? 'Sin título',
            'author':
                (doc['author_name'] != null && doc['author_name'].isNotEmpty)
                    ? doc['author_name'][0]
                    : 'Autor desconocido',
            'publishedYear': doc['first_publish_year'],
            'coverUrl': doc['cover_i'] != null
                ? 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-L.jpg'
                : null,
          };
        }).toList();

        setState(() => _results = books);
      } else {
        throw Exception('Error al buscar libros');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar libro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por título o autor',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchBooks,
                ),
              ),
              onSubmitted: (_) => _searchBooks(),
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final book = _results[index];
                        return ListTile(
                          leading: book['coverUrl'] != null
                              ? Image.network(book['coverUrl'],
                                  width: 40, fit: BoxFit.cover)
                              : const Icon(Icons.book_outlined),
                          title: Text(book['title']),
                          subtitle: Text(book['author']),
                          onTap: () {
                            widget.onBookSelected(book);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
