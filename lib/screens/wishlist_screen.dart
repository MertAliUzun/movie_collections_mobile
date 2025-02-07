import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../sup/businessLogic.dart';
import '../sup/groupBy.dart';
import '../services/supabase_service.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/movie_card.dart';
import '../models/movie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_movie_screen.dart';
import 'edit_movie_screen.dart';
import '../widgets/sort_widget.dart';
import 'dart:convert';
import 'package:hive/hive.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final SupabaseService _service = SupabaseService(Supabase.instance.client);
  List<Movie> _movies = [];
  List<Movie> _filteredMovies = [];
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
  bool _groupBy = false;
  Set<String> _selectedMovies = {};
  bool get _isSelectionMode => _selectedMovies.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadViewType();
    _fetchMovies();
  }

  Future<void> _loadViewType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _viewType = prefs.getString('viewType') ?? 'List';
    });
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
      List<Movie> movies = box.values.where((movie) => !movie.watched).toList();
      setState(() {
        _movies = movies;
        _filteredMovies = _movies; // Initialize filtered list
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(isFromWishlist: true, movie: movie),
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
        _selectedMovies.add(movie.id!.toString());
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
      print(movieId);
      for (var movie in box.values) {
        if (movie.id == movieId) {
      // Eğer film ID'si eşleşiyorsa, sil
      box.delete(movie.id);
      print('Film ID $movieId silindi.');
      }
     }
    }
    final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: 'Success!', 
          message: '${_selectedMovies.length} movies deleted.', 
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

    // Group movies by director or genre based on the selected option
    Map<String, List<Movie>> groupedMovies = _groupByDirector
        ? groupByDirector(_filteredMovies)
        : _groupByGenre
            ? groupByGenre(_filteredMovies)
            : _groupByReleaseYear ? groupByYear(_filteredMovies, 'Release Date') 
            : {};

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: _isSelectionMode ? AppBar(
        backgroundColor: Color.fromARGB(255, 44, 50, 60),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedMovies.clear();
            });
          },
        ),
        title: Text('${_selectedMovies.length} film seçildi', 
          style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedMovies.clear();
                for (var movie in _filteredMovies) {
                  if (!movie.watched) {
                    _selectedMovies.add(movie.id!.toString());
                  }
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.input, color: Colors.white),
            onPressed: () async {
              for (String movieId in _selectedMovies) {
                final movie = _movies.firstWhere((m) => m.id.toString() == movieId);
                await toggleWatchedStatus(context, movie, true, false); // true for collection,  false for canPop
              }
              setState(() {
                _selectedMovies.clear();
              });
              await _fetchMovies(); // Sayfayı yenile
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color.fromARGB(255, 44, 50, 60),
                  title: Text('Seçili filmleri sil', 
                    style: TextStyle(color: Colors.white)),
                  content: Text('${_selectedMovies.length} filmi silmek istediğinize emin misiniz?',
                    style: TextStyle(color: Colors.white)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('İptal', style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteSelectedMovies();
                      },
                      child: Text('Sil', style: TextStyle(color: Colors.red)),
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
        iconTheme: IconThemeData(color: Colors.white),
        leading: _isSearching ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
            });
          },
        ) : null,
        title: !_isSearching 
        ? Text('${_movies.length} Film', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04 ),)
        : SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.05,
          child: TextField(
            focusNode: FocusNode(),
            controller: _searchController,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: const InputDecoration(
              hintText: 'Film adı ile ara...',
              hintStyle: const TextStyle(color: Colors.white54),
              //prefixIcon: const Icon(Icons.search, color: Colors.white54,),
              //border: OutlineInputBorder(),
              //filled: true,
              fillColor: Colors.transparent,
            ),
            style: TextStyle(color: Colors.white),
            onChanged: _searchMovies,
          ),
        ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteSelectedMovies,
            ),
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
      drawer: _isSelectionMode || _isSearching ? null : DrawerWidget(viewType: _viewType, groupByText: _groupByText, sortBy: _sortBy, changeViewType: _changeViewType, toggleGroupBy: _toggleGroupBy, onSortByChanged: _onSortByChanged, sortDir: _sortDir, onSortDirChanged: _onSortDirChanged, isFromWishlist: true, movies: _movies,),
      body: Column(
        children: [
          Expanded(
            child: _viewType.contains('List')
                ? ListView.builder(
                    itemCount: _groupBy ? groupedMovies.keys.length : _filteredMovies.length,
                    itemBuilder: (context, index) {
                      if (_groupBy) {
                        //to sort directorCards by directorName
                        List<String> sortedMovies = groupedMovies.keys.toList()..sort();
                        String sortName = sortedMovies[index];
                        List<Movie> movies = groupedMovies[sortName]!;
                        if(_groupByDirector){ movies.sort((a, b) => a.directorName.compareTo(b.directorName),); }
                        //else { movies.sort((a, b) => (a.genres ?? '').compareTo(b.genres ?? ''));}
                        //
                        return ExpansionTile(
                          title: Text(sortName, style: const TextStyle(color: Colors.white)),
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
                  )
                :_groupBy ? ListView.builder(
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
                      crossAxisCount: 3, // 3 cards per row
                      childAspectRatio: _viewType == "Card" ? 0.5 : 0.55, // Adjust the aspect ratio as needed
                    ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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
                  ) : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 cards per row
                      childAspectRatio: _viewType == "Card" ? 0.5 : 0.55, // Adjust the aspect ratio as needed
                    ),
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
              builder: (context) => const AddMovieScreen(isFromWishlist: true),
            ),
          ).then((_) {
            _fetchMovies(); // Refresh the movie list when returning
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 