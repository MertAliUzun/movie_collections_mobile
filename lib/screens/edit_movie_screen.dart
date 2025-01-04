import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'dart:async';
import '../models/movie_model.dart';
import '../services/supabase_service.dart';
import '../services/tmdb_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:country_flags/country_flags.dart';
import 'director_screen.dart';

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

  void _deleteMovie() async {
    final supabase = Supabase.instance.client;
    final service = SupabaseService(supabase);
    try {
      await service.deleteMovie(widget.movie!.movieName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Film başarıyla silindi')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silme hatası: $e')),
        );
      }
    }
  }

  void _toggleWatchedStatus() async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:  Color.fromARGB(255, 44, 50, 60),
          content: Text(textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white), widget.isFromWishlist ? 'Filmi koleksiyona taşımak istiyor musunuz?' : 'Filmi izlenme listesine taşımak istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirmed
              child: Text('Evet', style: TextStyle(fontSize: screenWidth * 0.038,color: Colors.white,)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User declined
              child: Text('Hayır', style: TextStyle(fontSize: screenWidth * 0.038, color: Colors.white,)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final supabase = Supabase.instance.client;
      final service = SupabaseService(supabase);
      try {
        final updatedMovie = widget.movie!;
        updatedMovie.watched = widget.isFromWishlist ? true : false;
        if (widget.isFromWishlist) {
          updatedMovie.hypeScore = 0.0;
        } else {
          updatedMovie.userScore = 0.0;
          updatedMovie.watchDate = DateTime.now();
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
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0), // Adjust position as needed
      items: [
        PopupMenuItem<String>(
          value: 'add_genre',
          child: const Text('Add Genre'),
        ),
        PopupMenuItem<String>(
          value: 'add_actor',
          child: const Text('Add Actor'),
        ),
        PopupMenuItem<String>(
          value: 'add_writer',
          child: const Text('Add Writer'),
        ),
        PopupMenuItem<String>(
          value: 'add_producer',
          child: const Text('Add Production Company'),
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
          title: Text(title),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(hintText: 'Enter name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(input);
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String input = _directorNameController.text; // Pre-fill with current director name
        return AlertDialog(
          title: const Text('Edit Director'),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(hintText: 'Enter director name'),
            controller: TextEditingController(text: input), // Set initial text
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _directorNameController.text = input; // Update the director name
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDirector() {
    // Logic to delete the director
    setState(() {
      _directorNameController.clear(); // Clear the director name
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
    }
  }

  Future<void> _fetchMovieDetails(int movieId) async {
    final tmdbService = TmdbService();
    final movieDetails = await tmdbService.getMovieDetails(movieId);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                        return Card(
                          color: const Color.fromARGB(255, 44, 50, 60),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                _selectedGenres[index],
                                style: TextStyle(color: Colors.white, 
                                fontSize: _selectedGenres.length <= 2 ? screenWidth * 0.07 : 
                                _selectedGenres.length == 3 ? screenWidth * 0.04 : screenWidth * 0.03, fontWeight: FontWeight.bold),
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
                onTap: () async {
                  if(_directorNameController.text.isEmpty){
                    _editDirector();
                  }else{
                  final movieId = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DirectorScreen(directorName: _directorNameController.text),
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
                  color: const Color.fromARGB(255, 44, 50, 60),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        return Card(
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
                        return Card(
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
                        childAspectRatio: 7,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedProductionCompanies.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: const Color.fromARGB(255, 44, 50, 60),
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
                  onTap: () => _watchDate(context),
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
              SizedBox(height: 30),
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
    super.dispose();
  }
} 