import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'dart:async';
import '../models/movie_model.dart';
import '../services/supabase_service.dart';
import '../services/omdb_service.dart';
import '../services/tmdb_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:country_flags/country_flags.dart';
import 'company_screen.dart';
import 'director_screen.dart';
import 'genre_movies_screen.dart';
import '../sup/businessLogic.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hive/hive.dart';


class AddMovieScreen extends StatefulWidget {
  final bool isFromWishlist;
  final Movie? movie;
  final String? userEmail;
  final String? systemLanguage;

  const AddMovieScreen({super.key, required this.isFromWishlist, this.movie, this.userEmail, this.systemLanguage});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _movieNameController = TextEditingController();
  final _directorNameController = TextEditingController();
  final _plotController = TextEditingController();
  final _runtimeController = TextEditingController();
  final _imdbRatingController = TextEditingController();
  final _sortTitleController = TextEditingController();
  final _productionCompanyController = TextEditingController();
  final _countryController = TextEditingController();
  final _popularityController = TextEditingController();
  final _budgetController = TextEditingController();
  final _revenueController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _watchedDate = DateTime.now();
  double _userScore = 0.0;
  double _hypeScore = 0.0;
  int newId = -1;
  File? _selectedImage;
  bool _isUploading = false;
  String? _imageLink;
  final cloudinary = CloudinaryPublic('dper5kp88', 'YOUR_UPLOAD_PRESET', cache: false);
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  final _omdbService = OmdbService();
  final _tmdbService = TmdbService();
  List<String> _selectedGenres = [];
  List<String> _selectedActors = [];
  List<String> _selectedWriters = [];
  List<String> _selectedProductionCompanies = [];

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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (query.length >= 2) {
        setState(() {
          _isSearching = true;
        });
        try {
          //final results = await _omdbService.searchMovies(query);
          final results = await _tmdbService.searchMovies(query);
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        } catch (e) {
          setState(() {
            _isSearching = false;
          });
          if (mounted) {
            final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).unableUploadImages,
          message: '${S.of(context).unableFindMovie} ${S.of(context).checkInternet}', 
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
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _selectMovie(int movieId) async {
    try {
      //final movieDetails = await _omdbService.getMovieDetails(imdbId);
      final movieDetails = await _tmdbService.getMovieDetails(movieId);
      if (movieDetails != null) {
        setState(() {
          newId = movieDetails['id'] ?? -1;
          _movieNameController.text = movieDetails['title'] ?? '';
          _directorNameController.text = movieDetails['credits']['crew']
              .firstWhere((member) => member['job'] == 'Director', orElse: () => {'name': ''})['name'] ?? '';
          _plotController.text = movieDetails['overview'] ?? '';
          _runtimeController.text = movieDetails['runtime']?.toString() ?? '';
          _imdbRatingController.text = movieDetails['vote_average'].toString().length >= 3 ? 
            movieDetails['vote_average']?.toString().substring(0,3) ?? '' : 
            movieDetails['vote_average']?.toString() ?? '';
          if (movieDetails['release_date'] != null) {
            _selectedDate = DateTime.parse(movieDetails['release_date']);
          }
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
              ? List<String>.from(movieDetails['production_companies'].take(4).map((company) => company['name']))
              : [];
          _countryController.text = movieDetails['production_countries'] != null 
              ? movieDetails['production_countries'].take(1).map((country) => country['iso_3166_1']).join(', ') 
              : '';
          _popularityController.text = movieDetails['popularity']?.toString() ?? '';
          _budgetController.text = movieDetails['budget']?.toString() ?? '';
          _revenueController.text = movieDetails['revenue']?.toString() ?? '';
        });
        _searchController.clear();
        _searchResults = [];
      }
    } catch (e) {
      if (mounted) {
        final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).failure,
          message: '${S.of(context).unableGetMovieDetails} ${S.of(context).checkInternet}', 
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
  }

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Movie>('movies');
      // Eğer _selectMovie fonksiyonu kullanılmadıysa yeni bir ID oluştur
      if (newId == -1) {
      List<int> allIds = box.values.map((movie) => int.parse(movie.id.toString())).toList();
      if (allIds.isNotEmpty) {
         // En küçük ID'yi buluyoruz
         int minId = allIds.reduce((a, b) => a < b ? a : b);
     
         // Yeni id'yi en küçük id'den bir eksik yapıyoruz
         newId = minId - 1;
         if(newId > -1) { newId = -1;}
          }
        } 
       else {
        // Eğer _selectMovie kullanıldıysa, mevcut ID'yi al
      }
      print(newId);

      final movie = Movie(
        id: newId.toString(),
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
        watched: !widget.isFromWishlist,
        imageLink: _imageLink ?? '',
        userEmail: widget.userEmail ?? 'test@test.com', // Replace with actual user email if needed
        watchDate: widget.isFromWishlist ? null : _watchedDate,
        userScore: widget.isFromWishlist ? null : _userScore,
        hypeScore: widget.isFromWishlist ? _hypeScore : null,
        genres: _selectedGenres.isNotEmpty 
            ? _selectedGenres
            : null,
        productionCompany: _selectedProductionCompanies.isNotEmpty 
            ? _selectedProductionCompanies 
            : null,
        customSortTitle: _sortTitleController.text.isNotEmpty ? _sortTitleController.text : null,
        country: _countryController.text.isNotEmpty ? _countryController.text : null,
        popularity: _popularityController.text.isNotEmpty 
            ? double.tryParse(_popularityController.text) 
            : null,
        budget: _budgetController.text.isNotEmpty 
            ? double.tryParse(_budgetController.text) 
            : null,
        revenue: _revenueController.text.isNotEmpty 
            ? double.tryParse(_revenueController.text) 
            : null,
      );

      // Save to Hive
      await box.put(movie.id, movie);
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).succesful,
          message: S.of(context).movieAdded,
          contentType: ContentType.success, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
      Navigator.pop(context, true);
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
    setState(() {
      // Bu noktada `_directorNameController.text` güncellenmiş olur ve UI yeniden render edilir.
      //_directorNameController.text = input;
    });
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
      _selectedDate = widget.movie!.releaseDate;
      _imageLink = widget.movie!.imageLink;
      _sortTitleController.text = widget.movie!.customSortTitle ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      appBar: AppBar(
        title: Text(S.of(context).addNewMovie, style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showAddOptionsMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: S.of(context).searchMovies,
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54,),
                  suffixIcon: _isSearching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                            backgroundColor: Colors.black,
                          ),
                        )
                      : null,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
              ),
              if (_searchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: Card(
                    color: Color.fromARGB(255, 44, 50, 60),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = _searchResults[index];
                        return ListTile(
                          leading: movie['poster_path'] != null
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                  width: 50,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.movie, color: Colors.white54),
                                )
                              : const Icon(Icons.movie, color: Colors.white54),
                          title: Text(movie['title'], style: const TextStyle(color: Colors.white70)),
                          subtitle: Text(movie['release_date'] != null
                              ? movie['release_date'].split('-')[0]
                              : 'Unknown', style: const TextStyle(color: Colors.white54)),
                          onTap: () => _selectMovie(movie['id']),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _movieNameController,
                decoration:  InputDecoration(labelText: '${S.of(context).movieTitle} *', labelStyle: TextStyle(color: Colors.white54),),
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
                                builder: (context) => GenreMoviesScreen(genre: _selectedGenres[index]),
                              ),
                            );
                            if (movieId != null) {
                              _selectMovie(movieId);
                            }
                          },
                          child: Card(
                            color: const Color.fromARGB(255, 44, 50, 60),
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
                      builder: (context) => DirectorScreen(personName: _directorNameController.text, personType: 'Director', systemLanguage: widget.systemLanguage,),
                    ),
                  );

                  if (movieId != null) {
                    //final movieDetails = await _tmdbService.getMovieDetails(movieId);
                    _selectMovie(movieId);
                    // Handle the movie details as needed
                  }
                  }
                },
                child: Card(
                  color: const Color.fromARGB(255, 44, 50, 60),
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
                                builder: (context) => DirectorScreen(personName: actorName, personType: 'Actor', systemLanguage: widget.systemLanguage,),
                              ),
                            );
                            if (movieId != null) {
                              _selectMovie(movieId);
                            }
                          },
                          child: Card(
                            color: const Color.fromARGB(255, 44, 50, 60),
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
                                builder: (context) => DirectorScreen(personName: writerName, personType: 'Writer', systemLanguage: widget.systemLanguage,),
                              ),
                            );
                            if (movieId != null) {
                              _selectMovie(movieId);
                            }
                          },
                          child: Card(
                            color: const Color.fromARGB(255, 44, 50, 60),
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
                        childAspectRatio: 7,
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
                              _selectMovie(movieId);
                            }
                          },
                          child: Card(
                            color: const Color.fromARGB(255, 44, 50, 60),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  _selectedProductionCompanies[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: screenWidth* 0.045, fontWeight: FontWeight.bold),
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
                decoration: InputDecoration(labelText: S.of(context).imdbScore, labelStyle: TextStyle(color: Colors.white54),),
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
              /*TextFormField(
                controller: _popularityController,
                decoration: const InputDecoration(labelText: 'Popularity', labelStyle: TextStyle(color: Colors.white54)),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),*/
              SizedBox(height: 10,),
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
                RatingBar.builder(
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
              
              },
              if (widget.isFromWishlist)
              RatingBar.builder(
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
                                  Icon(Icons.cloud_upload, size: 75, color: Colors.white54,),
                                  Text(S.of(context).pressChoosePoster, style: TextStyle(color: Colors.white54),),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveMovie,
                child: Text(S.of(context).addMovie, style: TextStyle(fontSize: 18),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _movieNameController.dispose();
    _sortTitleController.dispose();
    _directorNameController.dispose();
    _plotController.dispose();
    _runtimeController.dispose();
    _imdbRatingController.dispose();
    _productionCompanyController.dispose();
    _countryController.dispose();
    _popularityController.dispose();
    _budgetController.dispose();
    _revenueController.dispose();
    super.dispose();
  }
} 