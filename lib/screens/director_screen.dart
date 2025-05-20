import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/ad_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/person_movies_widget.dart';
import '../sup/screen_util.dart';

class DirectorScreen extends StatefulWidget {
  final String personName;
  final String personType;
  final String systemLanguage;
  final bool? isFromWishlist;
  final String? userEmail;

  const   DirectorScreen({Key? key, required this.personName, required this.personType, required this.systemLanguage, this.isFromWishlist, this.userEmail}) : super(key: key);

  @override
  _DirectorScreenState createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _personDetails = [];
  List<Map<String, dynamic>> _personMovies = [];
  Map<String, dynamic>? _personPersonalDetails;
  bool _isLoading = true;
  late ScrollController _scrollController;
  bool _isCollapsed = false;
  final AdService _adService = AdService();


  @override
  void initState() {
    super.initState();  
    _fetchDirectorDetails();
    //print('Person Name: ${widget.personName}, Person Type: ${widget.personType}');
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _adService.loadRewardedAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showRewardedAd();
        });
      }
    );
  }

  Future<void> _fetchDirectorDetails() async {
    try {
      final results = await _tmdbService.searchPeople(widget.personName);
      if(widget.personType == 'Directing'){
        _personDetails = results.where((director) => director['known_for_department'] == 'Directing').take(1).toList();
      } else if(widget.personType == 'Acting'){
        _personDetails = results.where((actor) => actor['known_for_department'] == 'Acting').take(1).toList();
      } else if(widget.personType == 'Writing'){
        _personDetails = results.where((actor) => actor['known_for_department'] == 'Writing').take(1).toList();
      }
      
      if (_personDetails.isNotEmpty) {
        final personId = _personDetails[0]['id'];
        _personMovies = await _tmdbService.getMoviesByPerson(personId, widget.personType);
        _personMovies = _personMovies.where((movie) => movie['poster_path'] != null).toList();
        
        _personPersonalDetails = await _tmdbService.getPersonalDetails(personId, widget.systemLanguage ?? 'en');
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

  void _launchIMDb() async {
    if (_personPersonalDetails != null && _personPersonalDetails!['imdb_id'] != null) {
      final Uri url = Uri.parse('https://www.imdb.com/name/${_personPersonalDetails!['imdb_id']}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      // Handle the case where the IMDb ID is not available
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).failure,
          message: S.of(context).invalidIMDB,
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

    void _scrollListener() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final isCollapsed = offset > 400; // Adjust the threshold as needed
      if (isCollapsed != _isCollapsed) {
        setState(() {
          _isCollapsed = isCollapsed;
        });
      }
    }
  }

  // Biyografi dialogunu gösterecek fonksiyon ekleyelim
  void _showFullBiography(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 44, 50, 60),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).biographyColon,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      _personPersonalDetails!['biography'] ?? 'Null',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    S.of(context).cancel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dateString) {
  // Parse the date string into a DateTime object
  DateTime date = DateTime.parse(dateString);
  try {
    if(widget.systemLanguage == 'en') {
      return DateFormat('MMMM d, yyyy', 'en').format(date);
  } else if (widget.systemLanguage == 'ja') {
     return DateFormat('yyyy MMMM d', 'ja').format(date);
  } else {
     return DateFormat('d MMMM yyyy', widget.systemLanguage).format(date);
  }
  } catch (e) {
    // Format the DateTime object to the desired format
  return DateFormat('MMMM d, yyyy', 'en').format(date);
  }
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = ScreenUtil.isTablet(context);

    if(_personMovies.isNotEmpty) {
      if(_personDetails[0]['profile_path'] != null){
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                iconTheme: IconThemeData(
                  color: Colors.white,
                  size: ScreenUtil.getAdaptiveIconSize(context, 24),
                ),
                backgroundColor: const Color.fromARGB(255, 34, 40, 50),
                expandedHeight: isTablet ? screenHeight * 0.4 : screenHeight * 0.55,
                centerTitle: true,
                title: _isCollapsed ? Container(
                  padding: ScreenUtil.getAdaptivePadding(context),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.network(
                        'https://image.tmdb.org/t/p/w500${_personDetails[0]['profile_path']}',
                        width: ScreenUtil.getAdaptiveCardWidth(context, 50),
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.1)),
                      Column(
                        children: [
                          Text(
                            _personDetails[0]['name'],
                            style: TextStyle(
                              fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.personType == 'Directing' ? S.of(context).director :
                            widget.personType == 'Acting' ? S.of(context).actor :
                            widget.personType == 'Writer' ? S.of(context).writer : widget.personType,
                            style: TextStyle(
                              fontSize: ScreenUtil.getAdaptiveTextSize(context, 12),
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ) : const Text(''),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _personDetails.isNotEmpty
                      ? Card(
                          color: const Color.fromARGB(255, 34, 40, 50),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, screenHeight * 0.06, 0, 0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: ScreenUtil.getAdaptivePadding(context, vertical: 20, horizontal: screenWidth * 0.02),
                                  child: Container(
                            width: isTablet ? 250 : screenWidth * 0.47,
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
                                      child: _personDetails[0]['profile_path'] != null
                                          ? Image.network(
                                              'https://image.tmdb.org/t/p/w500${_personDetails[0]['profile_path']}',
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
                                        color: const Color.fromARGB(255, 20, 26, 33),
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
                                            _personDetails[0]['name'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                          widget.personType == 'Directing' ? S.of(context).director :
                                          widget.personType == 'Acting' ? S.of(context).actor :
                                          widget.personType == 'Writing' ? S.of(context).writer : widget.personType,
                                          style: TextStyle(
                                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                                            color: Colors.white54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                                ),
                                  Flexible(
                                    child: Container(
                                      //shadowColor: Colors.white,
                                      
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 20, 26, 33),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          /*
                                          if (_personPersonalDetails!['also_known_as'].length > 0)
                                            Card(
                                              shadowColor: Colors.white,
                                              color: const Color.fromARGB(255, 24, 30, 40),
                                              child: Padding(
                                                padding: ScreenUtil.getAdaptivePadding(context),
                                                child: Text(
                                                  '${S.of(context).aliasColon} ${_personPersonalDetails!['also_known_as'][0]}',
                                                  style: TextStyle(
                                                    fontSize: ScreenUtil.getAdaptiveTextSize(context, 11),
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),*/
                                            Card(
                                              shadowColor: Colors.white,
                                              color: const Color.fromARGB(255, 20, 26, 33),
                                              child: Container(
                                                width: screenWidth * 0.5,
                                                child: Padding(
                                                  padding: ScreenUtil.getAdaptiveLTRBPadding(context, bottom: 8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        S.of(context).birthDateColon,
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 11),
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                          _personPersonalDetails!['birthday'] != null && _formatDate(_personPersonalDetails!['birthday']).isNotEmpty ?
                                                          _formatDate(_personPersonalDetails!['birthday']) :
                                                          'Null',
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 11),
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (_personPersonalDetails!['deathday'] != null)
                                            Card(
                                              shadowColor: Colors.white,
                                              color: const Color.fromARGB(255, 20, 26, 33),
                                              child: Container(
                                                width: screenWidth * 0.5,
                                                child: Padding(
                                                  padding: ScreenUtil.getAdaptiveLTRBPadding(context, bottom: 8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        S.of(context).deathDateColon,
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 11),
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                        _formatDate(_personPersonalDetails!['deathday']),
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 11),
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Card(
                                              shadowColor: Colors.white,
                                              color: const Color.fromARGB(255, 20, 26, 33),
                                              child: Container(
                                                width: screenWidth * 0.5,
                                                child: Padding(
                                                  padding: ScreenUtil.getAdaptiveLTRBPadding(context, bottom: 8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        S.of(context).birthPlaceColon,
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 11),
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                          _personPersonalDetails!['place_of_birth'] != null && _personPersonalDetails?['place_of_birth']?.isNotEmpty ?
                                                          _personPersonalDetails!['place_of_birth'] :
                                                          'Null',
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 11),
                                                          color: Colors.white,
                                                        ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2, 
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _showFullBiography(context),
                                              child: Card(
                                                shadowColor: Colors.white,
                                                color: const Color.fromARGB(255, 20, 26, 33),
                                                child: Padding(
                                                  padding: ScreenUtil.getAdaptiveLTRBPadding(context, bottom: 2),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '${S.of(context).biographyColon}',
                                                          style: TextStyle(
                                                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 11),
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        ), 
                                                        Text(
                                                          _personPersonalDetails!['biography'] != null && _personPersonalDetails?['biography']?.isNotEmpty ?
                                                          _personPersonalDetails!['biography'] :
                                                          'Null',
                                                          style: TextStyle(
                                                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 11),
                                                            color: Colors.white,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: isTablet ? 8 : 3,
                                                        ), 
                                                        Center(
                                                          child: Icon(
                                                            Icons.keyboard_arrow_down,
                                                            color: Colors.white54,
                                                            size: ScreenUtil.getAdaptiveIconSize(context, 24),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.004)),
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.01),
                                              ),
                                              child: ElevatedButton(
                                                onPressed: _launchIMDb,
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  backgroundColor: Colors.transparent,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: Image.asset(
                                                    'assets/images/imdb.png',
                                                    width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.3),
                                                    height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.05),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: _personMovies.isNotEmpty
                  ? Column(
                      children: [
                        PersonMoviesWidget(
                          movies: _personMovies,
                          personType: widget.personType,
                          systemLanguage: widget.systemLanguage,
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
                    )
                  : Center(
                      child: Text(
                        S.of(context).noMoviesFound,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
            ),
            backgroundColor: const Color.fromARGB(255, 34, 40, 50),
            centerTitle: true,
            title: Column(
               children: [
                 Text(
                   _personDetails[0]['name'],
                   style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
                   textAlign: TextAlign.center,
                 ),
                 Text(
                   widget.personType == 'Director' ? S.of(context).director :
                   widget.personType == 'Actor' ? S.of(context).actor :
                   widget.personType == 'Writer' ? S.of(context).writer : widget.personType,
                   style: TextStyle(fontSize: screenWidth * 0.035 , color: Colors.white60),
                   textAlign: TextAlign.center,
                 ),
               ],
             ),
          ),
          body: _personMovies.isNotEmpty
                  ? 
                      Column(
                        children: [
                          SingleChildScrollView(child: PersonMoviesWidget(movies: _personMovies, personType: widget.personType, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail, systemLanguage: widget.systemLanguage,)),
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
                      )   
                  : Center(child: Text(S.of(context).noMoviesFound, style: const TextStyle(color: Colors.white54))),
        );
      }
    } else{
      if(_isLoading) {
        return Scaffold(backgroundColor: const Color.fromARGB(255, 34, 40, 50),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 44, 50, 60),
          iconTheme: IconThemeData(
            color: Colors.white,
            size: ScreenUtil.getAdaptiveIconSize(context, 24),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()));
      }
      else {
        return Scaffold(backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ScreenUtil.getAdaptiveIconSize(context, 24),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.personType == 'Director' ? S.of(context).dataNotRetrivedDirector :
                    widget.personType == 'Actor' ? S.of(context).dataNotRetrivedActor :
                    widget.personType == 'Writer' ? S.of(context).dataNotRetrivedWriter : widget.personType, 
                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.045)),
                    ),
                    Text(S.of(context).returnPreviousScreen,
                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.045)),
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
      )
        );
      }
    }
  }
  @override
  void dispose() {
    _adService.disposeAds();
    super.dispose();
  }
}