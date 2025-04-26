import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';
import '../models/book_detail_model.dart';

class ApiService {
  final String baseUrl = 'https://api.itbook.store/1.0';

  Future<BookSearchResult> searchBooks(String query, int page) async {
    final response = await http.get(Uri.parse('$baseUrl/search/$query/$page'));
    
    if (response.statusCode == 200) {
      return BookSearchResult.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<BookDetail> getBookDetail(String isbn13) async {
    final response = await http.get(Uri.parse('$baseUrl/books/$isbn13'));
    
    if (response.statusCode == 200) {
      return BookDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load book details');
    }
  }
}
