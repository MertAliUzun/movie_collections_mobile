import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_service.dart';
import '../sup/businessLogic.dart';
import '../sup/groupBy.dart';
import '../services/supabase_service.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/movie_card.dart';
import '../models/movie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_movie_screen.dart';
import 'ai_movie_recommendations_screen.dart';
import 'edit_movie_screen.dart';
import '../widgets/sort_widget.dart';
import 'package:hive/hive.dart';
import '../sup/screen_util.dart';

class WishlistScreen extends StatefulWidget {
  static final GlobalKey<_WishlistScreenState> globalKey = GlobalKey();
  final String? userId; // Kullanıcı ID'si
  final String? userEmail; // Kullanıcı E-postası
  final String? userPicture; // Kullanıcı Resmi
  final String? userName;
  final String systemLanguage;

  WishlistScreen({this.userId, this.userEmail, this.userPicture, this.userName, required this.systemLanguage}) : super(key: globalKey);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
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
  bool _groupByReleaseYear= false;
  bool _groupByFranchise = false;
  bool _groupByTag = false;
  bool _groupBy = false;
  Set<String> _selectedMovies = {};
  bool get _isSelectionMode => _selectedMovies.isNotEmpty;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _loadViewType();
    _loadSortPreferences(); // Sıralama tercihlerini yükle
    _loadGroupByText(); // Group by metnini yükle
    _loadGroupByBooleans(); // Group by boolean değerlerini yükle
    _fetchMovies();
    _adService.loadRewardedAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showRewardedAd();
        });
      }
    );
  }

  void navigateToAiPage() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => AiMovieRecommendationsScreen(
          userEmail: widget.userEmail ?? 'test@test.com',
          systemLanguage: widget.systemLanguage,

        ),
      ),
    );
  }

  Future<void> _loadViewType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _viewType = prefs.getString('viewTypeWishlist') ?? 'List';
    });
  }

  Future<void> _loadSortPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortBy = prefs.getString('sortByWishlist') ?? 'movieName'; // Varsayılan sıralama
      _sortDir = prefs.getString('sortDirWishlist') ?? 'Ascending'; // Varsayılan sıralama yönü
      _isAscending = _sortDir == 'Ascending'; // Sıralama yönünü ayarla
    });
  }

  Future<void> _saveSortPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sortByWishlist', _sortBy);
    await prefs.setString('sortDirWishlist', _sortDir);
  }

  Future<void> _loadGroupByText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _groupByText = prefs.getString('groupByTextWishlist') ?? 'None'; // Varsayılan grup metni
    });
  }

  Future<void> _saveGroupByText(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('groupByTextWishlist', value);
  }

  Future<void> _loadGroupByBooleans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _groupByDirector = prefs.getBool('groupByDirectorWishlist') ?? false;
      _groupByGenre = prefs.getBool('groupByGenreWishlist') ?? false;
      _groupByReleaseYear = prefs.getBool('groupByReleaseYearWishlist') ?? false;
      _groupByFranchise = prefs.getBool('_groupByFranchiseWishlist') ?? false;
      _groupByTag = prefs.getBool('groupByTagWishlist') ?? false;
      _groupBy = prefs.getBool('groupByWishlist') ?? false;
    });
  }

  Future<void> _saveGroupByBooleans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('groupByDirectorWishlist', _groupByDirector);
    await prefs.setBool('groupByGenreWishlist', _groupByGenre);
    await prefs.setBool('groupByReleaseYearWishlist', _groupByReleaseYear);
    await prefs.setBool('groupByFranchiseWishlist', _groupByFranchise);
    await prefs.setBool('groupByTagWishlist', _groupByTag);
    await prefs.setBool('groupByWishlist', _groupBy);
  }

  Future<void> _fetchMovies() async {
    try {
      final movies = await _service.getWishlistMovies();
      setState(() {
        _movies = movies;
        _filteredMovies = movies; // Initialize filtered list
        _sortMovies(); // Sort movies after fetching
      });
    } catch (e) {
      // If there's an error (like no internet), load from Hive
      final box = Hive.box<Movie>('movies');
      List<Movie> allMovies = box.values.toList();
      print(allMovies);
      List<Movie> movies = box.values.where((movie) => !movie.watched && movie.hidden == false).toList();
      setState(() {
        _movies = movies;
        _filteredMovies = _movies; // Initialize filtered list
        _allMovies = allMovies;
        _sortMovies(); // Sort movies after loading from Hive
      });
    }
  }

  String _ignoreThe(String title) {
    final lower = title.toLowerCase().trim();
    if (lower.startsWith('the ')) {
      return title.substring(4).trim();
    } else if (lower.startsWith('a ')) {
      return title.substring(2).trim();
    } else if (lower.startsWith('an ')) {
      return title.substring(3).trim();
    }
    return title;
  }

  void _sortMovies() {
    _filteredMovies.sort((a, b) {
      int comparison;
      if (_sortBy == 'movieName') {
        //if there is customSortTitle, sort according to that if not sort for movieName
        String aMovie = a.customSortTitle ?? a.movieName;
        String bMovie = b.customSortTitle ?? b.movieName;

        aMovie = _ignoreThe(aMovie);
        bMovie = _ignoreThe(bMovie);
        comparison = aMovie.compareTo(bMovie);
      } else if (_sortBy == 'releaseDate') {
        comparison = a.releaseDate.compareTo(b.releaseDate);
      } else if (_sortBy == 'directorName') {
        comparison = a.directorName.compareTo(b.directorName);
      } else if (_sortBy == 'imdbRating') {
        comparison = a.imdbRating!.compareTo(b.imdbRating!);
      } else if (_sortBy == 'runtime') {
        comparison = a.runtime!.compareTo(b.runtime!);
      } else if (_sortBy == 'creationDate') {
        comparison = a.creationDate!.compareTo(b.creationDate!);
      } else if (_sortBy == 'hypeScore') {
        comparison = a.hypeScore!.compareTo(b.hypeScore!);
      } else {
        comparison = 0; // Default case
      }
      return _isAscending ? comparison : -comparison;
    });
  }
  void _onSortByChanged(String newSortBy) {
    setState(() {
      _sortBy = newSortBy; // Yeni sıralama kriterini güncelle
      _saveSortPreferences(); // Sıralama tercihlerini kaydet
      _sortMovies(); // Filmleri sırala
    });
  }
  void _onSortDirChanged(String newSortDir) {
    setState(() {
      _sortDir = newSortDir; // Yeni sıralama yönünü güncelle
      _isAscending = newSortDir == 'Ascending'; // Sıralama yönünü ayarla
      _saveSortPreferences(); // Sıralama tercihlerini kaydet
      _sortMovies(); // Filmleri sırala
    });
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return SortWidget(
          isFromWishlist: true,
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
    print('xxxxx'+movie.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(isFromWishlist: true, movie: movie, userEmail: widget.userEmail, systemLanguage: widget.systemLanguage,),
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
    await prefs.setString('viewTypeWishlist', viewType);
  }

  void _toggleGroupBy(String value) {
    setState(() {
      // Tüm gruplamaları sıfırla
      _groupByDirector = false;
      _groupByGenre = false;
      _groupByReleaseYear = false;
      _groupByFranchise = false;
      _groupByTag = false;
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
        case 'Franchise':
          _groupByFranchise = true;
          _groupBy = true;
          break;
        case 'Tag':
          _groupByTag = true;
          _groupBy = true;
          break;
        default:
          // 'None' veya diğer durumlarda zaten tüm gruplamalar sıfırlanmış durumda
          break;
      }

      // Seçilen grup adını güncelle ve kaydet
      _groupByText = value;
      _saveGroupByText(value); // Grup metnini kaydet
      _saveGroupByBooleans(); // Group by boolean değerlerini kaydet
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
    print(movie.hidden);
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
            : _groupByGenre ? groupByGenre(_filteredMovies)
            : _groupByReleaseYear ? groupByYear(_filteredMovies, 'Release Date') 
            : _groupByFranchise ? groupByFranchise(_filteredMovies)
            : _groupByTag ? groupByTag(_filteredMovies)
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
        centerTitle: true,
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
                    if(_selectedMovies.length >= _filteredMovies.length) {
                      _selectedMovies.clear();
                    } else {
                      _selectedMovies.clear();
                    for (var movie in _filteredMovies) {
                      _selectedMovies.add(movie.id!.toString());
                     }
                    }          
                  });
            },
          ),
          IconButton(
            onPressed: () async {
              List<Movie> selectedMovies = _filteredMovies.where((movie) => _selectedMovies.contains(movie.id.toString())).toList();
              await exportRecommendationsToCSV(context, selectedMovies);
            }, 
            icon: Icon(
              Icons.share,
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.visibility, 
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
            ),
            onPressed: () {
             showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color.fromARGB(255, 44, 50, 60),
                  title: Text(
                    S.of(context).hideChosenMovies, 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
                    ),
                  ),
                  content: Text(
                    '${_selectedMovies.length} ${S.of(context).selectedMoviesHideConfirm}',
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
                      onPressed: () async {
                        Navigator.pop(context);
                          for (String movieId in _selectedMovies) {
                            final movie = _movies.firstWhere((m) => m.id.toString() == movieId);
                            await hideMovies(context, movie, false);
                          }
                          final snackBar = SnackBar(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          behavior: SnackBarBehavior.floating,
                          content: AwesomeSnackbarContent(
                            title: S.of(context).succesful, 
                            message:  S.of(context).moviesAreHidden, 
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
                      child: Text(
                        S.of(context).ok,  
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
          IconButton(
            icon: Icon(
              Icons.swap_horizontal_circle_outlined, 
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
            ),
            onPressed: () async {
              for (String movieId in _selectedMovies) {
                final movie = _movies.firstWhere((m) => m.id.toString() == movieId);
                await toggleWatchedStatus(context, movie, true, false); // true for collection,  false for canPop
              }
              final snackBar = SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              content: AwesomeSnackbarContent(
                title: S.of(context).succesful, 
                message:  S.of(context).moviesMovedToCollection, 
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
      )
      : AppBar(
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
        centerTitle: true,
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
          if(!_isSearching)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchController.clear();
                _filteredMovies = _movies;
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
        isFromWishlist: true, 
        movies: _movies, 
        allMovies: _allMovies,
        userPicture: widget.userPicture,
        userEmail: widget.userEmail,
        userName: widget.userName,
        userId: widget.userId,
        systemLanguage: widget.systemLanguage,
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
                            isFromWishlist: true,
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
                        isFromWishlist: true,
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
                      crossAxisCount: isTablet ? 5 : 3, // Tablet için 5, telefon için 3 sütun
                    childAspectRatio: isTablet 
                      ? (_viewType == "Card" ? 0.7 : 0.75)  // Tablet için aspect ratio
                      : (_viewType == "Card" ? 0.43 : 0.5), // Telefon için aspect ratio
                    mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                    ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: ScreenUtil.getAdaptivePadding(context),
                              itemCount: movies.length,
                              itemBuilder: (context, movieIndex) {
                                return MovieCard(
                                  movie: movies[movieIndex],
                                  isFromWishlist: true,
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
                      isFromWishlist: true,
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
                isFromWishlist: true, 
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