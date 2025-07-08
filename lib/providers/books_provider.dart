// lib/providers/books_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

/// 🔐 Observa el usuario autenticado actual
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// 📚 Proveedor de libros que se actualiza al cambiar de usuario
final booksStreamProvider = StreamProvider<List<Book>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return const Stream.empty();

  final booksCollection = FirebaseFirestore.instance.collection('books');

  return booksCollection
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Book.fromMap(doc.data(), doc.id))
        .toList();
  });
});

/// 🧠 Lógica para agregar, editar o eliminar libros
class BooksNotifier extends StateNotifier<AsyncValue<void>> {
  BooksNotifier() : super(const AsyncValue.data(null));

  final booksCollection = FirebaseFirestore.instance.collection('books');

  /// 🔧 Agrega un libro con metadatos completos
  Future<void> addBook(Map<String, dynamic> bookData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    state = const AsyncLoading();
    try {
      bookData['userId'] = user.uid;
      bookData['createdAt'] = Timestamp.now();

      await booksCollection.add(bookData);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 🪄 (Opcional) Agrega un libro básico solo con título y autor
  Future<void> addBasicBook(String title, String author) async {
    await addBook({
      'title': title,
      'author': author,
      'source': 'manual',
    });
  }

  Future<void> updateBook(String id, Map<String, dynamic> updatedData) async {
    try {
      await booksCollection.doc(id).update(updatedData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await booksCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}

final booksProvider =
    StateNotifierProvider<BooksNotifier, AsyncValue<void>>((ref) {
  return BooksNotifier();
});
