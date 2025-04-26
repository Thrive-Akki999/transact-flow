class BookDetail {
  final String error;
  final String title;
  final String subtitle;
  final String authors;
  final String publisher;
  final String isbn10;
  final String isbn13;
  final String pages;
  final String year;
  final String rating;
  final String desc;
  final String price;
  final String image;
  final String url;
  final Map<String, String> pdf;

  BookDetail({
    required this.error,
    required this.title,
    required this.subtitle,
    required this.authors,
    required this.publisher,
    required this.isbn10,
    required this.isbn13,
    required this.pages,
    required this.year,
    required this.rating,
    required this.desc,
    required this.price,
    required this.image,
    required this.url,
    required this.pdf,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    print('Raw JSON: $json'); // 👈 Add this to see what's coming

    Map<String, String> pdfMap = {};
    if (json['pdf'] != null && json['pdf'] is Map) {
      final pdfJson = json['pdf'] as Map<String, dynamic>;
      pdfJson.forEach((key, value) {
        if (value is String) {
          pdfMap[key] = value;
        }
      });
    }

    return BookDetail(
      error: json['error'] ?? '0',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      authors: json['authors'] ?? '',
      publisher: json['publisher'] ?? '',
      isbn10: json['isbn10'] ?? '',
      isbn13: json['isbn13'] ?? '',
      pages: json['pages'] ?? '',
      year: json['year'] ?? '',
      rating: json['rating'] ?? '0',
      desc: json['desc'] ?? '',
      price: json['price'] ?? '',
      image: json['image'] ?? '',
      url: json['url'] ?? '',
      pdf: pdfMap,
    );
  }

  @override
  String toString() {
    return 'BookDetail(title: $title, authors: $authors, pdf: $pdf, isbn13: $isbn13)';
  }
}
