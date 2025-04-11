import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import '../services/ad_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/person_movies_widget.dart';
import '../sup/screen_util.dart';

class GenreMoviesScreen extends StatefulWidget {
  final String genre;
  final bool? isFromWishlist;
  final String? userEmail;
  final String systemLanguage;

  const GenreMoviesScreen({Key? key, required this.genre, this.isFromWishlist, this.userEmail, required this.systemLanguage}) : super(key: key);

  @override
  _GenreMoviesScreenState createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  String _selectedPopularity = 'Monthly';
  final AdService _adService = AdService();


  @override
  void initState() {
    super.initState();
    _fetchGenreMovies();
    _adService.loadRewardedAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showRewardedAd();
        });
      }
    );
  }

   Future<void> _fetchGenreMovies() async {
   try {
     // Fetch movies for the selected genre and popularity
     _movies = await _tmdbService.getMoviesByGenre(widget.genre, _selectedPopularity);
   } catch (e) {
     // Handle error (e.g., show a snackbar)
     if (mounted) {  // Ensure the widget is still in the tree before using context
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
     }
   } finally {
     if (mounted) { 
       setState(() {
         _isLoading = false;
       });
     }
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
    bool isTablet = ScreenUtil.isTablet(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ScreenUtil.getAdaptiveIconSize(context, 24),
        ),
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white, 
              fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.04),
            ),
            children: <TextSpan>[
              TextSpan(
                text: _selectedPopularity == 'Daily' ? S.of(context).daily :
                      _selectedPopularity == 'Weekly' ? S.of(context).weekly :
                      _selectedPopularity == 'Monthly' ? S.of(context).monthly : _selectedPopularity, 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.04),
                ),
              ),
              TextSpan(
                text: ' ${S.of(context).popularFor} ',
                style: TextStyle(
                  fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.04),
                ),
              ),
              TextSpan(
                text: widget.genre == 'Action' ? S.of(context).action : 
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
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.04),
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.view_list, 
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
            ),
            onSelected: _changePopularType,
            color: const Color.fromARGB(255, 44, 50, 60),
            itemBuilder: (BuildContext context) {
              return {'Daily', 'Weekly', 'Monthly'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice == 'Daily' ? S.of(context).daily :
                    choice == 'Weekly' ? S.of(context).weekly :
                    choice == 'Monthly' ? S.of(context).monthly : choice, 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.04),
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movies.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: ScreenUtil.getAdaptivePadding(context),
                        child: PersonMoviesWidget(
                          movies: _movies, 
                          personType: 'Genre', 
                          isFromWishlist: widget.isFromWishlist, 
                          userEmail: widget.userEmail,
                          systemLanguage: widget.systemLanguage,
                        ),
                      ),
                      if(_adService.bannerAd != null)
            FutureBuilder<Widget>(
              future: _adService.showBannerAd(isTablet),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const SizedBox.shrink();
              },
            ),
                    ],
                  ),
                )
              : Column(
                children: [
                  Expanded(
                    child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              S.of(context).noMoviesForGenre,
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
                  ),
                    if(_adService.bannerAd != null)
            FutureBuilder<Widget>(
              future: _adService.showBannerAd(isTablet),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const SizedBox.shrink();
              },
            ),
                ],
              ),
    );
  }
  @override
  void dispose() {
    _adService.disposeAds();
    super.dispose();
  }
} 