import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book_detail_model.dart';

class PdfViewerScreen extends StatelessWidget {
  final BookDetail book;

  const PdfViewerScreen({Key? key, required this.book}) : super(key: key);

  Future<void> _openPdf(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book info header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    book.image,
                    height: 150,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By ${book.authors}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Publisher: ${book.publisher}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Year: ${book.year}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              'Available PDF Chapters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // PDF chapters list
            if (book.pdf.isEmpty)
              const Center(
                child: Text(
                  'No PDF chapters available for this book',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: book.pdf.length,
                  itemBuilder: (context, index) {
                    final entry = book.pdf.entries.elementAt(index);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 36,
                        ),
                        title: Text(entry.key),
                        subtitle: const Text('Tap to view PDF'),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => _openPdf(entry.value),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
