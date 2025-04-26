import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Required for launching URLs
import '../models/user_model.dart';
import '../models/book_detail_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final purchasedBooks = userModel.purchasedBooks;

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body:
          purchasedBooks.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.book_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No purchased books yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your purchased books will appear here',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Browse Books'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: purchasedBooks.length,
                itemBuilder: (context, index) {
                  final book = purchasedBooks[index];
                  return _buildBookCard(context, book);
                },
              ),
    );
  }

  Widget _buildBookCard(BuildContext context, BookDetail book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        // onTap: () async {
        //   print('book ${book.pdf}');
        //   print('book ${book}');
        //
        //   if (book.pdf.isNotEmpty) {
        //     final firstPdfUrl = book.pdf.entries.first.value;
        //     final Uri uri = Uri.parse(firstPdfUrl);
        //     if (await canLaunchUrl(uri)) {
        //       await launchUrl(uri, mode: LaunchMode.externalApplication);
        //     } else {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text('Could not open PDF')),
        //       );
        //     }
        //   } else {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('No PDF available for this book')),
        //     );
        //   }
        // },
        onTap: () async {
          final response = await http.get(
            Uri.parse('https://api.itbook.store/1.0/books/${book.isbn13}'),
          );

          print('📥 Response body: ${response.body}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final updatedBook = BookDetail.fromJson(data);

            // Check if PDF is available
            if (updatedBook.pdf.isNotEmpty) {
              final Uri pdfUri = Uri.parse(updatedBook.pdf.entries.first.value);
              if (await canLaunch(pdfUri.toString())) {
                await launch(
                  pdfUri.toString(),
                  forceWebView: true,
                  forceSafariVC: true,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open PDF')),
                );
              }
            } else {
              // If no PDF, try to open the book's detail URL
              final Uri webUri = Uri.parse(updatedBook.url);
              print("Opening URL: ${webUri.toString()}");
              if (await canLaunch(webUri.toString())) {
                await launch(
                  webUri.toString(),
                  forceWebView: false,
                  forceSafariVC: false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open book webpage')),
                );
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to fetch book details')),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  book.image,
                  height: 100,
                  width: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 70,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${book.authors}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.book, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${book.pages} pages',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          book.rating,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            book.pdf.isNotEmpty ? 'PDF Available' : 'No PDF',
                          ),
                          avatar:
                              book.pdf.isNotEmpty
                                  ? const Icon(
                                    Icons.picture_as_pdf,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                  : null,
                          backgroundColor:
                              book.pdf.isNotEmpty
                                  ? Colors.red[700]
                                  : Colors.grey[400],
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const Spacer(),
                        Text(
                          book.price,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
