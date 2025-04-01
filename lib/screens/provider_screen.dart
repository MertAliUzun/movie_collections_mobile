import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:movie_collections_mobile/models/movie_model.dart';
import '../services/ad_service.dart';
import '../sup/businessLogic.dart';
import '../sup/genreMap.dart';
import '../services/tmdb_service.dart';
import 'add_movie_screen.dart';
import '../sup/screen_util.dart';

class ProviderScreen extends StatefulWidget {
  final int providerId;
  final String providerName;
  final bool? isFromWishlist;
  final String? userEmail;

  const ProviderScreen({
    Key? key, 
    required this.providerId, 
    required this.providerName,
    this.isFromWishlist, 
    this.userEmail,
  }) : super(key: key);

  @override
  _ProviderScreenState createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _fetchMoviesByProvider();
    /*
    _adService.loadRewardedAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showRewardedAd();
        });
      }
    );
    */
  }

  Future<void> _fetchMoviesByProvider() async {
    try {
      _movies = await _tmdbService.getMoviesByProvider(widget.providerId);
      _movies = _movies.where((movie) => movie['poster_path'] != null).toList();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
        centerTitle: true,
        title: Text(
          widget.providerName,
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil.getAdaptiveTextSize(context, 18),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ScreenUtil.getAdaptiveIconSize(context, 24),
        ),
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movies.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 5 : 3,
                          childAspectRatio: isTablet ? 0.65 : 0.4,
                          mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                          crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                        ),
                        padding: ScreenUtil.getAdaptivePadding(context),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return GestureDetector(
                            onTap: () async {
                              final movieDetails = await _tmdbService.getMovieDetails(movie['id']);
                              if (movieDetails != null) {
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
                                  watched: widget.isFromWishlist ?? false,
                                  userEmail: widget.userEmail ?? 'test@test.com'
                                );

                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddMovieScreen(
                                        isFromWishlist: true, //always add to wishlist
                                        movie: chosenMovie,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Card(
                              color: const Color.fromARGB(255, 44, 50, 60),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16.0),
                                      topRight: Radius.circular(16.0),
                                    ),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                      fit: BoxFit.cover,
                                      height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                                      width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                                    ),
                                  ),
                                  SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.01)),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                                    child: Text(
                                      movie['title'] ?? S.of(context).noTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.027),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                                    child: Column(
                                      children: [
                                        if (movie['genre_ids'] != null)
                                          Text(
                                            '${movie['genre_ids'].map((id) => 
                                              getGenreLocalizedString(genreMap[id] ?? 'Action', context)
                                            ).take(3).join(', ')}',
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.025),
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        if (movie['release_date'] != null)
                                          Text(
                                            movie['release_date'].split('-')[0],
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.025),
                                            ),
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
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).noMoviesFound,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.045),
                        ),
                      ),
                      Text(
                        S.of(context).returnPreviousScreen,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.045),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _adService.disposeAds();
    super.dispose();
  }
} 