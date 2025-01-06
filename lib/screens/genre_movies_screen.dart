import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../widgets/person_movies_widget.dart';

class GenreMoviesScreen extends StatefulWidget {
  final String genre;

  const GenreMoviesScreen({Key? key, required this.genre}) : super(key: key);

  @override
  _GenreMoviesScreenState createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  String _selectedPopularity = 'Monthly'; // Default popularity type

  @override
  void initState() {
    super.initState();
    _fetchGenreMovies();
  }

  Future<void> _fetchGenreMovies() async {
    try {
      // Fetch movies for the selected genre and popularity
      _movies = await _tmdbService.getMoviesByGenre(widget.genre, _selectedPopularity);
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching movies: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changePopularType(String popularType) {
    setState(() {
      _selectedPopularity = popularType; // Update the selected popularity type
      _isLoading = true; // Set loading to true to fetch new data
    });
    _fetchGenreMovies(); // Fetch movies again with the new popularity type
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: IconThemeData(color: Colors.white),
        title: Center(child: Text('$_selectedPopularity Popular For ${widget.genre}', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04))),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_list, color: Colors.white),
            onSelected: _changePopularType,
            color: const Color.fromARGB(255, 44, 50, 60),
            itemBuilder: (BuildContext context) {
              return {'Daily', 'Weekly', 'Monthly'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice, style: const TextStyle(color: Colors.white)),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movies.isNotEmpty
              ? SingleChildScrollView(child: PersonMoviesWidget(movies: _movies, personType: 'Genre',))
              : const Center(child: Text('No movies found for this genre.', style: TextStyle(color: Colors.white54))),
    );
  }
} 