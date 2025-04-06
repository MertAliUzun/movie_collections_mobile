import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:movie_collections_mobile/screens/discover_movie_screen.dart';
import 'package:movie_collections_mobile/screens/edit_movie_screen.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import '../sup/screen_util.dart';
import '../screens/popular_people_screen.dart';
import '../screens/director_screen.dart';
import 'add_movie_screen.dart';

class DiscoverMainScreen extends StatefulWidget {
  final bool? isFromWishlist;
  final String? userEmail;
  final String? systemLanguage;

  const DiscoverMainScreen({
    Key? key,
    this.isFromWishlist,
    this.userEmail,
    this.systemLanguage,
  }) : super(key: key);

  @override
  _DiscoverMainScreenState createState() => _DiscoverMainScreenState();
}

class _DiscoverMainScreenState extends State<DiscoverMainScreen> {
  final _tmdbService = TmdbService();
  List<dynamic> _popularPeople = [];
  bool _isLoadingPeople = true;
  List<dynamic> _upcomingMovies = [];
  bool _isLoadingUpcoming = true;
  List<dynamic> _latestMovies = [];
  bool _isLoadingLatest = true;

  @override
  void initState() {
    super.initState();
    _loadPopularPeople();
    _loadUpcomingMovies();
    _loadLatestMovies();
  }

  Future<void> _loadPopularPeople() async {
    try {
      final people = await _tmdbService.getPopularPeople();
      if (mounted) {
        setState(() {
          // Sadece ilk 10 kişiyi al
          _popularPeople = people.take(10).toList();
          _isLoadingPeople = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPeople = false;
        });
      }
    }
  }

  Future<void> _loadUpcomingMovies() async {
    try {
      final people = await _tmdbService.getUpcomingMovies();
      if (mounted) {
        setState(() {
          // Sadece ilk 10 kişiyi al
          _upcomingMovies = people.take(10).toList();
          _isLoadingUpcoming = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUpcoming = false;
        });
      }
    }
  }

  Future<void> _loadLatestMovies() async {
    try {
      final people = await _tmdbService.getLatestMovies();
      if (mounted) {
        setState(() {
          // Sadece ilk 10 kişiyi al
          _latestMovies = people.take(10).toList();
          _isLoadingLatest = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLatest = false;
        });
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
        centerTitle: true,
        title: Text(
          'S.of(context).discover',
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ScreenUtil.getAdaptiveIconSize(context, 24),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Popüler Kişiler Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiscoverMovieScreen(
                            discoverType: 'Latest',
                            isFromWishlist: true,
                            userEmail: widget.userEmail ?? 'test@test.com',
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          S.of(context).latestMovies,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: ScreenUtil.getAdaptiveIconSize(context, 24),
                          )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _isLoadingLatest
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    height: isTablet ? 280 : 275,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _latestMovies.length,
                      itemBuilder: (context, index) {
                        final movie = _latestMovies[index];
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
                                  watched: false,
                                  userEmail: widget.userEmail ?? 'test@test.com',
                                  hidden: false
                                );

                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddMovieScreen(
                                        isFromWishlist: true,
                                        movie: chosenMovie,
                                      ),
                                    ),
                                  );
                                }
                              }           
                          },
                          child: Container(
                            width: isTablet ? 180 : 140,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: Card(
                              color: const Color.fromARGB(255, 44, 50, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16.0),
                                      topRight: Radius.circular(16.0),
                                    ),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                      fit: BoxFit.cover,
                                      height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                                      width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                                      errorBuilder: (context, error, stackTrace) =>
                                        Image.asset(
                                          'assets/images/placeholder_poster.png',
                                          fit: BoxFit.cover,
                                          height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                                          width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                                        ),
                                    ),
                                  ),
                                  ),
                                  
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 44, 50, 60),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            movie['original_title'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil.getAdaptiveTextSize(context, 14),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 16),
            // Upcoming Movies Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiscoverMovieScreen(
                            discoverType: 'Upcoming',
                            isFromWishlist: true,
                            userEmail: widget.userEmail ?? 'test@test.com',
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          S.of(context).upcomingMovies,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: ScreenUtil.getAdaptiveIconSize(context, 24),
                          )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _isLoadingUpcoming
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    height: isTablet ? 280 : 275,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _upcomingMovies.length,
                      itemBuilder: (context, index) {
                        final movie = _upcomingMovies[index];
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
                                  watched: false,
                                  userEmail: widget.userEmail ?? 'test@test.com',
                                  hidden: false
                                );

                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddMovieScreen(
                                        isFromWishlist: true,
                                        movie: chosenMovie,
                                      ),
                                    ),
                                  );
                                }
                              }
                          },
                          child: Container(
                            width: isTablet ? 180 : 140,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: Card(
                              color: const Color.fromARGB(255, 44, 50, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16.0),
                                      topRight: Radius.circular(16.0),
                                    ),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                      fit: BoxFit.cover,
                                      height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                                      width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                                      errorBuilder: (context, error, stackTrace) =>
                                        Image.asset(
                                          'assets/images/placeholder_poster.png',
                                          fit: BoxFit.cover,
                                          height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                                          width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                                        ),
                                    ),
                                  ),
                                  ),
                                  
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 44, 50, 60),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            movie['original_title'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil.getAdaptiveTextSize(context, 14),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 16),
            // Popüler Kişiler Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PopularPeopleScreen(
                            isFromWishlist: widget.isFromWishlist,
                            userEmail: widget.userEmail,
                            systemLanguage: widget.systemLanguage,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'S.of(context).popularPeople',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: ScreenUtil.getAdaptiveIconSize(context, 24),
                          )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Popüler Kişiler Yatay Liste
            _isLoadingPeople
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    height: isTablet ? 280 : 275,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _popularPeople.length,
                      itemBuilder: (context, index) {
                        final person = _popularPeople[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DirectorScreen(
                                  personName: person['name'],
                                  personType: person['known_for_department'],
                                  systemLanguage: widget.systemLanguage,
                                  isFromWishlist: widget.isFromWishlist,
                                  userEmail: widget.userEmail,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: isTablet ? 180 : 140,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: Card(
                              color: const Color.fromARGB(255, 44, 50, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        topRight: Radius.circular(16.0),
                                      ),
                                      child: person['profile_path'] != null
                                          ? Image.network(
                                              'https://image.tmdb.org/t/p/w500${person['profile_path']}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.person, color: Colors.white54, size: 50),
                                            )
                                          : Container(
                                              color: const Color.fromARGB(255, 54, 60, 70),
                                              child: const Icon(Icons.person, color: Colors.white54, size: 50),
                                            ),
                                    ),
                                  ),
                                  
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 44, 50, 60),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            person['name'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil.getAdaptiveTextSize(context, 14),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 32),
            
            // Buraya gelecekte eklenecek diğer keşif bölümleri için yer bırakıyoruz
            // ...
          ],
        ),
      ),
    );
  }
} 