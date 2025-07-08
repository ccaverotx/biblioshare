// lib/models/book.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String userId;
  final String? description;
  final String? coverUrl;
  final int? publishedYear;
  final String? genre;
  final DateTime? createdAt;
  final String? source;
  final String? isbn;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.userId,
    this.description,
    this.coverUrl,
    this.publishedYear,
    this.genre,
    this.createdAt,
    this.source,
    this.isbn,
  });

  factory Book.fromMap(Map<String, dynamic> data, String id) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      userId: data['userId'] ?? '',
      description: data['description'],
      coverUrl: data['coverUrl'],
      publishedYear: data['publishedYear'],
      genre: data['genre'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      source: data['source'],
      isbn: data['isbn'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'userId': userId,
      'description': description,
      'coverUrl': coverUrl,
      'publishedYear': publishedYear,
      'genre': genre,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'source': source,
      'isbn': isbn,
    };
  }
}
