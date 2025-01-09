import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../aux/groupBy.dart';
import '../services/supabase_service.dart';
import '../widgets/movie_card.dart';
import '../models/movie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_movie_screen.dart';
import 'edit_movie_screen.dart';
import '../widgets/sort_widget.dart';

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
  bool _isAscending = true; // Default sorting order
  bool _isSearching = false; // Track if searching
  final TextEditingController _searchController = TextEditingController();
  String _viewType = 'List'; // Default view type
  String _groupByText = 'None';
  bool _groupByDirector = false; // Track if grouping by director
  bool _groupByGenre = false; // Track if grouping by genre
  bool _groupBy = false;

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
    final movies = await _service.getWishlistMovies();
    setState(() {
      _movies = movies;
      _filteredMovies = movies; // Initialize filtered list
      _sortMovies(); // Sort movies after fetching
    });
  }

  void _sortMovies() {
    _filteredMovies.sort((a, b) {
      int comparison;
      if (_sortBy == 'movieName') {
        comparison = a.movieName.compareTo(b.movieName);
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
      _groupByText = value;
      if (value == 'Director') {
        _groupByDirector = true;
        _groupByGenre = false; // Reset genre grouping
        _groupBy = true;
      } else if (value == 'Genre') {
        _groupByGenre = true;
        _groupByDirector = false; // Reset director grouping
        _groupBy = true;
      } else {
        _groupByDirector = false;
        _groupByGenre = false; // Reset both
        _groupBy = false;
      }
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
            : {};

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: IconThemeData(color: Colors.white),
        title: !_isSearching 
        ? Text('${_movies.length} Film', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04 ),)
        : SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.05,
          child: TextField(
            controller: _searchController,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: const InputDecoration(
              hintText: 'Film adı ile ara...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _searchMovies,
          ),
        ),
        actions: [
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
          if(!_isSearching)
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: _showSortOptions,
          ),
          if(!_isSearching)
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onSelected: _toggleGroupBy,
            color: Color.fromARGB(255, 44, 50, 60),
            itemBuilder: (BuildContext context) {
              return {'None', 'Director', 'Genre'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice, style: const TextStyle(color: Colors.white)),
                );
              }).toList();
            },
          ),
          if(!_isSearching)
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_list, color: Colors.white),
            onSelected: _changeViewType,
            color: Color.fromARGB(255, 44, 50, 60),
            itemBuilder: (BuildContext context) {
              return {'List', 'List(Small)', 'Card', 'Poster'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice, style: TextStyle(color: Colors.white),),
                );
              }).toList();
            },
          ),
        ],
      ),
      drawer: Container(
        padding: EdgeInsets.only(top: screenHeight *0.1),
        width: screenWidth * 0.7,
        child: Drawer(
          backgroundColor: Color.fromARGB(255, 44, 50, 60),
          child: ListView(
            children: [
              DrawerHeader(child: Icon(Icons.home, size: 50)),
              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('View As', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),),
                    Container(
                      width: screenWidth * 0.55,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                        child: DropdownButton<String>(
                         value: _viewType, // Seçili değeri göster
                         icon: Padding(
                           padding: EdgeInsets.fromLTRB(screenWidth * 0.15, 0, 0, 0),
                           child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                         ),
                         dropdownColor: const Color.fromARGB(255, 44, 50, 60), // Menü arka plan rengi
                         underline: SizedBox(), // Alt çizgiyi kaldır
                         onChanged: (Object? newValue) {
                                     if(newValue is String) {
                                       _changeViewType(newValue);
                                     }}, // Seçim yapıldığında çalışacak fonksiyon
                         items: ['List', 'List(Small)', 'Card', 'Poster'].map((String choice) {
                           return DropdownMenuItem<String>(
                             value: choice,
                             child: Text(
                               choice,
                               style: TextStyle(fontSize: screenWidth * 0.055, color: Colors.white60), // Yazı rengi
                             ),
                           );
                         }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
               title: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     'Group By',
                     style: TextStyle(
                       color: Colors.white,
                       fontSize: screenWidth * 0.033,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   Container(
                     width: screenWidth * 0.55,
                     child: Padding(
                       padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                       child: DropdownButton<String>(
                         value: _groupByText, // Seçili değeri göster
                         icon: Padding(
                           padding: EdgeInsets.fromLTRB(screenWidth * 0.225, 0, 0, 0),
                           child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                         ),
                         dropdownColor: const Color.fromARGB(255, 44, 50, 60), // Menü arka plan rengi
                         underline: SizedBox(), // Alt çizgiyi kaldır
                         onChanged: (String? newValue) {
                           if (newValue != null) {
                             _toggleGroupBy(newValue);
                           }
                         }, // Seçim yapıldığında çalışacak fonksiyon
                         items: ['None', 'Director', 'Genre'].map((String choice) {
                           return DropdownMenuItem<String>(
                             value: choice,
                             child: Text(
                               choice,
                               style: TextStyle(
                                 fontSize: screenWidth * 0.055,
                                 color: Colors.white60,
                               ), // Yazı rengi
                             ),
                           );
                         }).toList(),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
            ],
          )
        ),
      ),
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
                              onTap: () => _navigateToEditMovieScreen(movie),
                            );
                          }).toList(),
                        );
                      } else {
                        return MovieCard(
                          movie: _filteredMovies[index],
                          isFromWishlist: true,
                          viewType: _viewType,
                          onTap: () => _navigateToEditMovieScreen(_filteredMovies[index]),
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
                      childAspectRatio: _viewType == "Card" ? 0.64 : 0.55, // Adjust the aspect ratio as needed
                    ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: movies.length,
                              itemBuilder: (context, movieIndex) {
                                return MovieCard(
                                  movie: movies[movieIndex],
                                  isFromWishlist: true,
                                  viewType: _viewType,
                                  onTap: () => _navigateToEditMovieScreen(movies[movieIndex]),
                                );
                              },
                            ),
                          ],
                        );
                    },
                  ) : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 cards per row
                      childAspectRatio: _viewType == "Card" ? 0.64 : 0.55, // Adjust the aspect ratio as needed
                    ),
                    itemCount: _filteredMovies.length,
                    itemBuilder: (context, index) {
                      return MovieCard(
                        movie: _filteredMovies[index],
                        isFromWishlist: true,
                        viewType: _viewType,
                        onTap: () => _navigateToEditMovieScreen(_filteredMovies[index]),
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