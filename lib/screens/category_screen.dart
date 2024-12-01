import 'package:flutter/material.dart';
import 'package:new_expense_tracker/screens/chat_screen.dart';
import '../widgets/category_screen/category_fetcher.dart';
import '../widgets/expense_form.dart';
import '../screens/pdf_screen.dart';

class CategoryScreen extends StatefulWidget {
  static const name = '/category_screen';

  const CategoryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isMenuOpen = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const CategoryFetcher(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: _isMenuOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: FloatingActionButton(
              heroTag: 'btn1',
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfScreen(), 
                  ),
                );
              },
              child: const Icon(Icons.picture_as_pdf_rounded),
            ),
          ),
          const SizedBox(height: 16), 
          AnimatedOpacity(
            opacity: _isMenuOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: FloatingActionButton(
              heroTag: 'btn2',
              onPressed: () {
                // Example action for the first hidden button
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(), 
                  ),
                );
              },
              child: const Icon(Icons.chat),
            ),
          ),
          const SizedBox(height: 16), 
          AnimatedOpacity(
            opacity: _isMenuOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: FloatingActionButton(
              heroTag: 'btn3',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const ExpenseForm(),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'main',
            onPressed: () {
              setState(() {
                _isMenuOpen = !_isMenuOpen; 
              });
            },
            child: Icon(_isMenuOpen ? Icons.close : Icons.menu), 
          ),
        ],
      ),
    );
  } 
  }

