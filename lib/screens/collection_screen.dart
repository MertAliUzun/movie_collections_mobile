import 'package:flutter/material.dart';
import 'add_movie_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Koleksiyon Sayfası'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMovieScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 