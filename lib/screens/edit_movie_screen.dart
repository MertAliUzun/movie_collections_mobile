import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movie_collections_mobile/widgets/person_movies_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'dart:async';
import '../aux/businessLogic.dart';
import '../aux/genreMap.dart';
import '../models/movie_model.dart';
import '../services/supabase_service.dart';
import '../services/tmdb_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:country_flags/country_flags.dart';
import 'director_screen.dart';
import 'genre_movies_screen.dart';
import 'company_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hive/hive.dart';

class EditMovieScreen extends StatefulWidget {
  final bool isFromWishlist;
  final Movie? movie;

  const EditMovieScreen({super.key, required this.isFromWishlist, this.movie});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _movieNameController = TextEditingController();
  final _directorNameController = TextEditingController();
  final _plotController = TextEditingController();
  final _runtimeController = TextEditingController();
  final _imdbRatingController = TextEditingController();
  final _writersController = TextEditingController();
  final _actorsController = TextEditingController();
  final _productionCompanyController = TextEditingController();
  final _countryController = TextEditingController();
  final _popularityController = TextEditingController();
  final _budgetController = TextEditingController();
  final _revenueController = TextEditingController();
  final _sortTitleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _watchedDate = DateTime.now();
  double _userScore = 0.0;
  double _hypeScore = 0.0;
  File? _selectedImage;
  bool _isUploading = false;
  String? _imageLink;
  final cloudinary = CloudinaryPublic('dper5kp88', 'YOUR_UPLOAD_PRESET', cache: false);
  List<String> _selectedGenres = [];
  List<String> _selectedActors = [];
  List<String> _selectedWriters = [];
  List<String> _selectedProductionCompanies = [];
  List<Map<String, dynamic>> _similarMovies = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

    Future<void> _watchDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _watchedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _watchedDate) {
      setState(() {
        _watchedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      setState(() {
        _isUploading = true;
      });

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          _selectedImage!.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      _imageLink = response.secureUrl;
      return _imageLink;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim yükleme hatası: $e')),
        );
      }
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      final supabase = Supabase.instance.client;
      final service = SupabaseService(supabase);

      final movie = Movie(
        id: widget.movie!.id,
        movieName: _movieNameController.text,
        directorName: _directorNameController.text,
        releaseDate: _selectedDate,
        plot: _plotController.text.isNotEmpty ? _plotController.text : null,
        runtime: _runtimeController.text.isNotEmpty 
            ? int.tryParse(_runtimeController.text) 
            : null,
        imdbRating: _imdbRatingController.text.isNotEmpty 
            ? double.tryParse(_imdbRatingController.text) 
            : null,
        writers: _selectedWriters.isNotEmpty 
            ? _selectedWriters
            : null,
        actors: _selectedActors.isNotEmpty 
            ? _selectedActors 
            : null,
        watchDate: widget.isFromWishlist ? null : _watchedDate,
        userScore: widget.isFromWishlist ? null : _userScore,
        hypeScore: widget.isFromWishlist ? _hypeScore : null,
        watched: !widget.isFromWishlist,
        imageLink: _imageLink ?? '',
        userEmail: 'test@test.com',
        genres: _selectedGenres,
        productionCompany: _selectedProductionCompanies,
        customSortTitle: _sortTitleController.text.isNotEmpty ? _sortTitleController.text : null,
      );

      // Check for internet connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult[0] == ConnectivityResult.none) {
        // Save to local storage if no internet
        await _saveMovieToLocalStorage(movie);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Film güncellendi, internet bağlantısı sağlandığında senkronize edilecek.')),
        );
      } else {
        // Save to database if internet is available
      try {
        await service.updateMovie(movie);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Film başarıyla güncellendi')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata oluştu: $e')),
          );
        }
      }
    }
    }
  }

  Future<void> _saveMovieToLocalStorage(Movie movie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String movieStorage = widget.isFromWishlist ? 'wishlistMovies' : 'collectionMovies' ;
    String? moviesString = prefs.getString(movieStorage);
    List<Movie> movies = [];

    if (moviesString != null) {
      List<dynamic> jsonList = jsonDecode(moviesString);
      movies = jsonList.map((m) => Movie.fromJson(m)).toList();
    }

    // Check for duplicates
    if (!movies.any((m) => m.movieName == movie.movieName)) {
      movies.add(movie);
      await prefs.setString(movieStorage, jsonEncode(movies));
    }
  }

  void _deleteMovie() {
    final box = Hive.box<Movie>('movies');
    
    // Film ID'sini al
    String movieId = widget.movie!.id!;

    // Hive'dan sil
    box.delete(movieId);

    // Kullanıcıya bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Film silindi.')),
    );

    // Geri dön
    Navigator.pop(context);
  }

  void _toggleWatchedStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Update in local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String oldStorage = widget.isFromWishlist ? 'wishlistMovies' : 'collectionMovies';
      String newStorage = widget.isFromWishlist ? 'collectionMovies' : 'wishlistMovies';
      
      // Remove from old storage
      String? oldMoviesString = prefs.getString(oldStorage);
      if (oldMoviesString != null) {
        List<dynamic> jsonList = jsonDecode(oldMoviesString);
        List<Movie> movies = jsonList.map((m) => Movie.fromJson(m)).toList();
        movies.removeWhere((m) => m.id == widget.movie!.id);
        await prefs.setString(oldStorage, jsonEncode(movies));
      }

      // Add to new storage with updated watched status
      String? newMoviesString = prefs.getString(newStorage);
      List<Movie> newMovies = [];
      if (newMoviesString != null) {
        List<dynamic> jsonList = jsonDecode(newMoviesString);
        newMovies = jsonList.map((m) => Movie.fromJson(m)).toList();
      }
      
      final updatedMovie = Movie(
        id: widget.movie!.id,
        movieName: widget.movie!.movieName,
        directorName: widget.movie!.directorName,
        releaseDate: widget.movie!.releaseDate,
        plot: widget.movie!.plot,
        runtime: widget.movie!.runtime,
        imdbRating: widget.movie!.imdbRating,
        writers: widget.movie!.writers,
        actors: widget.movie!.actors,
        watched: !widget.movie!.watched,
        imageLink: widget.movie!.imageLink,
        userEmail: widget.movie!.userEmail,
        watchDate: !widget.isFromWishlist ? DateTime.now() : null,
        userScore: widget.isFromWishlist ? null : 0,
        hypeScore: !widget.isFromWishlist ? null : widget.movie!.hypeScore,
        genres: widget.movie!.genres,
        productionCompany: widget.movie!.productionCompany,
        customSortTitle: widget.movie!.customSortTitle,
      );
      
      newMovies.add(updatedMovie);
      await prefs.setString(newStorage, jsonEncode(newMovies));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Film durumu güncellendi, internet bağlantısı sağlandığında senkronize edilecek.')),
      );
      Navigator.pop(context, true);
    } else {
      // Existing online functionality
      final supabase = Supabase.instance.client;
      final service = SupabaseService(supabase);
      try {
        final updatedMovie = widget.movie!;
        updatedMovie.watched = widget.isFromWishlist ? true : false;
        if (widget.isFromWishlist) {
          
          updatedMovie.userScore = 0.0;
          updatedMovie.watchDate = DateTime.now();
          updatedMovie.hypeScore = null;
        } else {
          updatedMovie.hypeScore = 0.0;
          updatedMovie.userScore = null;
          updatedMovie.watchDate = null;
        }
        await service.updateMovie(updatedMovie);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.isFromWishlist ? 'Film koleksiyona taşındı.' : 'Film istek listesine taşındı.')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Güncelleme hatası: $e')),
          );
        }
      }
    }
  }

  void _showAddOptionsMenu(BuildContext context) {
    showMenu(
      color: const Color.fromARGB(255, 44, 50, 60),
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0), // Adjust position as needed
      items: [
        PopupMenuItem<String>(
          value: 'add_genre',
          child: const Text('Add Genre', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_actor',
          child: const Text('Add Actor', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_writer',
          child: const Text('Add Writer', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_producer',
          child: const Text('Add Production Company', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'add_genre':
            _addDetails('Add Genre', (genre) {
              setState(() {
                _selectedGenres.add(genre);
              });
            });
            break;
          case 'add_actor':
            _addDetails('Add Actor', (actor) {
              setState(() {
                _selectedActors.add(actor);
              });
            });
            break;
          case 'add_writer':
            _addDetails('Add Writer', (writer) {
              setState(() {
                _selectedWriters.add(writer);
              });
            });
            break;
          case 'add_producer':
            _addDetails('Add Production Company', (company) {
              setState(() {
                _selectedProductionCompanies.add(company);
              });
            });
            break;
        }
      }
    });
  }

  Future<void> _addDetails(String title, Function(String) onAdd) async {
    String input = '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 44, 50, 60),
          title: Text(title, style: TextStyle(color: Colors.white)),
          content: TextField(
            style: TextStyle(color: Colors.white),
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(hintText: 'Please Enter', hintStyle: TextStyle(color: Colors.white)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(input);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null && value.isNotEmpty) {
        onAdd(value);
      }
    });
  }

  void _editDirector() {
    editDirector(context, _directorNameController);
  }

  //DELETE BUSINESS
  void _deleteDirector() async {
    final confirm = await deleteDetailsConfirm(context, 'yönetmen');
    
    if (confirm) {
      setState(() {
        _directorNameController.clear(); // Clear the director name
      });
    }
  }
  void _deleteGenre(int index) {
    deleteDetails(context, 'genre', index: index, selected: _selectedGenres, onDelete: () {
      setState(() {
        // This will trigger a rebuild of the widget tree
      });
    });
  }
  void _deleteActor(int index) {
    deleteDetails(context, 'actor', index: index, selected: _selectedActors, onDelete: () {
      setState(() {
        // This will trigger a rebuild of the widget tree
      });
    });
  }
  void _deleteWriter(int index) {
    deleteDetails(context, 'writer', index: index, selected: _selectedWriters, onDelete: () {
      setState(() {
        // This will trigger a rebuild of the widget tree
      });
    });
  }
  void _deleteCompany(int index) {
    deleteDetails(context, 'company', index: index, selected: _selectedProductionCompanies, onDelete: () {
      setState(() {
        // This will trigger a rebuild of the widget tree
      });
    });
  }
  
  String _formatCurrency(double? value) {
    if (value == null) return '\$0.00';
    final formatter = NumberFormat.simpleCurrency(locale: 'en_US');
    return formatter.format(value);
  }

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _movieNameController.text = widget.movie!.movieName;
      _directorNameController.text = widget.movie!.directorName;
      _plotController.text = widget.movie!.plot ?? '';
      _runtimeController.text = widget.movie!.runtime?.toString() ?? '';
      _imdbRatingController.text = widget.movie!.imdbRating?.toString() ?? '';
      _writersController.text = widget.movie!.writers?.join(', ') ?? '';
      _actorsController.text = widget.movie!.actors?.join(', ') ?? '';
      _productionCompanyController.text = widget.movie!.productionCompany?.join(', ') ?? '';
      _countryController.text = widget.movie!.country ?? '';
      _popularityController.text = widget.movie!.popularity?.toString() ?? '';
      _budgetController.text = widget.movie!.budget?.toString() ?? '';
      _revenueController.text = widget.movie!.revenue?.toString() ?? '';
      _selectedDate = widget.movie!.releaseDate;
      _imageLink = widget.movie!.imageLink;
      _userScore = widget.movie!.userScore ?? 0;
      _hypeScore = widget.movie!.hypeScore ?? 0;
      _selectedGenres = widget.movie!.genres ?? [];
      _selectedActors = widget.movie!.actors ?? [];
      _selectedWriters = widget.movie!.writers ?? [];
      _selectedProductionCompanies = widget.movie!.productionCompany ?? [];
      _sortTitleController.text = widget.movie!.customSortTitle ?? '';
      _fetchSimilarMovies();
    }
  }

  Future<void> _fetchSimilarMovies() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Skip fetching similar movies if there's no internet
      return;
    }

    try {
      final tmdbService = TmdbService();
      final movieDetails = await tmdbService.searchMovies(widget.movie!.movieName);
      if (movieDetails.isNotEmpty) {
        final movieId = movieDetails[0]['id'];
        if(movieId < 0) { return; }
        final similarMovies = await tmdbService.getSimilarMovies(movieId);
        if(similarMovies != null) {
      setState(() {
        _similarMovies = similarMovies.where((movie) => movie['original_language'] == 'en')
          .where((movie) => movie['poster_path'] != null)
          .take(6) // İlk 6 filmi al
          .map((movie) => Map<String, dynamic>.from(movie)) // Filmleri Map formatında döndür
          .toList();;
      });
    }
      }
    } catch (e) {
      print('Error fetching similar movies: $e');
    }
  }

  Future<void> _fetchMovieDetails(int movieId) async {
    final tmdbService = TmdbService();
    final movieDetails = await tmdbService.getMovieDetails(movieId);
    final similarMovies = await tmdbService.getSimilarMovies(movieId);
    if(similarMovies != null) {
      setState(() {
        _similarMovies = similarMovies.where((movie) => movie['original_language'] == 'en')
          .where((movie) => movie['poster_path'] != null)
          .take(6) // İlk 6 filmi al
          .map((movie) => Map<String, dynamic>.from(movie))
          .toList();
          
      });

    }
    if (movieDetails != null) {
      setState(() {
        _movieNameController.text = movieDetails['title'] ?? '';
        _directorNameController.text = movieDetails['credits']['crew']
            .firstWhere((crew) => crew['job'] == 'Director', orElse: () => {'name': ''})['name'] ?? '';
        _plotController.text = movieDetails['overview'] ?? '';
        _runtimeController.text = movieDetails['runtime']?.toString() ?? '';
        _imdbRatingController.text = movieDetails['vote_average'].toString().length >= 3 ? 
            movieDetails['vote_average']?.toString().substring(0,3) ?? '' : 
            movieDetails['vote_average']?.toString() ?? '';
        _selectedDate = DateTime.parse(movieDetails['release_date'] ?? DateTime.now().toString());
        _imageLink = 'https://image.tmdb.org/t/p/w500${movieDetails['poster_path']}';
        _selectedGenres = movieDetails['genres'] != null 
              ? List<String>.from(movieDetails['genres'].take(4).map((genre) => genre['name'])) 
              : [];
        _selectedActors = movieDetails['credits']['cast'] != null 
              ? List<String>.from(movieDetails['credits']['cast'].take(6).map((actor) => actor['name'])) 
              : [];
        _selectedWriters = movieDetails['credits']['crew'] != null 
              ? List<String>.from(movieDetails['credits']['crew'].where((member) => member['department'] == 'Writing').take(3).map((writer) => writer['name'])) 
              : [];
        _selectedProductionCompanies = movieDetails['production_companies'] != null 
              ? List<String>.from(movieDetails['production_companies'].take(2).map((company) => company['name']))
              : [];
        _countryController.text = movieDetails['production_countries'] != null 
              ? movieDetails['production_countries'].take(1).map((country) => country['iso_3166_1']).join(', ') 
              : '';
        _popularityController.text = movieDetails['popularity']?.toString() ?? '';
        _budgetController.text = movieDetails['budget']?.toString() ?? '';
        _revenueController.text = movieDetails['revenue']?.toString() ?? '';
        // Populate other fields as necessary
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0, // 0.0'a kaydırmak sayfanın başı demektir
      duration: Duration(seconds: 1), // Kaydırma süresi
      curve: Curves.easeInOut, // Animasyon tipi
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        title: const Text('Film Detayları', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.input, color: Colors.white),
            onPressed: _toggleWatchedStatus,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showAddOptionsMenu(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          if(_imageLink != null && _imageLink!.isNotEmpty)
            Positioned.fill(
             child: Image.network(
               _imageLink!, // Resim URL'si
               fit: BoxFit.cover, // Tüm alanı kaplar
             ),
           ),
           if(_imageLink == null)
           Positioned.fill(
              child: Image.asset(
                'assets/images/placeholder_poster.png', 
                fit: BoxFit.cover,)),
           if(_imageLink != null)
           Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Siyah yarı saydam filtre
            ),
          ),  
          SingleChildScrollView(
          controller: _scrollController,
          //padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _movieNameController,
                    decoration: const InputDecoration(labelText: 'Film Adı *', labelStyle: TextStyle(color: Colors.white54)),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen film adını girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                    controller: _sortTitleController,
                    decoration: const InputDecoration(labelText: 'Custom Sort Title', labelStyle: TextStyle(color: Colors.white54),),
                style: const TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: screenWidth * 0.1),
                  Text('Genres', style: TextStyle(color: Colors.white, fontSize: 16),),
                  Divider(height: 10, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.03),
                  _selectedGenres.isNotEmpty
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:  _selectedGenres.length >= 5 ? 4 : _selectedGenres.length > 2 ? _selectedGenres.length :2,
                            childAspectRatio: 1.5,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedGenres.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                _deleteGenre(index);
                              },
                              onTap: () async {
                                final movieId = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GenreMoviesScreen(genre: _selectedGenres[index]),
                                  ),
                                );
                                if (movieId != null) {
                                  _fetchMovieDetails(movieId);
                                }
                              },
                              child: Card(
                                color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      _selectedGenres[index],
                                      style: TextStyle(color: Colors.white, 
                                      fontSize: _selectedGenres.length <= 2 ? screenWidth * 0.055 : 
                                      _selectedGenres.length == 3 ? screenWidth * 0.04 : screenWidth * 0.03, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Text('No Genres Selected', style: TextStyle(color: Colors.white54)),
                  SizedBox(height: screenHeight * 0.02,),
                  Text('Director', style: TextStyle(color: Colors.white, fontSize: 16),),
                  Divider(height: 10, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.03),
                  GestureDetector(
                    onLongPress: () {
                      _deleteDirector();
                    },
                    onTap: () async {
                      if(_directorNameController.text.isEmpty){
                        _editDirector();
                      }else{
                      final movieId = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DirectorScreen(personName: _directorNameController.text, personType: 'Director',),
                        ),
                      );
                      
                      if (movieId != null) {
                        //final movieDetails = await _tmdbService.getMovieDetails(movieId);
                        _fetchMovieDetails(movieId);
                        // Handle the movie details as needed
                      }
                      }
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: screenWidth * 0.1),
                            Text(
                              _directorNameController.text.isNotEmpty 
                                  ? _directorNameController.text 
                                  : 'No Director Selected',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: _editDirector,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Text('Actors', style: TextStyle(color: Colors.white, fontSize: 16),),
                  Divider(height: 10, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.03),
                  const SizedBox(height: 10),
                  _selectedActors.isNotEmpty
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _selectedActors.length == 1 ? 2 : _selectedActors.length >= 3 ? 3 : 2 ,
                            childAspectRatio: 2,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedActors.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                               _deleteActor(index);
                              },
                              onTap: () async {
                                final actorName = _selectedActors[index];
                                final movieId = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DirectorScreen(personName: actorName, personType: 'Actor'),
                                  ),
                                );
                                if (movieId != null) {
                                  _fetchMovieDetails(movieId);
                                }
                              },
                              child: Card(
                                color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      _selectedActors[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize: 
                                      _selectedActors.length < 3 ? screenWidth * 0.05 : screenWidth * 0.03, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Text('No actors selected', style: TextStyle(color: Colors.white54)),
                  SizedBox(height: screenWidth * 0.05),
                  Text('Writers', style: TextStyle(color: Colors.white, fontSize: 16),),
                  Divider(height: 10, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.03),
                  const SizedBox(height: 10),
                  _selectedWriters.isNotEmpty
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _selectedWriters.length >= 3 ? 3 : _selectedWriters.length,
                            childAspectRatio: _selectedWriters.length == 1 ? 5 : 2,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedWriters.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                               _deleteWriter(index);
                              },
                              onTap: () async {
                                final writerName = _selectedWriters[index];
                                final movieId = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DirectorScreen(personName: writerName, personType: 'Writer'),
                                  ),
                                );
                                if (movieId != null) {
                                  _fetchMovieDetails(movieId);
                                }
                              },
                              child: Card(
                                color:  const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      _selectedWriters[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize:
                                      _selectedWriters.length < 3 ? screenWidth * 0.05 : screenWidth * 0.03, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Text('No writers selected', style: TextStyle(color: Colors.white54)),
                  SizedBox(height: screenWidth * 0.05),
                  Text('Production Companies', style: TextStyle(color: Colors.white, fontSize: 16),),
                  Divider(height: 10, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.03),
                  const SizedBox(height: 10),
                  _selectedProductionCompanies.isNotEmpty
                      ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 6,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedProductionCompanies.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                               _deleteCompany(index);
                              },
                              onTap: () async {
                                final companyName = _selectedProductionCompanies[index];
                                final movieId = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CompanyScreen(companyName: companyName,),
                                  ),
                                );
                                if (movieId != null) {
                                  _fetchMovieDetails(movieId);
                                }
                              },
                              child: Card(
                                color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      _selectedProductionCompanies[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Text('No companies selected', style: TextStyle(color: Colors.white54)),
              ListTile(
                  title: Text(
                    'Çıkış Tarihi: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.white54,),
                      onTap: () => _selectDate(context),
                    ),
                  if(_budgetController.text.isNotEmpty && toDouble(_budgetController.text)! > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Budget: ${_formatCurrency(double.tryParse(_budgetController.text))}', style:  TextStyle(fontSize: screenWidth * 0.03, color: Colors.red)),
                      SizedBox(width: screenWidth * 0.1,),
                      Text('Revenue: ${_formatCurrency(double.tryParse(_revenueController.text))}', style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.red)),
                    ],
                  ),
                  if(_countryController.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenWidth * 0.05, screenWidth * 0.05, 0),
                    child: CountryFlag.fromCountryCode(_countryController.text.toUpperCase()),
                ),
              TextFormField(
                controller: _plotController,
                    decoration: const InputDecoration(labelText: 'Konu', labelStyle: TextStyle(color: Colors.white54)),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _runtimeController,
                    decoration: const InputDecoration(labelText: 'Süre (dakika)', labelStyle: TextStyle(color: Colors.white54)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = int.tryParse(value);
                    if (number == null) {
                      return 'Geçerli bir sayı girin';
                    }
                  }
                  return null;
                },
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _imdbRatingController,
                    decoration: const InputDecoration(labelText: 'IMDB Puanı', labelStyle: TextStyle(color: Colors.white54)),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = double.tryParse(value);
                    if (number == null || number < 0 || number > 10) {
                      return 'Geçerli bir puan girin (0-10)';
                    }
                  }
                  return null;
                },
              ),
              if (!widget.isFromWishlist) ...{
                ListTile(
                  title: Text(
                    'İzleme Tarihi: ${_watchedDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                      trailing: const Icon(Icons.calendar_today, color: Colors.white54),
                  onTap: () => _watchDate(context),
                    ),
                    Stack(
                      children: [
                        Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.3), // Siyah yarı saydam filtre
                            ),
                ),
                RatingBar.builder(
                      unratedColor: Colors.blueGrey.withOpacity(0.6),
                  itemSize: 30,
                  initialRating: _userScore,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 10,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 0.5),
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _userScore = rating;
                    });
                  },
                ),
                      ],
                    ),
                    
                  },
                  if (widget.isFromWishlist)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                      child: Stack(
                        children: [
                            Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.3), // Siyah yarı saydam filtre
                            ),
                          ),                 
                          RatingBar.builder(
                          unratedColor: Colors.blueGrey.withOpacity(0.6),
                          itemSize: 30,
                          initialRating: _hypeScore,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 0.5),
                          itemBuilder: (context, _) => const Icon(Icons.local_fire_department, color: Colors.red),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _hypeScore = rating;
                            });
                          },
                        ),
                        ],
                      ),
                    ),
                  SizedBox(height: 30),
                  if(_similarMovies.length > 3)
                  Card(color: Colors.transparent,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Similar Movies', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold),),
                      ),
                      GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Adjust the number of columns as needed
                        childAspectRatio: 0.42, // Adjust the aspect ratio as needed
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _similarMovies.length,
                      itemBuilder: (context, index) {
                        final similarMovie = _similarMovies[index];
                        return GestureDetector(
                          onTap: () {
                            if (similarMovie['id'] != null) {
                                  _fetchMovieDetails(similarMovie['id']);
                                  _scrollToTop();
                                }
                          },
                          child: Card(
                            color: const Color.fromARGB(255, 44, 50, 60),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0), // Sol üst köşe
                                topRight: Radius.circular(16.0), // Sağ üst köşe
                              ),
                            ),
                            child: Column(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [               
                                similarMovie['poster_path'] != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16.0), // Sol üst köşe
                                          topRight: Radius.circular(16.0), // Sağ üst köşe
                                        ),
                                      child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${similarMovie['poster_path']}',
                                          fit: BoxFit.cover,
                                          height: screenHeight * 0.22,
                                          width: screenWidth * 0.35,
                                        ),
                                    )
                                    : const Icon(Icons.movie, size: 100, color: Colors.white54),
                                SizedBox(height: screenHeight *0.01,),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                                  child: Text(
                                    similarMovie['title'] ?? 'No Title',
                                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.027, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                                    child: Column(
                                      children: [
                                        if(similarMovie['genre_ids'] != null && similarMovie['genre_ids'].any((id) => genreMap[id] != null))
                                        Text(
                                          '${similarMovie['genre_ids'].map((id) => genreMap[id]).take(3).join(', ')}',
                                          style:  TextStyle(color: Colors.white54, fontSize: screenWidth * 0.025),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: screenHeight * 0.001,),
                                        if (similarMovie['release_date'] != null)
                                        Text(
                                          '${similarMovie['release_date'].split('-')[0]}',
                                          style:  TextStyle(color: Colors.white54, fontSize: screenWidth * 0.025),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    ],
                  )),
              SizedBox(height: 30,),
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                      Icon(Icons.cloud_upload, size: 75, color: Colors.white54),
                                      Text('Film afişi seçmek için tıklayın', style: TextStyle(color: Colors.white54)),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveMovie,
                        icon: const Icon(Icons.save),
                        label: const Text('Güncelle', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          fixedSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _deleteMovie,
                        icon: const Icon(Icons.delete),
                        label: const Text('Sil', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _movieNameController.dispose();
    _directorNameController.dispose();
    _plotController.dispose();
    _runtimeController.dispose();
    _imdbRatingController.dispose();
    _writersController.dispose();
    _actorsController.dispose();
    _productionCompanyController.dispose();
    _countryController.dispose();
    _popularityController.dispose();
    _budgetController.dispose();
    _revenueController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 