import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import '../services/ad_service.dart';
import '../services/tmdb_service.dart';
import '../sup/tag_map.dart';
import '../widgets/person_movies_widget.dart';
import '../sup/screen_util.dart';

class TagMoviesScreen extends StatefulWidget {
  final String tag;
  final bool? isFromWishlist;
  final String? userEmail;
  final String systemLanguage;

  const TagMoviesScreen({
    Key? key, 
    required this.tag, 
    this.isFromWishlist, 
    this.userEmail, 
    required this.systemLanguage
  }) : super(key: key);

  @override
  _TagMoviesScreenState createState() => _TagMoviesScreenState();
}

class _TagMoviesScreenState extends State<TagMoviesScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  final AdService _adService = AdService();
  String _selectedSort = 'All Time';

  @override
  void initState() {
    super.initState();
    _fetchTagMovies();
    _adService.loadBannerAd(
      onAdLoaded: (ad) {
        setState(() {});
      },
    );
    _adService.loadInterstitialAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showInterstitialAd();
        });
      }
    );
  }

  Future<void> _fetchTagMovies() async {
    try {
      // Etiket için filmleri getir
      final Map<String, int> tagMapReverse =
      {for (var e in tagMap.entries) e.value: e.key};
      final tagId = tagMapReverse[widget.tag];

      String sortBy = _selectedSort == 'Trend' ? 'popularity.desc' : 'vote_count.desc';
      _movies = await _tmdbService.getMoviesByTag(tagId ?? -1, sortBy);
    } catch (e) {
      if (mounted) {
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

  void _changeSortType(String sortType) {
    setState(() {
      _selectedSort = sortType;
      _isLoading = true;
    });
    _fetchTagMovies();
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
        scrolledUnderElevation: 0,
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.04),
            ),
            children: <TextSpan>[
              TextSpan(
                text: widget.tag == 'Superhero' ? S.of(context).superhero :
                      widget.tag == 'Sequel' ? S.of(context).sequel :
                      widget.tag == 'MCU' ? S.of(context).mcu :
                      widget.tag == 'Magic' ? S.of(context).magic :
                      widget.tag == 'Supernatural' ? S.of(context).supernatural :
                      widget.tag == 'Time Travel' ? S.of(context).timetravel :
                      widget.tag == 'Romance' ? S.of(context).romance :
                      widget.tag == 'Anime' ? S.of(context).anime :
                      widget.tag == 'Prequel' ? S.of(context).prequel :
                      widget.tag == 'Chosen One' ? S.of(context).chosenOne :
                      widget.tag == 'Fantasy World' ? S.of(context).fantasyWorld :
                      widget.tag == 'Isekai' ? S.of(context).isekai :
                      widget.tag == 'Pirate' ? S.of(context).pirate :
                      widget.tag == 'Martial Arts' ? S.of(context).martialArts :
                      widget.tag == 'Kung Fu' ? S.of(context).kungFu :
                      widget.tag == 'Yakuza' ? S.of(context).yakuza :
                      widget.tag == 'Anti War' ? S.of(context).antiWar :
                      widget.tag == 'Sports Documentary' ? S.of(context).sportsDocumentary :
                      widget.tag == 'Dystopia' ? S.of(context).dystopia :
                      widget.tag == 'Steampunk' ? S.of(context).steampunk :
                      widget.tag == 'Robot' ? S.of(context).robot :
                      widget.tag == 'Silent Film' ? S.of(context).silentFilm :
                      widget.tag == 'Cyberpunk' ? S.of(context).cyberpunk :
                      widget.tag == 'Military' ? S.of(context).military :
                      widget.tag == 'Sci-fi' ? S.of(context).sciFi :
                      widget.tag == 'Space' ? S.of(context).space :
                      widget.tag == 'Prison' ? S.of(context).prison :
                      widget.tag == 'AI' ? S.of(context).ai :
                      widget.tag == 'Philosophy' ? S.of(context).philosophy :
                      widget.tag == 'Mafia' ? S.of(context).mafia :
                      widget.tag == 'Detective' ? S.of(context).detective :
                      widget.tag == 'Dark Comedy' ? S.of(context).darkComedy :
                      widget.tag == 'School' ? S.of(context).school : widget.tag,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.04),
                ),
              ),
              TextSpan(
                text: ' ${S.of(context).movies}',
                style: TextStyle(
                  fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.04),
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.sort,
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
            ),
            onSelected: _changeSortType,
            color: const Color.fromARGB(255, 44, 50, 60),
            itemBuilder: (BuildContext context) {
              return {'Trend', 'All Time'}.map((String choice) { //S.of
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
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
              ? Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: ScreenUtil.getAdaptivePadding(context),
                            child: PersonMoviesWidget(
                              movies: _movies,
                              personType: 'Tag',
                              isFromWishlist: widget.isFromWishlist,
                              userEmail: widget.userEmail,
                              systemLanguage: widget.systemLanguage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_adService.bannerAd != null)
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
                )
              : Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              S.of(context).noMoviesForTag,
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
                    if (_adService.bannerAd != null)
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