import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:movie_collections_mobile/models/movie_model.dart';
import '../sup/businessLogic.dart';
import '../sup/genreMap.dart';
import '../services/tmdb_service.dart';
import 'add_movie_screen.dart';

class CompanyScreen extends StatefulWidget {
  final String companyName;
  final bool? isFromWishlist;
  final String? userEmail;

  const CompanyScreen({Key? key, required this.companyName, this.isFromWishlist, this.userEmail }) : super(key: key);

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoviesByCompany();
  }

  Future<void> _fetchMoviesByCompany() async {
    try {
      final results = await _tmdbService.searchCompany(widget.companyName);
      
      if (results.isNotEmpty) {
        final companyId = results[0]['id'];
        _movies = await _tmdbService.getMoviesByCompany(companyId);
        _movies = _movies.where((movie) => movie['poster_path'] != null).toList();
        
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (e.g., show a snackbar)
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        title: Center(child: Text(widget.companyName, style: TextStyle(color: Colors.white),)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movies.isNotEmpty
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.45,
                  ),
                  itemCount: _movies.length,
                  itemBuilder: (context, index) {
                    final movie = _movies[index];
                    return GestureDetector(
          onTap: () async{
            // Navigate back with movie details
            final movieDetails = await TmdbService().getMovieDetails(movie['id']);                   
            if (movieDetails != null) {
              // Movie nesnesini oluştur
              final chosenMovie = Movie(
                id: movieDetails['id'].toString(),
                movieName: movieDetails['title'] ?? '',
                directorName: movieDetails['credits']['crew']
                    ?.firstWhere((crew) => crew['job'] == 'Director', orElse: () => {'name': ''})['name'] ?? '',
                releaseDate: movieDetails['release_date'] != null 
                    ? DateTime.parse(movieDetails['release_date']) 
                    : DateTime.now(),
                plot: movieDetails['overview'],
                runtime: movieDetails['runtime'],
                imdbRating: movieDetails['vote_average']?.toDouble(),
                writers: movieDetails['credits']['crew']
                    ?.where((member) => member['department'] == 'Writing')
                    .take(3)
                    .map<String>((writer) => writer['name'] as String)
                    .toList(),
                actors: movieDetails['credits']['cast']
                    ?.take(6)
                    .map<String>((actor) => actor['name'] as String)
                    .toList(),
                imageLink: movieDetails['poster_path'] != null 
                    ? 'https://image.tmdb.org/t/p/w500${movieDetails['poster_path']}'
                    : '',
                genres: movieDetails['genres']
                    ?.take(4)
                    .map<String>((genre) => genre['name'] as String)
                    .toList(),
                productionCompany: movieDetails['production_companies']
                    ?.take(2)
                    .map<String>((company) => company['name'] as String)
                    .toList(),
                country: movieDetails['production_countries']?.isNotEmpty 
                    ? movieDetails['production_countries'][0]['iso_3166_1']
                    : null,
                popularity: movieDetails['popularity']?.toDouble(),
                budget: movieDetails['budget']?.toDouble(),
                revenue: movieDetails['revenue']?.toDouble(),
                watched: widget.isFromWishlist ?? false,
                userEmail: widget.userEmail ?? 'test@test.com'
              );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMovieScreen(
                      isFromWishlist: widget.isFromWishlist ?? false,
                      movie: chosenMovie,
                    ),
                  ),
                );
              }        
          },
          child: Card(
            color: const Color.fromARGB(255, 44, 50, 60),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0), // Sol üst köşe
                topRight: Radius.circular(16.0), // Sağ üst köşe
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                movie['poster_path'] != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0), // Sol üst köşe
                          topRight: Radius.circular(16.0), // Sağ üst köşe
                        ),
                      child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                          fit: BoxFit.cover,
                          height: screenHeight * 0.22,
                          width: screenWidth * 0.35,
                        ),
                    )
                    : const Icon(Icons.movie, size: 100, color: Colors.white54),
                SizedBox(height: screenHeight * 0.01,),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 0, 2, 15),
                      child: Text(
                        movie['title'] ?? S.of(context).noTitle,
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                        child: Column(
                          children: [
                            if(movie['genre_ids'] != null && movie['genre_ids'].any((id) => genreMap[id] != null))
                            Text(
                              '${movie['genre_ids'].map((id) => 
                              getGenreLocalizedString(genreMap[id] ?? 'Action', context)
                              ).take(3).join(', ')}',
                              style:  TextStyle(color: Colors.white54, fontSize: screenWidth * 0.025),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: screenHeight * 0.001,),
                            if (movie['release_date'] != null)
                            Text(
                              '${movie['release_date'].split('-')[0]}',
                              style:  TextStyle(color: Colors.white54, fontSize: screenWidth * 0.025),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
                  },
                )
              : Center(child: 
                Column(
                  children: [
                    Text(S.of(context).noMoviesFoundForCompany, 
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045)
                    ),
                    Text(S.of(context).returnPreviousScreen,
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
                    ),
                  ],
                )
                ),
    );
  }
} 