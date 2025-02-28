import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import '../models/movie_model.dart';
import '../screens/add_movie_screen.dart';
import '../services/tmdb_service.dart';
import '../sup/businessLogic.dart';
import '../sup/genreMap.dart';

class PersonMoviesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> movies;
  final String personType;
  final bool? isFromWishlist;
  final String? userEmail;

  const PersonMoviesWidget({Key? key, required this.movies, required this.personType, this.isFromWishlist, this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Adjust the number of columns as needed
        childAspectRatio: 0.42, // Adjust the aspect ratio as needed
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () async {
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
                watched: isFromWishlist ?? false,
                userEmail: userEmail ?? 'test@test.com'
              );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMovieScreen(
                      isFromWishlist: isFromWishlist ?? false,
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
                      borderRadius: const BorderRadius.only(
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
                SizedBox(height: screenHeight *0.01,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 15),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          movie['title'] ?? S.of(context).noTitle,
                          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      if(personType == 'Actor')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0,),
                        child: Text('(${movie['character']})', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1,),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: screenHeight*0.005,),
                
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
          ),
        );
      },
    );
  }
} 