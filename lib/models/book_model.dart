class Book {
  final String title;
  final String subtitle;
  final String isbn13;
  final String price;
  final String image;
  final String url;

  Book({
    required this.title,
    required this.subtitle,
    required this.isbn13,
    required this.price,
    required this.image,
    required this.url,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      isbn13: json['isbn13'] ?? '',
      price: json['price'] ?? '',
      image: json['image'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class BookSearchResult {
  final String error;
  final String total;
  final String page;
  final List<Book> books;

  BookSearchResult({
    required this.error,
    required this.total,
    required this.page,
    required this.books,
  });

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    return BookSearchResult(
      error: json['error'] ?? '0',
      total: json['total'] ?? '0',
      page: json['page'] ?? '1',
      books: (json['books'] as List<dynamic>?)
              ?.map((book) => Book.fromJson(book))
              .toList() ??
          [],
    );
  }
}
