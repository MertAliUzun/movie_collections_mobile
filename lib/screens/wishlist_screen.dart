import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/movie_card.dart';
import '../models/movie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_movie_screen.dart';
import 'edit_movie_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final SupabaseService _service = SupabaseService(Supabase.instance.client);
  List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    final movies = await _service.getWishlistMovies();
    setState(() {
      _movies = movies;
    });
  }
  
  void _navigateToEditMovieScreen(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(isFromWishlist: true, movie: movie),
      ),
    ).then((_) {
      _fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 44, 50, 60),
        title: Text('İzleme Listenizde ${_movies.length} film bulunuyor', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),),
      ),
      body: ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          return MovieCard(
            movie: _movies[index],
            isFromWishlist: true,
            onTap: () => _navigateToEditMovieScreen(_movies[index]),
          );
        },
      ),
            floatingActionButton: FloatingActionButton(
              backgroundColor:  Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMovieScreen(isFromWishlist: true), // Wishlist'den geldi
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 