import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'book_detail_model.dart';

class UserModel extends ChangeNotifier {
  final SharedPreferences _prefs;

  String _name = '';
  String _email = '';
  bool _isLoggedIn = false;
  List<BookDetail> _purchasedBooks = [];

  UserModel(this._prefs) {
    _loadUserData();
    _loadPurchasedBooks();
  }

  String get name => _name;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;
  List<BookDetail> get purchasedBooks => List.unmodifiable(_purchasedBooks);

  void _loadUserData() {
    final userData = _prefs.getString('user_data');
    if (userData != null) {
      final Map<String, dynamic> userMap = jsonDecode(userData);
      _name = userMap['name'] ?? '';
      _email = userMap['email'] ?? '';
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  void _loadPurchasedBooks() {
    final purchasedBooksData = _prefs.getString('purchased_books_${_email}');
    if (purchasedBooksData != null) {
      final List<dynamic> booksJson = jsonDecode(purchasedBooksData);
      _purchasedBooks =
          booksJson.map((bookJson) => BookDetail.fromJson(bookJson)).toList();
      notifyListeners();
    }
  }

  Future<void> addPurchasedBooks(List<BookDetail> books) async {
    if (_email.isEmpty) return;

    // Add new books to the purchased books list
    for (var book in books) {
      if (!_purchasedBooks.any((item) => item.isbn13 == book.isbn13)) {
        _purchasedBooks.add(book);
      }
    }

    // Save to SharedPreferences
    final List<Map<String, dynamic>> booksJson =
        _purchasedBooks
            .map(
              (book) => {
                'error': book.error,
                'title': book.title,
                'subtitle': book.subtitle,
                'authors': book.authors,
                'publisher': book.publisher,
                'isbn10': book.isbn10,
                'isbn13': book.isbn13,
                'pages': book.pages,
                'year': book.year,
                'rating': book.rating,
                'desc': book.desc,
                'price': book.price,
                'image': book.image,
                'url': book.url,
                'pdf': book.pdf,
              },
            )
            .toList();

    await _prefs.setString('purchased_books_${_email}', jsonEncode(booksJson));
    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    // In a real app, you would make an API call to create a user account
    // For this demo, we'll just store the user data in SharedPreferences

    // Check if email already exists
    final userData = _prefs.getString('user_data');
    if (userData != null) {
      final Map<String, dynamic> userMap = jsonDecode(userData);
      if (userMap['email'] == email) {
        throw Exception('Email already exists');
      }
    }

    // Store user data
    final Map<String, dynamic> userMap = {
      'name': name,
      'email': email,
      'password': password, // In a real app, you would hash this password
    };

    await _prefs.setString('user_data', jsonEncode(userMap));

    // Don't log in the user automatically after signup
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // In a real app, you would make an API call to verify credentials
    // For this demo, we'll just check against SharedPreferences

    final userData = _prefs.getString('user_data');
    if (userData != null) {
      final Map<String, dynamic> userMap = jsonDecode(userData);
      if (userMap['email'] == email && userMap['password'] == password) {
        _name = userMap['name'] ?? '';
        _email = email;
        _isLoggedIn = true;
        _loadPurchasedBooks(); // Load purchased books after login
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  void logout() {
    _name = '';
    _email = '';
    _isLoggedIn = false;
    _purchasedBooks = [];
    notifyListeners();
  }
}
