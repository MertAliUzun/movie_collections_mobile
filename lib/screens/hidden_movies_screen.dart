import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import '../widgets/movie_card.dart';
import '../models/movie_model.dart';
import '../sup/businessLogic.dart';
import '../sup/screen_util.dart';
import 'package:hive/hive.dart';
import 'edit_movie_screen.dart';

class HiddenMoviesScreen extends StatefulWidget {
  final String? userEmail;
  final String? systemLanguage;
  final bool? isFromWishlist;
  
  const HiddenMoviesScreen({
    super.key, 
    this.userEmail, 
    this.systemLanguage,
    this.isFromWishlist
  });

  @override
  State<HiddenMoviesScreen> createState() => _HiddenMoviesScreenState();
}

class _HiddenMoviesScreenState extends State<HiddenMoviesScreen> {
  List<Movie> _hiddenMovies = [];
  List<Movie> _filteredMovies = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedMovies = {};
  bool get _isSelectionMode => _selectedMovies.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchHiddenMovies();
  }

  Future<void> _fetchHiddenMovies() async {
    final box = Hive.box<Movie>('movies');
    List<Movie> hiddenMovies = box.values.where((movie) => movie.hidden == true).toList();
    
    // Filmleri isme göre sırala
    hiddenMovies.sort((a, b) {
      String aMovie = a.customSortTitle ?? a.movieName;
      String bMovie = b.customSortTitle ?? b.movieName;
      return aMovie.compareTo(bMovie);
    });
    
    setState(() {
      _hiddenMovies = hiddenMovies;
      _filteredMovies = hiddenMovies;
    });
  }

  void _searchMovies(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMovies = _hiddenMovies;
      });
    } else {
      setState(() {
        _filteredMovies = _hiddenMovies.where((movie) {
          return movie.movieName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void _navigateToEditMovieScreen(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(
          isFromWishlist: !movie.watched, 
          movie: movie, 
          userEmail: widget.userEmail, 
          systemLanguage: widget.systemLanguage,
        ),
      ),
    ).then((_) {
      _fetchHiddenMovies();
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

  void _restoreSelectedMovies() async {
    bool hasError = false;
    for (String movieId in _selectedMovies) {
      try {
        final movie = _hiddenMovies.firstWhere((m) => m.id.toString() == movieId);
        await hideMovies(context, movie, false);
      } catch (e) {
        hasError = true;
      }
    }

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      content: AwesomeSnackbarContent(
        title: S.of(context).succesful, 
        message: hasError 
          ? 'S.of(context).someMoviesRestoredWithErrors' 
          : '${_selectedMovies.length} ${'S.of(context).moviesRestored'}', 
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
    
    // Listeyi güncelle
    await _fetchHiddenMovies();
  }

  void _deleteSelectedMovies() {
    final box = Hive.box<Movie>('movies');
    bool hasError = false;

    for (String movieId in _selectedMovies) {
      try {
        // Hive'dan silinecek filmleri bul
        for (var movie in box.values) {
          if (movie.id == movieId) {
            // Eğer film ID'si eşleşiyorsa, sil
            box.delete(movie.id);
            break;
          }
        }
      } catch (e) {
        hasError = true;
      }
    }

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      content: AwesomeSnackbarContent(
        title: S.of(context).succesful, 
        message: hasError 
          ? 'S.of(context).someMoviesDeletedWithErrors' 
          : '${_selectedMovies.length} ${S.of(context).moviesDeleted}', 
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
    
    // Listeyi güncelle
    _fetchHiddenMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: _isSelectionMode 
        ? AppBar(
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
                    _selectedMovies.clear();
                    for (var movie in _filteredMovies) {
                      _selectedMovies.add(movie.id!.toString());
                    }
                  });
                },
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
                        'S.of(context).restoreHiddenMovies', 
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
                        ),
                      ),
                      content: Text(
                        '${_selectedMovies.length} ${'S.of(context).selectedMoviesRestoreConfirm'}',
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
                            _restoreSelectedMovies();
                          },
                          child: Text(
                            S.of(context).ok,  
                            style: TextStyle(
                              color: Colors.green,
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
                  Icons.delete_forever, 
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
            leading: _isSearching 
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back, 
                    color: Colors.white,
                    size: ScreenUtil.getAdaptiveIconSize(context, 24),
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      _filteredMovies = _hiddenMovies;
                    });
                  },
                ) 
              : IconButton(
                  icon: Icon(
                    Icons.arrow_back, 
                    color: Colors.white,
                    size: ScreenUtil.getAdaptiveIconSize(context, 24),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
            centerTitle: true,
            title: !_isSearching 
              ? Text(
                  '${_hiddenMovies.length} ${'S.of(context).hiddenMovies'}', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: ScreenUtil.getAdaptiveTextSize(context, 18),
                  ),
                )
              : TextField(
                  controller: _searchController,
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
                    border: InputBorder.none,
                  ),
                  onChanged: _searchMovies,
                ),
            actions: [
              if (!_isSearching)
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
            ],
          ),
      body: _hiddenMovies.isEmpty 
        ? Center(
            child: Text(
              'S.of(context).noHiddenMovies',
              style: TextStyle(
                color: Colors.white60,
                fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
              ),
            ),
          )
        : ListView.builder(
            itemCount: _filteredMovies.length,
            itemBuilder: (context, index) {
              return MovieCard(
                movie: _filteredMovies[index],
                isFromWishlist: !_filteredMovies[index].watched,
                viewType: 'List',
                isSelected: _selectedMovies.contains(_filteredMovies[index].id.toString()),
                selectionMode: _isSelectionMode,
                onTap: () => _handleMovieTap(_filteredMovies[index]),
                onLongPress: () => _handleMovieSelection(_filteredMovies[index]),
              );
            },
          ),
    );
  }
} 