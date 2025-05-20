import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import '../widgets/movie_card.dart';
import '../models/movie_model.dart';
import '../sup/screen_util.dart';
import 'package:hive/hive.dart';

class ImportedMoviesScreen extends StatefulWidget {
  final List<Movie> importedMovies;
  final String systemLanguage;
  
  const ImportedMoviesScreen({
    super.key, 
    required this.importedMovies,
    required this.systemLanguage,
  });

  @override
  State<ImportedMoviesScreen> createState() => _ImportedMoviesScreenState();
}

class _ImportedMoviesScreenState extends State<ImportedMoviesScreen> {
  Set<String> _selectedMovies = {};
  bool _isSelectionMode = true;
  List<Movie> _sortedMovies = [];

  @override
  void initState() {
    super.initState();
    _sortMovies();
  }

  void _sortMovies() {
    _sortedMovies = List.from(widget.importedMovies);
    _sortedMovies.sort((a, b) {
      String aMovie = a.movieName;
      String bMovie = b.movieName;
      if(a.customSortTitle != null) { aMovie = a.customSortTitle!; }
      if(b.customSortTitle != null) { bMovie = b.customSortTitle!; }
      return aMovie.compareTo(bMovie);
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
    }
  }

  void _importSelectedMovies() {
    final moviesBox = Hive.box<Movie>('movies');
    
    // Seçili filmler arasında hasImportedSame true olan var mı kontrol et
    bool hasSameMovies = _selectedMovies.any((movieId) {
      final movie = widget.importedMovies.firstWhere((m) => m.id.toString() == movieId);
      return moviesBox.containsKey(movie.id);
    });

    if (hasSameMovies) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 44, 50, 60),
            title: Text(
              S.of(context).warning,
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              'Some of the selected movies are already in your collection. If you continue imported movies will update their counterpart in your collection. Do you want to continue?',//'S.of
              //Seçili filmler arasında zaten koleksiyonunuzda bulunan filmler var. Devam etmek istiyor musunuz?
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: Text(
                  S.of(context).cancel,
                  style: const TextStyle(color: Colors.white70),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  'Continue',//'S.of
                  style: const TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _performImport(moviesBox);
                },
              ),
            ],
          );
        },
      );
    } else {
      _performImport(moviesBox);
    }
  }

  void _performImport(Box<Movie> moviesBox) {
    int importedCount = 0;

    for (String movieId in _selectedMovies) {
      try {
        final movie = widget.importedMovies.firstWhere((m) => m.id.toString() == movieId);
        moviesBox.put(movie.id, movie);
        importedCount++;
      } catch (e) {
        print('Film eklenirken hata oluştu: $e');
      }
    }

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      content: AwesomeSnackbarContent(
        title: S.of(context).succesful, 
        message: '$importedCount ', //${S.of(context).moviesImported}
        contentType: ContentType.success, 
        inMaterialBanner: true,
      ), 
      dismissDirection: DismissDirection.horizontal,
    );
    
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showSnackBar(snackBar);

    Navigator.pop(context, importedCount);
  }

  @override
  Widget build(BuildContext context) {
    final moviesBox = Hive.box<Movie>('movies');
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: ScreenUtil.getAdaptiveIconSize(context, 24),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: Colors.white,
            size: ScreenUtil.getAdaptiveIconSize(context, 24),
          ),
          onPressed: () {
            if (_selectedMovies.isEmpty) {
              final snackBar = SnackBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                behavior: SnackBarBehavior.floating,
                content: AwesomeSnackbarContent(
                  title: 'S.of(context).warning', 
                  message: 'S.of(context).noMoviesImported', 
                  contentType: ContentType.warning, 
                  inMaterialBanner: true,
                ), 
                dismissDirection: DismissDirection.horizontal,
              );
              
              ScaffoldMessenger.of(context)
                ..hideCurrentMaterialBanner()
                ..showSnackBar(snackBar);
            }
            Navigator.pop(context, 0);
          },
        ),
        centerTitle: true,
        title: Text(
          '${widget.importedMovies.length} ${S.of(context).movies}', 
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
                if(widget.importedMovies.length == _selectedMovies.length) {
                  _selectedMovies.clear();
                } else {
                  _selectedMovies.clear();
                for (var movie in widget.importedMovies) {
                  _selectedMovies.add(movie.id!.toString());
                 }
                }
              });
            },
          ),
        ],
      ),
      body: widget.importedMovies.isEmpty 
        ? Center(
            child: Text(
              S.of(context).noMoviesFound,
              style: TextStyle(
                color: Colors.white60,
                fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
              ),
            ),
          )
        : ListView.builder(
            itemCount: _sortedMovies.length,
            itemBuilder: (context, index) {
              return MovieCard(
                movie: _sortedMovies[index],
                isFromWishlist: !_sortedMovies[index].watched,
                viewType: 'List',
                isSelected: _selectedMovies.contains(_sortedMovies[index].id.toString()),
                selectionMode: true,
                onTap: () => _handleMovieTap(_sortedMovies[index]),
                onLongPress: () {}, //return null
                hasImportedSame: moviesBox.containsKey(_sortedMovies[index].id),
              );
            },
          ),
      floatingActionButton: _selectedMovies.isNotEmpty
        ? FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: _importSelectedMovies,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: ScreenUtil.getAdaptiveIconSize(context, 24),
            ),
          )
        : null,
    );
  }
} 