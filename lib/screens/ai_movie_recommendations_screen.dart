import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../models/movie_model.dart';
import '../services/ai_service.dart';
import '../services/tmdb_service.dart';
import '../sup/businessLogic.dart';
import '../sup/genreMap.dart';
import '../sup/screen_util.dart';
import 'add_movie_screen.dart';

class AiMovieRecommendationsScreen extends StatefulWidget {
  @override
  _AiMovieRecommendationsScreenState createState() => _AiMovieRecommendationsScreenState();
}

class _AiMovieRecommendationsScreenState extends State<AiMovieRecommendationsScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _recommendedMovies = [];
  bool _isLoading = false;

  String _getGenreLocalizedString(String genre) {
    return getGenreLocalizedString(genre, context);
  }

  Future<void> _getAiRecommendations(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // AI servisinden film önerilerini al
      final movieTitles = await getGroqRecommendations(query);

      
      
      // TMDB ID'lerini al
      final tmdbService = TmdbService();
      final movies = await tmdbService.getMovies(movieTitles);
      /*
      final ids = await tmdbService.getTMDBIds(movieTitles);
      // Her film için detayları al
      List<Map<String, dynamic>> movieDetails = [];
      for (var id in ids) {
        final details = await tmdbService.getMovieDetails(id);
        if (details != null) {
          movieDetails.add(details);
        }
        print(movieDetails);
        //print(movieDetails[0]['genre']);
      }
      */
      
      setState(() {
        _recommendedMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        print(e.toString());
        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: AwesomeSnackbarContent(
            title: S.of(context).error,
            message: e.toString(),
            contentType: ContentType.failure,
            inMaterialBanner: true,
          ),
          dismissDirection: DismissDirection.horizontal,
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = ScreenUtil.isTablet(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Film Önerileri', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : _recommendedMovies.isEmpty
                    ? Center(
                        child: Text(
                          'Film türü veya konusu yazarak\nöneriler alabilirsiniz',
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      )
                    :SingleChildScrollView(
                      child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ScreenUtil.getAdaptiveGridCrossAxisCount(context, 3),
                          childAspectRatio: isTablet ? 2.0 : 0.4,
                          mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                          crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recommendedMovies.length,
                        itemBuilder: (context, index) {
                          final recommendedMovie = _recommendedMovies[index];
                          return GestureDetector(
                            onTap: () async {
                              if (recommendedMovie['id'] != null) {
                                final movieDetails = await TmdbService().getMovieDetails(recommendedMovie['id']);
                                
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
                                        ?.take(6)
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
                                    watched: false,
                                    userEmail: 'test@test.com' //widget.userEmail ?? 'test@test.com'
                                  );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddMovieScreen(
                                          isFromWishlist: true,
                                          movie: chosenMovie,
                                        ),
                                      ),
                                    );
                                    /*_fetchMovieDetails(similarMovie['id']);
                                    _scrollToTop();*/
                                  }
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
                                  recommendedMovie['poster_path'] != null
                                      ? ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16.0), // Sol üst köşe
                                            topRight: Radius.circular(16.0), // Sağ üst köşe
                                          ),
                                        child: Image.network(
                                            'https://image.tmdb.org/t/p/w500${recommendedMovie['poster_path']}',
                                            fit: BoxFit.cover,
                                            height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                                            width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                                            errorBuilder: (context, error, stackTrace) =>
                                            Image.asset(
                                             'assets/images/placeholder_poster.png',
                                             fit: BoxFit.contain,
                                            ),
                                          ),
                                      )
                                      : const Icon(Icons.movie, size: 100, color: Colors.white54),
                                  SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight *0.01)),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                                    child: Text(
                                      recommendedMovie['title'] ?? S.of(context).noTitle,
                                      style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.027), fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                                      child: Column(
                                        children: [
                                          if(recommendedMovie['genre_ids'] != null && recommendedMovie['genre_ids'].any((id) => genreMap[id] != null))
                                          Text(
                                            '${recommendedMovie['genre_ids'].map((id) => 
                                            _getGenreLocalizedString(genreMap[id] ?? 'Action')
                                            ).take(3).join(', ')}',
                                            style:  TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.025)),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.001)),
                                          if (recommendedMovie['release_date'] != null)
                                          Text(
                                            '${recommendedMovie['release_date'].split('-')[0]}',
                                            style:  TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.025)),
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
                      ),
                    ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ne tür filmler arıyorsunuz?',
                hintStyle: TextStyle(color: Colors.white70),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () => _getAiRecommendations(_textController.text),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: _getAiRecommendations,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
} 