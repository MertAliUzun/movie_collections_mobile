import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/tmdb_service.dart';
import '../widgets/person_movies_widget.dart';

class DirectorScreen extends StatefulWidget {
  final String directorName;

  const DirectorScreen({Key? key, required this.directorName}) : super(key: key);

  @override
  _DirectorScreenState createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Map<String, dynamic>> _directorDetails = [];
  List<Map<String, dynamic>> _directorMovies = [];
  Map<String, dynamic>? _directorPersonalDetails;
  bool _isLoading = true;
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _fetchDirectorDetails();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchDirectorDetails() async {
    try {
      final results = await _tmdbService.searchPeople(widget.directorName);
      _directorDetails = results.where((director) => director['known_for_department'] == 'Directing').take(1).toList();
      if (_directorDetails.isNotEmpty) {
        final directorId = _directorDetails[0]['id'];
        _directorMovies = await _tmdbService.getMoviesByPerson(directorId);
        _directorMovies = _directorMovies.where((movie) => movie['poster_path'] != null).toList();
        _directorPersonalDetails = await _tmdbService.getPersonalDetails(directorId);
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
    if (_directorPersonalDetails != null && _directorPersonalDetails!['imdb_id'] != null) {
      final String url = 'https://www.imdb.com/name/${_directorPersonalDetails!['imdb_id']}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      // Handle the case where the IMDb ID is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IMDb ID not available')),
      );
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
                                          'https://image.tmdb.org/t/p/w500${_directorDetails[0]['profile_path']}',
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                  SizedBox(width: screenWidth * 0.1),
                                  Column(
                                    children: [
                                      Text(
                                        _directorDetails[0]['name'],
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                      Text(
                                        "Director",
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
                  : _directorDetails.isNotEmpty
                      ? Card(
                          color: const Color.fromARGB(255, 44, 50, 60),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, screenHeight * 0.1, 0, 0),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _directorDetails[0]['profile_path'] != null
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                            child: Image.network(
                                              'https://image.tmdb.org/t/p/w500${_directorDetails[0]['profile_path']}',
                                              width: 150,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(Icons.person, color: Colors.white54),
                                    Text(
                                      _directorDetails[0]['name'],
                                      style: const TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    const Text(
                                      'Director',
                                      style: TextStyle(fontSize: 16, color: Colors.white54),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                                if (_directorPersonalDetails != null)
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (_directorPersonalDetails!['also_known_as'] != null)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 44, 50, 60),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Alias: ${_directorPersonalDetails!['also_known_as'][0]}',
                                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ),
                                        if (_directorPersonalDetails!['birthday'] != null)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 44, 50, 60),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Birth Date: ${_directorPersonalDetails!['birthday']}',
                                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        if (_directorPersonalDetails!['deathday'] != null)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 44, 50, 60),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Death Date: ${_directorPersonalDetails!['deathday']}',
                                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        if (_directorPersonalDetails!['place_of_birth'] != null)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 44, 50, 60),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Birth Place: ${_directorPersonalDetails!['place_of_birth']}',
                                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ),
                                        if (_directorPersonalDetails!['biography'] != null)
                                          Card(
                                            shadowColor: Colors.white,
                                            color: const Color.fromARGB(255, 44, 50, 60),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  'Biography: ${_directorPersonalDetails!['biography']}',
                                                  style: const TextStyle(fontSize: 12, color: Colors.white),
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
            child: _directorMovies.isNotEmpty
                ? PersonMoviesWidget(movies: _directorMovies)
                : const Center(child: Text('No movies found for this director.', style: TextStyle(color: Colors.white54))),
          ),
        ],
      ),
    );
  }
}