import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/login_screen.dart';
import 'pages/add_book_page.dart';
import 'pages/book_list_page.dart';
import 'pages/home_page.dart';
import 'firebase_options.dart';
import 'pages/my_reviews_page.dart';
import 'pages/review_feed_page.dart';
import 'pages/saved_books_page.dart';
import 'pages/select_book_for_review_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiblioShare',
      debugShowCheckedModeBanner: false,
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/books': (_) => const BookListPage(),
        '/add': (context) => const AddBookPage(),
        '/feed': (context) => const ReviewsFeedPage(),
        '/select_book': (context) => const SelectBookForReviewPage(),
        '/my_reviews': (context) => const MyReviewsPage(),
        '/saved_books': (context) => const SavedBooksPage(),
      },
    );
  }
}
