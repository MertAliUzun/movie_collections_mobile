import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_service.dart';
import '../services/supabase_service.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/movie_card.dart';
import '../models/movie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_movie_screen.dart';
import 'edit_movie_screen.dart';
import '../widgets/sort_widget.dart';
import '../sup/groupBy.dart';
import 'package:hive/hive.dart';
import '../sup/businessLogic.dart';
import '../sup/screen_util.dart';

class CollectionScreen extends StatefulWidget {
  final String? userId; // Kullanıcı ID'si
  final String? userEmail; // Kullanıcı E-postası
  final String? userPicture; // Kullanıcı Resmi
  final String? userName;
  final String? systemLanguage;

  const CollectionScreen({super.key, this.userId, this.userEmail, this.userPicture, this.userName, this.systemLanguage});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final SupabaseService _service = SupabaseService(Supabase.instance.client);
  List<Movie> _movies = [];
  List<Movie> _filteredMovies = [];
  List<Movie> _allMovies = [];
  String _sortBy = 'movieName'; // Default sorting criteria
  String _sortDir = 'Ascending'; // Default sorting criteria
  bool _isAscending = true; // Default sorting order
  bool _isSearching = false; // Track if searching
  final TextEditingController _searchController = TextEditingController();
  String _viewType = 'List'; // Default view type
  String _groupByText = 'None';
  bool _groupByDirector = false; // Track if grouping by director
  bool _groupByGenre = false; // Track if grouping by genre
  bool _groupByReleaseYear = false;
  bool _groupByWatchYear = false;
  bool _groupBy = false;
  Set<String> _selectedMovies = {};
  bool get _isSelectionMode => _selectedMovies.isNotEmpty;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _loadViewType();
    _fetchMovies();
    _adService.loadRewardedAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showRewardedAd();
        });
      }
    );
  }

  Future<void> _loadViewType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _viewType = prefs.getString('viewType') ?? 'List';
    });
  }

  Future<void> _fetchMovies() async {
    try {
      final movies = await _service.getCollectionMovies();
      setState(() {
        _movies = movies;
        _filteredMovies = movies; // Initialize filtered list
        _sortMovies(); // Sort movies after fetching
      });
    } catch (e) {
      // If there's an error (like no internet), load from Hive
      final box = Hive.box<Movie>('movies');
      List<Movie> allMovies = box.values.toList();
      List<Movie> movies = box.values.where((movie) => movie.watched).toList();
      setState(() {
        _movies = movies;
        _filteredMovies = _movies; // Initialize filtered list
        _allMovies = allMovies;
        _sortMovies(); // Sort movies after loading from Hive
      });
    }
  }

  void _sortMovies() {
    _filteredMovies.sort((a, b) {
      int comparison;
      if (_sortBy == 'movieName') {
        //if there is customSortTitle, sort according to that if not sort for movieName
        String aMovie = a.movieName;
        String bMovie = b.movieName;
        if(a.customSortTitle !=null) { aMovie = a.customSortTitle!; }
        if(b.customSortTitle !=null) { bMovie = b.customSortTitle!; }
        comparison = aMovie.compareTo(bMovie);
      } else if (_sortBy == 'releaseDate') {
        comparison = a.releaseDate.compareTo(b.releaseDate);
      } else if (_sortBy == 'directorName') {
        comparison = a.directorName.compareTo(b.directorName);
      } else if (_sortBy == 'imdbRating') {
        comparison = a.imdbRating!.compareTo(b.imdbRating!);
      } else if (_sortBy == 'runtime') {
        comparison = a.runtime!.compareTo(b.runtime!);
      } else if (_sortBy == 'watchCount') {
        comparison = a.watchCount!.compareTo(b.watchCount!);
      } else if (_sortBy == 'userScore') {
        comparison = a.userScore!.compareTo(b.userScore!);
      } else if (_sortBy == 'watchDate') {
        comparison = a.watchDate!.compareTo(b.watchDate!);
      } else {
        comparison = 0; // Default case
      }
      return _isAscending ? comparison : -comparison;
    });
  }
  void _onSortByChanged(String newSortBy) {
  setState(() {
    _sortBy = newSortBy; // Yeni sıralama kriterini güncelle
    _sortMovies(); // Filmleri sırala
  });
  }
  void _onSortDirChanged(String newSortDir) {
    setState(() {
      _sortDir = newSortDir; // Yeni sıralama kriterini güncelle
      if(newSortDir == 'Ascending') { _isAscending = true;} else { _isAscending = false;}
      _sortMovies(); // Filmleri sırala
    });
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return SortWidget(
          isFromWishlist: false,
          sortBy: _sortBy,
          isAscending: _isAscending,
          onSortByChanged: (value) {
            setState(() {
              _sortBy = value;
              _sortMovies();
            });
          },
          onOrderChanged: (value) {
            setState(() {
              _isAscending = value;
              _sortMovies();
            });
          },
        );
      },
    );
  }

  void _searchMovies(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMovies = _movies; // Reset to original list
      });
    } else {
      setState(() {
        _filteredMovies = _movies.where((movie) {
          return movie.movieName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void _navigateToEditMovieScreen(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(isFromWishlist: false, movie: movie, userEmail: widget.userEmail, systemLanguage: widget.systemLanguage,),
      ),
    ).then((_) {
      _fetchMovies();
    });
  }

  void _changeViewType(String newViewType) {
    setState(() {
      _viewType = newViewType;
    });
    _saveViewType(newViewType);
  }

  Future<void> _saveViewType(String viewType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('viewType', viewType);
  }

  void _toggleGroupBy(String value) {
  setState(() {
    // Tüm gruplamaları sıfırla
    _groupByDirector = false;
    _groupByGenre = false;
    _groupByReleaseYear = false;
    _groupByWatchYear = false;
    _groupBy = false;

    // Seçime göre gruplamayı etkinleştir
    switch (value) {
      case 'Director':
        _groupByDirector = true;
        _groupBy = true;
        break;
      case 'Genre':
        _groupByGenre = true;
        _groupBy = true;
        break;
      case 'Release Year':
        _groupByReleaseYear = true;
        _groupBy = true;
        break;
      case 'Watch Year':
        _groupByWatchYear = true;
        _groupBy = true;
        break;
      default:
        // 'None' veya diğer durumlarda zaten tüm gruplamalar sıfırlanmış durumda
        break;
    }

    // Seçilen grup adını güncelle
    _groupByText = value;
  });
}

  void _handleMovieSelection(Movie movie) {
    setState(() {
      if (_selectedMovies.contains(movie.id.toString())) {
        _selectedMovies.remove(movie.id.toString());
      } else {
        _selectedMovies.add(movie.id.toString());
      }
    });
  }

  void _handleMovieTap(Movie movie) {
    if (_isSelectionMode) {
      _handleMovieSelection(movie);
    } else {
      _navigateToEditMovieScreen(movie);
    }
  }

  void _deleteSelectedMovies() {
    final box = Hive.box<Movie>('movies');

    for (String movieId in _selectedMovies) {
      // Hive'dan silinecek filmleri bul
      for (var movie in box.values) {
        if (movie.id == movieId) {
      // Eğer film ID'si eşleşiyorsa, sil
      box.delete(movie.id);
      }
     }
    }
    _adService.showRewardedAd();

    final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).succesful, 
          message: '${_selectedMovies.length} ${S.of(context).moviesDeleted}', 
          contentType: ContentType.success, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
      
    setState(() {
      _selectedMovies.clear();
      _fetchMovies(); // Filmleri güncelle
    });  
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = ScreenUtil.isTablet(context);

    // Group movies by director or genre based on the selected option
    Map<String, List<Movie>> groupedMovies = _groupByDirector
        ? groupByDirector(_filteredMovies)
        : _groupByGenre
            ? groupByGenre(_filteredMovies)
            : _groupByReleaseYear ? groupByYear(_filteredMovies, 'Release Date') 
            : _groupByWatchYear ? groupByYear(_filteredMovies, 'Watch Date') 
            : {};

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: _isSelectionMode ? AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: Colors.white,
            size: ScreenUtil.getAdaptiveIconSize(context, 24),
          ),
          onPressed: () {
            setState(() {
              _selectedMovies.clear();
            });
          },
        ),
        title: Text(
          '${_selectedMovies.length} ${S.of(context).moviesSelected}', 
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil.getAdaptiveTextSize(context, 18),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.select_all, 
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
            ),
            onPressed: () {
              setState(() {
                _selectedMovies.clear();
                for (var movie in _filteredMovies) {
                  if (movie.watched) {
                    _selectedMovies.add(movie.id!.toString());
                  }
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.input, 
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
            ),
            onPressed: () async {
              for (String movieId in _selectedMovies) {
                final movie = _movies.firstWhere((m) => m.id.toString() == movieId);
                await toggleWatchedStatus(context, movie, false, false); // 1. false for collection 2. false for canPop
              }
              final snackBar = SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              content: AwesomeSnackbarContent(
                title: S.of(context).succesful, 
                message:  S.of(context).moviesMovedToWatchlist, 
                contentType: ContentType.success, 
                inMaterialBanner: true,
              ), 
              dismissDirection: DismissDirection.horizontal,
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentMaterialBanner()
              ..showSnackBar(snackBar);
              setState(() {
                _selectedMovies.clear();
              });
              await _fetchMovies(); // Sayfayı yenile
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete, 
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color.fromARGB(255, 44, 50, 60),
                  title: Text(
                    S.of(context).deleteChosenMovies, 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
                    ),
                  ),
                  content: Text(
                    '${_selectedMovies.length} ${S.of(context).selectedMoviesDeleteConfirm}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        S.of(context).cancel,  
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteSelectedMovies();
                      },
                      child: Text(
                        S.of(context).delete,  
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ) : AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ScreenUtil.getAdaptiveIconSize(context, 24),
        ),
        leading: _isSearching ? IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: Colors.white,
            size: ScreenUtil.getAdaptiveIconSize(context, 24),
          ),
          onPressed: () {
            setState(() {
              _isSearching = false;
            });
          },
        ) : null,
        title: !_isSearching 
          ? Text(
              '${_movies.length} ${S.of(context).movies}', 
              style: TextStyle(
                color: Colors.white, 
                fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.04),
              ),
            )
          : SizedBox(
              width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.8),
              height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.05),
              child: TextField(
                focusNode: FocusNode(),
                controller: _searchController,
                textAlignVertical: TextAlignVertical.bottom,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                ),
                decoration: InputDecoration(
                  hintText: S.of(context).searchMovies,
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                  ),
                  fillColor: Colors.transparent,
                ),
                onChanged: _searchMovies,
              ),
            ),
            actions: [
          if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching; // Toggle search mode
                _searchController.clear(); // Clear search field
                _filteredMovies = _movies; // Reset filtered list
              });
            },
          ),
        ],
      ),
      drawer: _isSelectionMode || _isSearching ? null : DrawerWidget(
        viewType: _viewType,
        groupByText: _groupByText,
        sortBy: _sortBy,
        changeViewType: _changeViewType,
        toggleGroupBy: _toggleGroupBy,
        onSortByChanged: _onSortByChanged,
        sortDir: _sortDir,
        onSortDirChanged: _onSortDirChanged,
        isFromWishlist: false,
        movies: _movies,
        allMovies: _allMovies,
        userPicture: widget.userPicture,
        userEmail: widget.userEmail,
        userId: widget.userId,
        userName: widget.userName,
      ),
      body: Column(
        children: [
          Expanded(
            child: _viewType.contains('List')
              ? ListView.builder(
                  itemCount: _groupBy ? groupedMovies.keys.length : _filteredMovies.length,
                  itemBuilder: (context, index) {
                    if (_groupBy) {
                      List<String> sortedMovies = groupedMovies.keys.toList()..sort();
                      String sortName = sortedMovies[index];
                      List<Movie> movies = groupedMovies[sortName]!;
                      if(_groupByDirector){ movies.sort((a, b) => a.directorName.compareTo(b.directorName),); }
                      return ExpansionTile(
                        title: Text(
                          sortName == 'Action' ? S.of(context).action :
                          sortName == 'Adventure' ? S.of(context).adventure :
                          sortName == 'Animation' ? S.of(context).animation :
                          sortName == 'Comedy' ? S.of(context).comedy :
                          sortName == 'Crime' ? S.of(context).crime :
                          sortName == 'Documentary' ? S.of(context).documentary :
                          sortName == 'Drama' ? S.of(context).drama :
                          sortName == 'Family' ? S.of(context).family :
                          sortName == 'Fantasy' ? S.of(context).fantasy :
                          sortName == 'History' ? S.of(context).history :
                          sortName == 'Horror' ? S.of(context).horror :
                          sortName == 'Music' ? S.of(context).music :
                          sortName == 'Mystery' ? S.of(context).mystery :
                          sortName == 'Romance' ? S.of(context).romance :
                          sortName == 'Science Fiction' ? S.of(context).scienceFiction :
                          sortName == 'TV Movie' ? S.of(context).tvMovie :
                          sortName == 'Thriller' ? S.of(context).thriller :
                          sortName == 'War' ? S.of(context).war :
                          sortName == 'Western' ? S.of(context).western : sortName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                          ),
                        ),
                        children: movies.map((movie) {
                          return MovieCard(
                            movie: movie,
                            isFromWishlist: false,
                            viewType: _viewType,
                            isSelected: _selectedMovies.contains(movie.id.toString()),
                            selectionMode: _isSelectionMode,
                            onTap: () => _handleMovieTap(movie),
                            onLongPress: () => _handleMovieSelection(movie),
                          );
                        }).toList(),
                      );
                    } else {
                      return MovieCard(
                        movie: _filteredMovies[index],
                        isFromWishlist: false,
                        viewType: _viewType,
                        isSelected: _selectedMovies.contains(_filteredMovies[index].id.toString()),
                        selectionMode: _isSelectionMode,
                        onTap: () => _handleMovieTap(_filteredMovies[index]),
                        onLongPress: () => _handleMovieSelection(_filteredMovies[index]),
                      );
                    }
                  },
                ) :_groupBy ? ListView.builder(
                    itemCount: _groupBy ? groupedMovies.keys.length : _filteredMovies.length,
                    itemBuilder: (context, index) {
                        //to sort directorCards by directorName
                        List<String> sortedDirectors = groupedMovies.keys.toList()..sort();
                        String directorName = sortedDirectors[index];
                        List<Movie> movies = groupedMovies[directorName]!;
                        movies.sort((a, b) => a.directorName.compareTo(b.directorName),);
                        //
                        return ExpansionTile(
                          title: Text(directorName, style: const TextStyle(color: Colors.white)),
                          children: [
                            GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 5 : 3,
                      childAspectRatio: isTablet 
                      ? (_viewType == "Card" ? 0.7 : 0.75)  // Tablet için aspect ratio
                      : (_viewType == "Card" ? 0.43 : 0.5), // Telefon için aspect ratio
                    mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                    crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                    ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: ScreenUtil.getAdaptivePadding(context),
                              itemCount: movies.length,
                              itemBuilder: (context, movieIndex) {
                                return MovieCard(
                                  movie: movies[movieIndex],
                                  isFromWishlist: false,
                                  viewType: _viewType,
                                  isSelected: _selectedMovies.contains(movies[movieIndex].id.toString()),
                                  selectionMode: _isSelectionMode,
                                  onTap: () => _handleMovieTap(movies[movieIndex]),
                                  onLongPress: () => _handleMovieSelection(movies[movieIndex]),
                                );
                              },
                            ),
                          ],
                        );
                    },
                  )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 5 : 3, // Tablet için 5, telefon için 3 sütun
                    childAspectRatio: isTablet 
                      ? (_viewType == "Card" ? 0.7 : 0.75)  // Tablet için aspect ratio
                      : (_viewType == "Card" ? 0.43 : 0.5), // Telefon için aspect ratio
                    mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                    crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                  ),
                  padding: ScreenUtil.getAdaptivePadding(context),
                  itemCount: _filteredMovies.length,
                  itemBuilder: (context, index) {
                    return MovieCard(
                      movie: _filteredMovies[index],
                      isFromWishlist: false,
                      viewType: _viewType,
                      isSelected: _selectedMovies.contains(_filteredMovies[index].id.toString()),
                      selectionMode: _isSelectionMode,
                      onTap: () => _handleMovieTap(_filteredMovies[index]),
                      onLongPress: () => _handleMovieSelection(_filteredMovies[index]),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMovieScreen(
                isFromWishlist: false, 
                userEmail: widget.userEmail, 
                systemLanguage: widget.systemLanguage,
              ),
            ),
          ).then((_) {
            _fetchMovies();
          });
        },
        child: Icon(
          Icons.add,
          size: ScreenUtil.getAdaptiveIconSize(context, 24),
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