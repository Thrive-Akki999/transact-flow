import 'package:flutter/foundation.dart';
import 'book_detail_model.dart';

class CartModel extends ChangeNotifier {
  final List<BookDetail> _items = [];

  List<BookDetail> get items => List.unmodifiable(_items);

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      // Extract the price value from the string (e.g., "$19.99" -> 19.99)
      final priceString = item.price.replaceAll('\$', '');
      final price = double.tryParse(priceString) ?? 0;
      total += price;
    }
    return total;
  }

  void addItem(BookDetail book) {
    // Check if the book is already in the cart
    if (!_items.any((item) => item.isbn13 == book.isbn13)) {
      _items.add(book);
      notifyListeners();
    }
  }

  void removeItem(BookDetail book) {
    _items.removeWhere((item) => item.isbn13 == book.isbn13);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
