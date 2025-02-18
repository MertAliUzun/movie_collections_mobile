import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:movie_collections_mobile/widgets/person_movies_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'dart:async';
import '../sup/businessLogic.dart';
import '../sup/genreMap.dart';
import '../models/movie_model.dart';
import '../services/supabase_service.dart';
import '../services/tmdb_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:country_flags/country_flags.dart';
import 'add_movie_screen.dart';
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
  final String? userEmail;
  final String? systemLanguage;

  const EditMovieScreen({super.key, required this.isFromWishlist, this.movie, required this.userEmail, this.systemLanguage});

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
        final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).failure,
          message: S.of(context).unableUploadImages,
          contentType: ContentType.failure, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
      }
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Movie>('movies');

      // Film nesnesini oluştur
      final movie = Movie(
        id: widget.movie!.id, // Mevcut ID'yi kullan
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

      // Hive'da güncelle
      box.put(movie.id, movie);

      // Kullanıcıya bildirim göster
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).succesful,
          message: S.of(context).movieUpdated,
          contentType: ContentType.success, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);

      // Geri dön
      Navigator.pop(context);
    }
  }

  void _deleteMovie() {
    final box = Hive.box<Movie>('movies');
    
    // Film ID'sini al
    String movieId = widget.movie!.id!;

    // Hive'dan sil
    box.delete(movieId);

    // Kullanıcıya bildirim göster
    final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title:  S.of(context).succesful,
          message:  S.of(context).movieDeleted,
          contentType: ContentType.success, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);

    // Geri dön
    Navigator.pop(context);
  }

  void _toggleWatchedStatus() async {
    await toggleWatchedStatus(context, widget.movie!, widget.isFromWishlist, true);
  }

  String _getGenreLocalizedString(String genre) {
    return getGenreLocalizedString(genre, context);
  }

  void _showAddOptionsMenu(BuildContext context) {
    showMenu(
      color: const Color.fromARGB(255, 44, 50, 60),
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0), // Adjust position as needed
      items: [
        PopupMenuItem<String>(
          value: 'add_genre',
          child: Text(S.of(context).addGenre, style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_actor',
          child: Text(S.of(context).addActor, style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_writer',
          child: Text(S.of(context).addWriter, style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_producer',
          child: Text(S.of(context).addProductionCompany, style: TextStyle(color: Colors.white)),
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
            decoration: InputDecoration(hintText: S.of(context).pleaseEnter, hintStyle: TextStyle(color: Colors.white)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel, style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(input);
              },
              child: Text(S.of(context).add, style: TextStyle(color: Colors.white)),
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
    final confirm = await deleteDetailsConfirm(context, S.of(context).director,);
    
    if (confirm) {
      setState(() {
        _directorNameController.clear(); // Clear the director name
      });
    }
  }
  void _deleteGenre(int index) {
    deleteDetails(context, S.of(context).genre, index: index, selected: _selectedGenres, onDelete: () {
      setState(() {
        // This will trigger a rebuild of the widget tree
      });
    });
  }
  void _deleteActor(int index) {
    deleteDetails(context, S.of(context).actor, index: index, selected: _selectedActors, onDelete: () {
      setState(() {
        // This will trigger a rebuild of the widget tree
      });
    });
  }
  void _deleteWriter(int index) {
    deleteDetails(context, S.of(context).writer, index: index, selected: _selectedWriters, onDelete: () {
      setState(() {
        // This will trigger a rebuild of the widget tree
      });
    });
  }
  void _deleteCompany(int index) {
    deleteDetails(context, S.of(context).company, index: index, selected: _selectedProductionCompanies, onDelete: () {
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
      print(widget.movie!.id);
    }
  }

  Future<void> _fetchSimilarMovies() async {
    if(int.parse(widget.movie!.id) < 0) {return;}
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
        final similarMovies = await tmdbService.getSimilarMovies(movieId);
        if(similarMovies != null) {
      setState(() {
        _similarMovies = similarMovies.where((movie) => movie['original_language'] == 'en')
          .where((movie) => movie['poster_path'] != null)
          .take(6) // İlk 6 filmi al
          .map((movie) => Map<String, dynamic>.from(movie)) // Filmleri Map formatında döndür
          .toList();
      });
    }
      }
    } catch (e) {
      // Kullanıcıya bildirim göster
    final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title:  S.of(context).failure,
          message: '${S.of(context).errorFetchingSimilar} $e',
          contentType: ContentType.failure, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
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
        title: Text(S.of(context).movieDetails, style: TextStyle(color: Colors.white)),
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
               errorBuilder: (context, error, stackTrace) =>
               Image.asset(
                'assets/images/placeholder_poster.png',
                fit: BoxFit.cover,
               ),
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
                    decoration: InputDecoration(labelText: '${S.of(context).movieTitle} *', labelStyle: TextStyle(color: Colors.white54)),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).pleaseEnterMovieTitle;
                  }
                  return null;
                },
              ),
              TextFormField(
                    controller: _sortTitleController,
                    decoration: InputDecoration(labelText: S.of(context).customSortTitle, labelStyle: TextStyle(color: Colors.white54),),
                style: const TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: screenWidth * 0.1),
                  Text(S.of(context).genres, style: TextStyle(color: Colors.white, fontSize: 16),),
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
                                    builder: (context) => GenreMoviesScreen(genre: _selectedGenres[index], isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,),
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
                                      _selectedGenres[index] == 'Action' ? S.of(context).action : 
                                      _selectedGenres[index] == 'Adventure' ? S.of(context).adventure :
                                      _selectedGenres[index] == 'Animation' ? S.of(context).animation :
                                      _selectedGenres[index] == 'Comedy' ? S.of(context).comedy :
                                      _selectedGenres[index] == 'Crime' ? S.of(context).crime :
                                      _selectedGenres[index] == 'Documentary' ? S.of(context).documentary :
                                      _selectedGenres[index] == 'Drama' ? S.of(context).drama :
                                      _selectedGenres[index] == 'Family' ? S.of(context).family :
                                      _selectedGenres[index] == 'Fantasy' ? S.of(context).fantasy :
                                      _selectedGenres[index] == 'History' ? S.of(context).history :
                                      _selectedGenres[index] == 'Horror' ? S.of(context).horror :
                                      _selectedGenres[index] == 'Music' ? S.of(context).music :
                                      _selectedGenres[index] == 'Mystery' ? S.of(context).mystery :
                                      _selectedGenres[index] == 'Romance' ? S.of(context).romance :
                                      _selectedGenres[index] == 'Science Fiction' ? S.of(context).scienceFiction :
                                      _selectedGenres[index] == 'TV Movie' ? S.of(context).tvMovie :
                                      _selectedGenres[index] == 'Thriller' ? S.of(context).thriller :
                                      _selectedGenres[index] == 'War' ? S.of(context).war :
                                      _selectedGenres[index] == 'Western' ? S.of(context).western : _selectedGenres[index],
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
                      : Text(S.of(context).noGenresSelected, style: TextStyle(color: Colors.white54)),
                  SizedBox(height: screenHeight * 0.02,),
                  Text(S.of(context).director, style: TextStyle(color: Colors.white, fontSize: 16),),
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
                          builder: (context) => DirectorScreen(personName: _directorNameController.text, personType: 'Director', systemLanguage: widget.systemLanguage, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,),
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
                                  : S.of(context).directorNull,
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
                  Text(S.of(context).actors, style: TextStyle(color: Colors.white, fontSize: 16),),
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
                                    builder: (context) => DirectorScreen(personName: actorName, personType: 'Actor', systemLanguage: widget.systemLanguage, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,),
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
                      : Text(S.of(context).noActorsSelected, style: TextStyle(color: Colors.white54)),
                  SizedBox(height: screenWidth * 0.05),
                  Text(S.of(context).writers, style: TextStyle(color: Colors.white, fontSize: 16),),
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
                                    builder: (context) => DirectorScreen(personName: writerName, personType: 'Writer', systemLanguage: widget.systemLanguage, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,),
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
                      : Text(S.of(context).noWritersSelected, style: TextStyle(color: Colors.white54)),
                  SizedBox(height: screenWidth * 0.05),
                  Text(S.of(context).productionCompanies, style: TextStyle(color: Colors.white, fontSize: 16),),
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
                                    builder: (context) => CompanyScreen(companyName: companyName, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,),
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
                      : Text(S.of(context).noCompaniesSelected, style: TextStyle(color: Colors.white54)),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenHeight * 0.02), // Padding for better spacing
                  tileColor: Colors.transparent, // Optional: make the background transparent
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Space between the text and icon
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${S.of(context).releaseDateColon} ', 
                              style: TextStyle(
                                color: Colors.white70, 
                                fontWeight: FontWeight.normal, 
                                fontSize: screenHeight * 0.015,
                              ),
                            ),
                            TextSpan(
                              text: DateFormat('dd MMMM yyyy').format(_selectedDate.toLocal()),
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: screenHeight * 0.025,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
                        child: const Icon(
                          Icons.edit_calendar,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _selectDate(context),
                ),
                  if(_budgetController.text.isNotEmpty && toDouble(_budgetController.text)! > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text('${S.of(context).budgetColon} ${_formatCurrency(double.tryParse(_budgetController.text))}', style:  TextStyle(fontSize: screenWidth * 0.03, color: Colors.red)),
                  SizedBox(width: screenWidth * 0.1,),
                  Text('${S.of(context).revenueColon} ${_formatCurrency(double.tryParse(_revenueController.text))}', style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.red)),
                ],
                  ),
                  if(_countryController.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenWidth * 0.05, screenWidth * 0.05, 0),
                    child: CountryFlag.fromCountryCode(_countryController.text.toUpperCase()),
                ),
              TextFormField(
                controller: _plotController,
                decoration: InputDecoration(labelText: S.of(context).plot, labelStyle: TextStyle(color: Colors.white54),),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _runtimeController,
                decoration: InputDecoration(labelText: S.of(context).runtimeMinutes, labelStyle: TextStyle(color: Colors.white54),),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = int.tryParse(value);
                    if (number == null) {
                      return S.of(context).enterValidNumber;
                    }
                  }
                  return null;
                },
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _imdbRatingController,
                    decoration: InputDecoration(labelText: S.of(context).imdbScore, labelStyle: TextStyle(color: Colors.white54)),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = double.tryParse(value);
                    if (number == null || number < 0 || number > 10) {
                      return S.of(context).enterValidScore;
                    }
                  }
                  return null;
                },
              ),
              if (!widget.isFromWishlist) ...{
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenHeight * 0.02), // Padding for better spacing
                  tileColor: Colors.transparent, // Optional: make the background transparent
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Space between the text and icon
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${S.of(context).watchDateColon} ', 
                              style: TextStyle(
                                color: Colors.white70, 
                                fontWeight: FontWeight.normal, 
                                fontSize: screenHeight * 0.015,
                              ),
                            ),
                            TextSpan(
                              text: DateFormat('dd MMMM yyyy').format(_watchedDate.toLocal()),
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: screenHeight * 0.025,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
                        child: const Icon(
                          Icons.edit_calendar,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
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
                        child: Text(S.of(context).similarMovies, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold),),
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
                          onTap: () async {
                            if (similarMovie['id'] != null) {
                              final movieDetails = await TmdbService().getMovieDetails(similarMovie['id']);
                              
                              if (movieDetails != null) {
                                // Movie nesnesini oluştur
                                final chosenMovie = Movie(
                                  id: movieDetails['id'].toString(),
                                  movieName: movieDetails['title'] ?? '',
                                  directorName: movieDetails['credits']['crew']
                                      ?.firstWhere((crew) => crew['job'] == 'Director', orElse: () => {'name': ''})['name'] ?? '',
                                  releaseDate: movieDetails['release_date'] != null 
                                      ? DateTime.parse(movieDetails['release_date']) 
                                      : DateTime.now(),
                                  plot: movieDetails['overview'],
                                  runtime: movieDetails['runtime'],
                                  imdbRating: movieDetails['vote_average']?.toDouble(),
                                  writers: movieDetails['credits']['crew']
                                      ?.where((member) => member['department'] == 'Writing')
                                      .take(3)
                                      .map<String>((writer) => writer['name'] as String)
                                      .toList(),
                                  actors: movieDetails['credits']['cast']
                                      ?.take(6)
                                      .map<String>((actor) => actor['name'] as String)
                                      .toList(),
                                  imageLink: movieDetails['poster_path'] != null 
                                      ? 'https://image.tmdb.org/t/p/w500${movieDetails['poster_path']}'
                                      : '',
                                  genres: movieDetails['genres']
                                      ?.take(4)
                                      .map<String>((genre) => genre['name'] as String)
                                      .toList(),
                                  productionCompany: movieDetails['production_companies']
                                      ?.take(2)
                                      .map<String>((company) => company['name'] as String)
                                      .toList(),
                                  country: movieDetails['production_countries']?.isNotEmpty 
                                      ? movieDetails['production_countries'][0]['iso_3166_1']
                                      : null,
                                  popularity: movieDetails['popularity']?.toDouble(),
                                  budget: movieDetails['budget']?.toDouble(),
                                  revenue: movieDetails['revenue']?.toDouble(),
                                  watched: !widget.isFromWishlist,
                                  userEmail: widget.userEmail ?? 'test@test.com'
                                );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddMovieScreen(
                                        isFromWishlist: widget.isFromWishlist,
                                        movie: chosenMovie,
                                      ),
                                    ),
                                  );
                                  /*_fetchMovieDetails(similarMovie['id']);
                                  _scrollToTop();*/
                                }
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
                                    similarMovie['title'] ?? S.of(context).noTitle,
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
                                          '${similarMovie['genre_ids'].map((id) => 
                                          _getGenreLocalizedString(genreMap[id] ?? 'Action')
                                          ).take(3).join(', ')}',
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
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                      Icon(Icons.cloud_upload, size: 75, color: Colors.white54),
                                      Text(S.of(context).pressChoosePoster, style: TextStyle(color: Colors.white54)),
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
                        label: Text(S.of(context).update, style: TextStyle(fontSize: 18)),
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
                        label: Text(S.of(context).delete, style: TextStyle(fontSize: 18)),
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