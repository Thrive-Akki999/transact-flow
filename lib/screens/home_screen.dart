import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/cart_model.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Book> _books = [];
  bool _isLoading = false;
  String _searchQuery = 'mongodb';
  int _currentPage = 1;
  bool _hasMorePages = true;
  String _sortBy = 'title';
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.searchBooks(_searchQuery, _currentPage);

      if (_currentPage == 1) {
        _books = result.books;
      } else {
        _books.addAll(result.books);
      }

      _hasMorePages = _currentPage < (int.parse(result.total) / 10).ceil();
      _sortBooks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading books: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMoreBooks() {
    if (_hasMorePages && !_isLoading) {
      _currentPage++;
      _loadBooks();
    }
  }

  void _search() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _searchQuery = _searchController.text;
        _currentPage = 1;
        _books = [];
      });
      _loadBooks();
    }
  }

  void _sortBooks() {
    switch (_sortBy) {
      case 'title':
        _books.sort(
          (a, b) =>
              _ascending
                  ? a.title.compareTo(b.title)
                  : b.title.compareTo(a.title),
        );
        break;
      case 'price':
        _books.sort((a, b) {
          final priceA = double.tryParse(a.price.replaceAll('\$', '')) ?? 0;
          final priceB = double.tryParse(b.price.replaceAll('\$', '')) ?? 0;
          return _ascending
              ? priceA.compareTo(priceB)
              : priceB.compareTo(priceA);
        });
        break;
    }
    setState(() {});
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Title'),
                trailing: Radio<String>(
                  value: 'title',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                      Navigator.pop(context);
                      _sortBooks();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _sortBy = 'title';
                    Navigator.pop(context);
                    _sortBooks();
                  });
                },
              ),
              ListTile(
                title: const Text('Price'),
                trailing: Radio<String>(
                  value: 'price',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                      Navigator.pop(context);
                      _sortBooks();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _sortBy = 'price';
                    Navigator.pop(context);
                    _sortBooks();
                  });
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Order'),
                trailing: Switch(
                  value: _ascending,
                  onChanged: (value) {
                    setState(() {
                      _ascending = value;
                      Navigator.pop(context);
                      _sortBooks();
                    });
                  },
                ),
                subtitle: Text(_ascending ? 'Ascending' : 'Descending'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() {
    Provider.of<UserModel>(context, listen: false).logout();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _showUserMenu() {
    final userModel = Provider.of<UserModel>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('User Profile'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${userModel.name}'),
                    const SizedBox(height: 8),
                    Text('Email: ${userModel.email}'),
                  ],
                ),
              ),
              const Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.book, size: 20),
                    SizedBox(width: 16),
                    Text('My Orders'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout();
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 16),
                    Text('Logout'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Row(
                  children: [
                    Icon(Icons.close, size: 20),
                    SizedBox(width: 16),
                    Text('Close'),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transact',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              if (cartModel.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartModel.items.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _showUserMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showSortOptions,
                  tooltip: 'Sort',
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _books.isEmpty && !_isLoading
                    ? const Center(
                      child: Text(
                        'No books found. Try a different search term.',
                      ),
                    )
                    : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                          _loadMoreBooks();
                        }
                        return true;
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: _books.length + (_hasMorePages ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _books.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final book = _books[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => ProductDetailScreen(
                                        isbn13: book.isbn13,
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                    child: Image.network(
                                      book.image,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          book.subtitle,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          book.price,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
