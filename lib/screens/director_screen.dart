import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/tmdb_service.dart';
import '../widgets/person_movies_widget.dart';

class DirectorScreen extends StatefulWidget {
  final String personName;
  final String personType;
  final String? systemLanguage;
  final bool? isFromWishlist;
  final String? userEmail;

  const DirectorScreen({Key? key, required this.personName, required this.personType, this.systemLanguage, this.isFromWishlist, this.userEmail}) : super(key: key);

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

  @override
  void initState() {
    super.initState();  
    _fetchDirectorDetails();
    //print('Person Name: ${widget.personName}, Person Type: ${widget.personType}');
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchDirectorDetails() async {
    try {
      final results = await _tmdbService.searchPeople(widget.personName);
      if(widget.personType == 'Director'){
        _personDetails = results.where((director) => director['known_for_department'] == 'Directing').take(1).toList();
      } else if(widget.personType == 'Actor'){
        _personDetails = results.where((actor) => actor['known_for_department'] == 'Acting').take(1).toList();
      } else if(widget.personType == 'Writer'){
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if(_personMovies.isNotEmpty) {
      if(_personDetails[0]['profile_path'] != null){
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: const Color.fromARGB(255, 34, 40, 50),
            expandedHeight: screenHeight * 0.5,
            //title: Center(child: Text('Sort and View ?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
            title: _isCollapsed ?  Container(
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                       Image.network(
                                          'https://image.tmdb.org/t/p/w500${_personDetails[0]['profile_path']}',
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                  SizedBox(width: screenWidth * 0.1),
                                  Column(
                                    children: [
                                      Text(
                                        _personDetails[0]['name'],
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                      Text(
                                        widget.personType == 'Director' ? S.of(context).director :
                                        widget.personType == 'Actor' ? S.of(context).actor :
                                        widget.personType == 'Writer' ? S.of(context).writer : widget.personType,
                                        style: const TextStyle(fontSize: 12 , color: Colors.white60),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ) : Text(''),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _personDetails.isNotEmpty
                      ? Card(
                          color: const Color.fromARGB(255, 34, 40, 50),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, screenHeight * 0.08, 0, 0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                  child: Card(
                                    color: const Color.fromARGB(255, 24, 30, 40),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        _personDetails[0]['profile_path'] != null
                                            ? Container(
                                              decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(12.0), // Sol üst köşe
                                                topRight: Radius.circular(12.0), // Sağ üst köşe
                                              ),
                                              boxShadow: [
                                               const BoxShadow(
                                                  color: Colors.black26,
                                                  offset: Offset(0, 0),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.network(
                                                  'https://image.tmdb.org/t/p/w500${_personDetails[0]['profile_path']}',
                                                  height: screenHeight * 0.3,
                                                  width: screenWidth * 0.45,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                            : const Icon(Icons.person, color: Colors.white54),
                                        SizedBox(height: screenHeight * 0.015),
                                        Text(
                                          _personDetails[0]['name'],
                                          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                       Text(
                                          widget.personType == 'Director' ? S.of(context).director :
                                          widget.personType == 'Actor' ? S.of(context).actor :
                                          widget.personType == 'Writer' ? S.of(context).writer : widget.personType,
                                          style: TextStyle(fontSize: 16, color: Colors.white54, fontWeight: FontWeight.bold),
                                        ),
                                        
                                      ],
                                    ),
                                  ),
                                ),
                                if (_personPersonalDetails != null)
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_personPersonalDetails!['also_known_as'].length > 0)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 24, 30, 40),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${S.of(context).aliasColon} ${_personPersonalDetails!['also_known_as'][0]}',
                                                style: const TextStyle(fontSize: 11, color: Colors.white),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        if (_personPersonalDetails!['birthday'] != null)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 24, 30, 40),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${S.of(context).birthDateColon} ${_personPersonalDetails!['birthday']}',
                                                style: const TextStyle(fontSize: 11, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        if (_personPersonalDetails!['deathday'] != null)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 24, 30, 40),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${S.of(context).deathDateColon} ${_personPersonalDetails!['deathday']}',
                                                style: const TextStyle(fontSize: 11, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        if (_personPersonalDetails!['place_of_birth'] != null)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 24, 30, 40),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${S.of(context).birthPlaceColon} ${_personPersonalDetails!['place_of_birth']}',
                                                style: const TextStyle(fontSize: 11, color: Colors.white),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ),
                                        if (_personPersonalDetails?['biography']?.isNotEmpty ?? false)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 24, 30, 40),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  '${S.of(context).biographyColon} ${_personPersonalDetails!['biography']}',
                                                  style: const TextStyle(fontSize: 11, color: Colors.white),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 6,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.004,),
                                          Center(
                                            child: ElevatedButton(
                                             onPressed: () {
                                              _launchIMDb();
                                              },
                                             child: Icon(Icons.movie, size: 24, color: Colors.amber),
                                             style: ElevatedButton.styleFrom(
                                               backgroundColor: Colors.transparent
                                            ),
                                           ),
                                          ),
                                      ],
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
                ? PersonMoviesWidget(movies: _personMovies, personType: widget.personType,)
                : Center(child: Text(S.of(context).noMoviesFound, style: TextStyle(color: Colors.white54))),
          ),
        ],
      ),
    );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 34, 40, 50),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: const Color.fromARGB(255, 34, 40, 50),
          title: Center(
            child: Column(
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
        ),
        body: _personMovies.isNotEmpty
                ? SingleChildScrollView(child: PersonMoviesWidget(movies: _personMovies, personType: widget.personType, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,))
                : Center(child: Text(S.of(context).noMoviesFound, style: TextStyle(color: Colors.white54))),

      );
    }
    } else{
      return Scaffold(backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: const Center(child: CircularProgressIndicator()));
    }
  }
}