import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/movie_card.dart';
import '../models/movie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_movie_screen.dart';
import 'edit_movie_screen.dart';
import '../widgets/sort_widget.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final SupabaseService _service = SupabaseService(Supabase.instance.client);
  List<Movie> _movies = [];
  String _sortBy = 'movieName'; // Default sorting criteria
  bool _isAscending = true; // Default sorting order

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    final movies = await _service.getWishlistMovies();
    setState(() {
      _movies = movies;
      _sortMovies(); // Sort movies after fetching
    });
  }

  void _sortMovies() {
    _movies.sort((a, b) {
      int comparison;
      if (_sortBy == 'movieName') {
        comparison = a.movieName.compareTo(b.movieName);
      } else if (_sortBy == 'releaseDate') {
        comparison = a.releaseDate.compareTo(b.releaseDate);
      } else if(_sortBy == 'directorName'){
        comparison = a.directorName.compareTo(b.directorName);
      }  else if(_sortBy == 'imdbRating'){
        comparison = a.imdbRating!.compareTo(b.imdbRating!);
      } else if(_sortBy == 'rtRating'){
        comparison = a.rtRating!.compareTo(b.rtRating!);
      } else if(_sortBy == 'runtime'){
        comparison = a.runtime!.compareTo(b.runtime!);
      } else if (_sortBy == 'hypeScore') {
        comparison = a.hypeScore!.compareTo(b.hypeScore!);
      } else {
        comparison = 0; // Default case
      }
      return _isAscending ? comparison : -comparison;
    });
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return SortWidget(
          isFromWishlist: true,
          sortBy: _sortBy,
          isAscending: _isAscending,
          onSortByChanged: (value) {
            setState(() {
              _sortBy = value;
              _sortMovies();
            });
          },
          onOrderChanged: (value) {
            setState(() {
              _isAscending = value;
              _sortMovies();
            });
          },
        );
      },
    );
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
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        title: Text('İzlenme Listenizde ${_movies.length} film bulunuyor', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04 ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white,),
            onPressed: _showSortOptions,
          ),
        ],
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMovieScreen(isFromWishlist: true),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 