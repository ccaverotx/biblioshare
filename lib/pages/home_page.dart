import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/open_library_service.dart';
import '../db/local_saved_books.dart';
import '../db/local_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int bookCount = 0;
  int userReviewCount = 0;
  Set<String> savedTitles = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadSavedBooks();
  }

  Future<void> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final booksSnapshot =
          await FirebaseFirestore.instance.collection('books').get();
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        bookCount = booksSnapshot.docs.length;
        userReviewCount = reviewsSnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar estadísticas: $e');
    }
  }

  Future<void> _loadSavedBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final savedBooks = await LocalDatabase.getSavedBooksForUser(user.uid);
    setState(() {
      savedTitles = savedBooks.map((b) => b.title).toSet();
    });
  }

  Future<void> _toggleSavedBook(Map<String, dynamic> book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final title = book['title'] ?? 'Sin título';

    if (savedTitles.contains(title)) {
      final all = await LocalDatabase.getSavedBooksForUser(user.uid);
      final target = all.firstWhere((b) => b.title == title,
          orElse: () => LocalSavedBook(
              id: -1,
              title: '',
              author: '',
              publishedYear: 0,
              savedAt: DateTime.now(),
              userId: user.uid));

      if (target.id != null && target.id! >= 0) {
        await LocalDatabase.deleteSavedBook(target.id!);
        savedTitles.remove(title);
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Quitado: $title')),
          );
        }
      }
    } else {
      final savedBook = LocalSavedBook(
        title: title,
        author: book['author'] ?? 'Desconocido',
        publishedYear: book['publishedYear'] ?? 0,
        coverUrl: book['coverUrl'],
        savedAt: DateTime.now(),
        userId: user.uid,
      );
      await LocalDatabase.insertSavedBook(savedBook);
      savedTitles.add(title);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📥 Guardado: $title')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('BiblioShare 📚')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.account_circle,
                        size: 60, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? 'Usuario',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✍️ Reseñas escritas: $userReviewCount',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Reseñas públicas'),
              onTap: () => Navigator.pushNamed(context, '/feed'),
            ),
            ListTile(
              leading: const Icon(Icons.reviews),
              title: const Text('Mis reseñas'),
              onTap: () => Navigator.pushNamed(context, '/my_reviews'),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Libros en colección'),
              onTap: () => Navigator.pushNamed(context, '/books'),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Guardados para leer después'),
              onTap: () => Navigator.pushNamed(context, '/saved_books'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '📚 Libros populares de Open Library',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: OpenLibraryService.fetchPopularBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay libros disponibles'));
                }

                final books = snapshot.data!;
                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final title = book['title'] ?? 'Sin título';
                    final isSaved = savedTitles.contains(title);

                    return ListTile(
                      leading: book['coverUrl'] != null
                          ? Image.network(book['coverUrl'],
                              width: 50, fit: BoxFit.cover)
                          : const Icon(Icons.book, size: 40),
                      title: Text(title),
                      subtitle: Text(book['author'] ?? 'Desconocido'),
                      trailing: IconButton(
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_added
                              : Icons.bookmark_add_outlined,
                          color: isSaved ? Colors.green : null,
                        ),
                        tooltip: isSaved
                            ? 'Quitar de guardados'
                            : 'Guardar para después',
                        onPressed: () => _toggleSavedBook(book),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
