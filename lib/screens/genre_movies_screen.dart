import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import '../services/tmdb_service.dart';
import '../widgets/person_movies_widget.dart';

class GenreMoviesScreen extends StatefulWidget {
  final String genre;
  final bool? isFromWishlist;
  final String? userEmail;

  const GenreMoviesScreen({Key? key, required this.genre, this.isFromWishlist, this.userEmail}) : super(key: key);

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
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).failure,
          message: S.of(context).errorFetchingMovies, 
          contentType: ContentType.failure, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
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
        title: Center(child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
              children: <TextSpan>[
                TextSpan(text: _selectedPopularity == 'Daily' ? S.of(context).daily :
                               _selectedPopularity == 'Weekly' ? S.of(context).weekly :
                               _selectedPopularity == 'Monthly' ? S.of(context).monthly : _selectedPopularity, 
                               style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' ${S.of(context).popularFor} '),
                TextSpan(text: widget.genre == 'Action' ? S.of(context).action : 
                               widget.genre == 'Adventure' ? S.of(context).adventure :
                               widget.genre == 'Animation' ? S.of(context).animation :
                               widget.genre == 'Comedy' ? S.of(context).comedy :
                               widget.genre == 'Crime' ? S.of(context).crime :
                               widget.genre == 'Documentary' ? S.of(context).documentary :
                               widget.genre == 'Drama' ? S.of(context).drama :
                               widget.genre == 'Family' ? S.of(context).family :
                               widget.genre == 'Fantasy' ? S.of(context).fantasy :
                               widget.genre == 'History' ? S.of(context).history :
                               widget.genre == 'Horror' ? S.of(context).horror :
                               widget.genre == 'Music' ? S.of(context).music :
                               widget.genre == 'Mystery' ? S.of(context).mystery :
                               widget.genre == 'Romance' ? S.of(context).romance :
                               widget.genre == 'Science Fiction' ? S.of(context).scienceFiction :
                               widget.genre == 'TV Movie' ? S.of(context).tvMovie :
                               widget.genre == 'Thriller' ? S.of(context).thriller :
                               widget.genre == 'War' ? S.of(context).war :
                               widget.genre == 'Western' ? S.of(context).western : widget.genre, 
                               style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_list, color: Colors.white),
            onSelected: _changePopularType,
            color: const Color.fromARGB(255, 44, 50, 60),
            itemBuilder: (BuildContext context) {
              return {'Daily', 'Weekly', 'Monthly'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice== 'Daily' ? S.of(context).daily :
                              choice== 'Weekly' ? S.of(context).weekly :
                              choice== 'Monthly' ? S.of(context).monthly : choice, style: const TextStyle(color: Colors.white)),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movies.isNotEmpty
              ? SingleChildScrollView(child: PersonMoviesWidget(movies: _movies, personType: 'Genre', isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,))
              : const Center(child: Text('No movies found for this genre.', style: TextStyle(color: Colors.white54))),
    );
  }
} 