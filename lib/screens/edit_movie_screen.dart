import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:movie_collections_mobile/widgets/provider_card_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'dart:async';
import '../sup/businessLogic.dart';
import '../sup/genreMap.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:country_flags/country_flags.dart';
import 'add_movie_screen.dart';
import 'director_screen.dart';
import 'genre_movies_screen.dart';
import 'company_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../sup/screen_util.dart';
import 'tag_movies_screen.dart';

class EditMovieScreen extends StatefulWidget {
  final bool isFromWishlist;
  final Movie? movie;
  final String? userEmail;
  final String systemLanguage;

  const EditMovieScreen({super.key, required this.isFromWishlist, this.movie, required this.userEmail, required this.systemLanguage});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _movieNameController = TextEditingController();
  final _directorNameController = TextEditingController();
  final _plotController = TextEditingController();
  final _notesController = TextEditingController();
  final _runtimeController = TextEditingController();
  final _watchCountController = TextEditingController();
  final _imdbRatingController = TextEditingController();
  final _writersController = TextEditingController();
  final _actorsController = TextEditingController();
  final _productionCompanyController = TextEditingController();
  final _franchisesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _countryController = TextEditingController();
  final _popularityController = TextEditingController();
  final _budgetController = TextEditingController();
  final _revenueController = TextEditingController();
  final _sortTitleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime? _watchedDate;
  bool _isHidden = false;
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
  List<String> _selectedFranchises = [];
  List<String> _selectedTags = [];
  List<Map<String, dynamic>> _similarMovies = [];
  List<Map<String, dynamic>> _seriesMovies = [];
  String? _pgRating;
  final ScrollController _scrollController = ScrollController();
  String _selectedCollectionType = ''; // Varsayılan 
  bool? _afterCreditsExists;
  String? _basedOn;
  Map<String, List<dynamic>> _providers = {
    'flatrate': [],
    'rent': [],
    'buy': [],
  };
  final AdService _adService = AdService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(255, 20, 30, 40),
              onPrimary: Colors.white,
              surface: Color.fromARGB(255, 44, 50, 60),
              onSurface: Colors.white, 
            ),
            dialogBackgroundColor: const Color.fromARGB(255, 34, 40, 50),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(255, 20, 30, 40),
              onPrimary: Colors.white,
              surface: Color.fromARGB(255, 44, 50, 60),
              onSurface: Colors.white, 
            ),
            dialogBackgroundColor: const Color.fromARGB(255, 34, 40, 50),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _watchedDate) {
      setState(() {
        _watchedDate = picked;
      });
    }
  }

  /*
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
  */

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
        myNotes: _notesController.text.isNotEmpty ? _notesController.text : null,
        runtime: _runtimeController.text.isNotEmpty 
            ? int.tryParse(_runtimeController.text) 
            : null,
        watchCount: _watchCountController.text.isNotEmpty 
            ? int.tryParse(_watchCountController.text) 
            : null,
        imdbRating: _imdbRatingController.text.isNotEmpty
            ? _imdbRatingController.text.length >= 3 ? double.tryParse(_imdbRatingController.text.substring(0, 3))
            : double.tryParse(_imdbRatingController.text)
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
        hidden: widget.movie!.hidden ?? false,
        imageLink: _imageLink ?? '',
        userEmail: 'test@test.com',
        genres: _selectedGenres,
        productionCompany: _selectedProductionCompanies,
        customSortTitle: _sortTitleController.text.isNotEmpty ? _sortTitleController.text : null,
        collectionType: _selectedCollectionType,
        creationDate: widget.movie!.creationDate ?? DateTime.now(),
        pgRating: _pgRating != null && _pgRating!.isNotEmpty ? _pgRating : null,
        franchises: _selectedFranchises.isNotEmpty 
            ? _selectedFranchises 
            : null,
        tags: _selectedTags.isNotEmpty 
            ? _selectedTags
            : null,
      );
      

      // Hive'da güncelle
      box.put(movie.id, movie);

      _adService.showInterstitialAd();

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

    _adService.showInterstitialAd();

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
    // Önce rewarded reklamı göster
      // Reklam başarıyla gösterildiyse (ve kullanıcı izlediyse) durumu değiştir
      await toggleWatchedStatus(context, widget.movie!, widget.isFromWishlist, true);
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
  }

  String _getGenreLocalizedString(String genre) {
    return getGenreLocalizedString(genre, context);
  }

  void _showAddOptionsMenu(BuildContext context) {
    showMenu(
      color: const Color.fromARGB(255, 44, 50, 60),
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0), // Adjust position as needed
      items: [
        PopupMenuItem<String>(
          value: 'add_genre',
          child: Text(S.of(context).addGenre, style: const TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_actor',
          child: Text(S.of(context).addActor, style: const TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_writer',
          child: Text(S.of(context).addWriter, style: const TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_producer',
          child: Text(S.of(context).addProductionCompany, style: const TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_franchise',
          child: Text(S.of(context).addFranchise, style: const TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'add_tags',
          child: Text(S.of(context).addTag, style: const TextStyle(color: Colors.white)),
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
          case 'add_franchise':
            _addDetails('Add Franchise', (franchise) {
              setState(() {
                _selectedFranchises.add(franchise);
              });
            });
            break;
          case 'add_tag':
            _addDetails('Add Tag', (tag) {
              setState(() {
                _selectedTags.add(tag);
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
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              input = value;
            },
            decoration: InputDecoration(hintText: S.of(context).pleaseEnter, hintStyle: const TextStyle(color: Colors.white)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel, style: const TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(input);
              },
              child: Text(S.of(context).add, style: const TextStyle(color: Colors.white)),
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
  void _deleteFranchise(int index) {
    deleteDetails(context, S.of(context).franchise, index: index, selected: _selectedFranchises, onDelete: () {
      setState(() {
        // This will trigger a rebuild of the widget tree
      });
    });
  }
  void _deleteTag(int index) {
    deleteDetails(context, S.of(context).tag, index: index, selected: _selectedTags, onDelete: () {
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

  // Runtime'ı saat ve dakika formatına çeviren yardımcı fonksiyon
  String _formatRuntime(String? minutes) {
    if (minutes == null || minutes.isEmpty) {
      //return S.of(context).runtimeNull;
      return 'null';
    }
    
    int? totalMinutes = int.tryParse(minutes);
    if (totalMinutes == null) {
      //return S.of(context).runtimeNull;
      return 'null';
    }

    int hours = totalMinutes ~/ 60;
    int remainingMinutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  // Runtime düzenleme dialog'unu gösteren fonksiyon
  Future<void> _editRuntime() async {
    String? newRuntime = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String tempRuntime = _runtimeController.text;
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 44, 50, 60),
          title: Text(
            S.of(context).runtimeMinutes,
              style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
            ),
          ),
          content: TextField(
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              //hintText: S.of(context).enterMinutes,
              hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: ScreenUtil.getAdaptiveTextSize(context, 14),
              ),
            ),
            onChanged: (value) {
              tempRuntime = value;
            },
            controller: TextEditingController(text: _runtimeController.text),
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
              onPressed: () => Navigator.pop(context, tempRuntime),
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil.getAdaptiveTextSize(context, 16),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (newRuntime != null) {
      setState(() {
        _runtimeController.text = newRuntime;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _movieNameController.text = widget.movie!.movieName;
      _directorNameController.text = widget.movie!.directorName;
      _plotController.text = widget.movie!.plot ?? '';
      _notesController.text = widget.movie!.myNotes ?? '';
      _selectedCollectionType = widget.movie!.collectionType ?? 'DVD';
      _runtimeController.text = widget.movie!.runtime?.toString() ?? '';
      _imdbRatingController.text = widget.movie!.imdbRating != null 
        ? widget.movie!.imdbRating!.toString().length > 3
            ? widget.movie!.imdbRating!.toString().substring(0, 3)
            : widget.movie!.imdbRating!.toString()
        : '';
      _watchCountController.text = widget.movie!.watchCount?.toString() ?? '';
      _writersController.text = widget.movie!.writers?.join(', ') ?? '';
      _actorsController.text = widget.movie!.actors?.join(', ') ?? '';
      _franchisesController.text = widget.movie!.franchises?.join(', ') ?? '';
      _tagsController.text = widget.movie!.tags?.join(', ') ?? '';
      _productionCompanyController.text = widget.movie!.productionCompany?.join(', ') ?? '';
      _countryController.text = widget.movie!.country ?? '';
      _popularityController.text = widget.movie!.popularity?.toString() ?? '';
      _budgetController.text = widget.movie!.budget?.toString() ?? '';
      _revenueController.text = widget.movie!.revenue?.toString() ?? '';
      _selectedDate = widget.movie!.releaseDate;
      _watchedDate = widget.movie!.watchDate ?? DateTime.now();
      _isHidden = widget.movie!.hidden ?? false;
      _imageLink = widget.movie!.imageLink;
      _userScore = widget.movie!.userScore ?? 0;
      _hypeScore = widget.movie!.hypeScore ?? 0;
      _selectedGenres = widget.movie!.genres ?? [];
      _selectedActors = widget.movie!.actors ?? [];
      _selectedWriters = widget.movie!.writers ?? [];
      _selectedProductionCompanies = widget.movie!.productionCompany ?? [];
      _selectedFranchises = widget.movie!.franchises ?? [];
      _selectedTags = widget.movie!.tags ?? [];
      _sortTitleController.text = widget.movie!.customSortTitle ?? '';
      _pgRating = widget.movie!.pgRating ?? '';
      _fetchSimilarMovies();
      _fetchCollectionMovies();
      _fetchMovieKeywords();
      //_fetchPgRating();
      
      //_fetchProviders();
      Future.microtask(() => _fetchProviders());    
    }
    
    // Reklamları yükle
    _adService.loadBannerAd(
      onAdLoaded: (ad) {
        setState(() {}); // UI'ı güncelle
      },
    );
    _adService.loadInterstitialAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showInterstitialAd();
        });
      }
    );
  }

  Future<void> _fetchProviders() async{
    if(int.parse(widget.movie!.id) < 0) {return;}
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Skip fetching similar movies if there's no internet
      return;
    }
    final tmdbService = TmdbService();
    final providers = await tmdbService.getProviders(int.parse(widget.movie!.id));
      if (providers != null) {
        setState(() {
          _providers = {
            'flatrate': List<dynamic>.from(providers['flatrate'] ?? []),
            'rent': List<dynamic>.from(providers['rent'] ?? []),
            'buy': List<dynamic>.from(providers['buy'] ?? []),
          };
        });
      }
  }
  Future<void> _fetchPgRating() async { 
    if (int.parse(widget.movie!.id) < 0 || _pgRating!.isNotEmpty) { return; }
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Skip fetching similar movies if there's no internet
      return;
    }
    final tmdbService = TmdbService();
    final movieDetails = await tmdbService.searchMovies(widget.movie!.movieName);

    if (movieDetails.isNotEmpty) { 
      final movieId = movieDetails[0]['id'];
      final pgRating = await tmdbService.getPgRating(movieId);

      if (mounted) {
          setState(() {
          _pgRating = pgRating.where((rating) => rating['iso_3166_1'] == 'US')
          .map((rating) => rating['release_dates']?.first['certification'])
          .toString();
          });
        //print('xxxxxx'+_pgRating!);
        }
    }
  }

  Future<void> _fetchMovieKeywords() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
   if (connectivityResult[0] == ConnectivityResult.none) {
     // Skip fetching similar movies if there's no internet
     return;
   }
   try {
     final tmdbService = TmdbService();
     final movie = await tmdbService.searchMovies(widget.movie!.movieName);

     if(movie.isNotEmpty) {
        final keywords = await tmdbService.getMovieKeywords(movie[0]['id']);
        final List<int> keywordIds = keywords.map<int>((k) => k['id'] as int).toList();

        bool afterCredits = keywordIds.contains(179430) || keywordIds.contains(179431);
        String basedOn = 'Original';   
        if (keywordIds.contains(9717)) {
          basedOn = 'Comic';
        } else if (keywordIds.contains(818) || keywordIds.contains(15101)) {
          basedOn = 'Book';
        } else if (keywordIds.contains(13141)) {
          basedOn = 'Manga';
        } else if (keywordIds.contains(348023)) {
          basedOn = 'Documentary';
        } else if (keywordIds.contains(222243)) {
          basedOn = 'Anime';
        } else if (keywordIds.contains(10244)) {
          basedOn = 'Cartoon';
        } else if (keywordIds.contains(10542)) {
          basedOn = 'Toy';
        } else if (keywordIds.contains(290667)) {
          basedOn = 'Manhua';
        } else if (keywordIds.contains(323477)) { 
          basedOn = 'Manhwa';
        } else if (keywordIds.contains(14641)) {
          basedOn = 'Autobiography';
        }
      setState(() {
        _afterCreditsExists = afterCredits;
        _basedOn = basedOn;
      });
     }

   } catch (e) {
     
   }
  }
  
  Future<void> _fetchCollectionMovies() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
   if (connectivityResult[0] == ConnectivityResult.none) {
     // Skip fetching similar movies if there's no internet
     return;
   }
   try {
     final tmdbService = TmdbService();
     final movie = await tmdbService.searchMovies(widget.movie!.movieName);

     if (movie.isNotEmpty) {
      final movieDetails = await tmdbService.getMovieDetails(movie[0]['id']);
      if(movieDetails !=null || movieDetails!.isNotEmpty || movieDetails['belongs_to_collection']['id'].isNotEmpty) {
        final collectionId = movieDetails['belongs_to_collection']['id'];

      final collectionMovies = await tmdbService.getCollectionMovies(collectionId);

      if (collectionMovies != null) {
         if (mounted) {
           setState(() {
             _seriesMovies = collectionMovies.where((movie) => movie['original_language'] == 'en')
               .where((movie) => movie['poster_path'] != null)
               .take(6) // İlk 6 filmi al
               .map((movie) => Map<String, dynamic>.from(movie)) // Filmleri Map formatında döndür
               .toList();
           });
         }
       }
      }
     }
   } catch (e) {
     
   }
  }
  Future<void> _fetchSimilarMovies() async {
   if (int.parse(widget.movie!.id) < 0) { return; } //CHANGE This shouldn't matter. We search movie with title then get the id.
   
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
       
       if (similarMovies != null) {
         if (mounted) {
           setState(() {
             _similarMovies = similarMovies.where((movie) => movie['original_language'] == 'en')
               .where((movie) => movie['poster_path'] != null)
               .take(6) // İlk 6 filmi al
               .map((movie) => Map<String, dynamic>.from(movie)) // Filmleri Map formatında döndür
               .toList();
           });
         }
       }
     }
   } catch (e) {
     // Kullanıcıya bildirim göster
     if (mounted) {
       final snackBar = SnackBar(
         elevation: 0,
         backgroundColor: Colors.transparent,
         behavior: SnackBarBehavior.floating,
         content: AwesomeSnackbarContent(
           title: S.of(context).failure,
           message: S.of(context).errorFetchingSimilar,
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

  Future<void> _fetchMovieDetails(int movieId) async {
    try {
      final tmdbService = TmdbService();
      final movieDetails = await tmdbService.getMovieDetails(movieId);
      final movieDetailsLanguage = await TmdbService().getMovieDetails(movieId, languageCode: widget.systemLanguage);
      
      if (movieDetails != null) {
        setState(() {
          _movieNameController.text = movieDetails['title'] ?? '';
          _directorNameController.text = movieDetails['credits']['crew']
              .firstWhere((crew) => crew['job'] == 'Director', orElse: () => {'name': ''})['name'] ?? '';
          _plotController.text = movieDetailsLanguage!['overview'] ?? movieDetails['overview'] ?? '';
          _runtimeController.text = movieDetails['runtime']?.toString() ?? '';
          _imdbRatingController.text = movieDetails['vote_average'].toString().length >= 3 ? 
              movieDetails['vote_average']?.toString().substring(0,3) ?? '' : 
              movieDetails['vote_average']?.toString() ?? '';
          _selectedDate = DateTime.parse(movieDetails['release_date'] ?? DateTime.now().toString());
          _imageLink = 'https://image.tmdb.org/t/p/w500${movieDetails['poster_path']}';
          _selectedGenres = movieDetails['genres'] != null 
                ? List<String>.from(movieDetails['genres'].take(6).map((genre) => genre['name'])) 
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
    } catch (e) {
      rethrow;
    }
  }




  void _scrollToTop() {
    _scrollController.animateTo(
      0.0, // 0.0'a kaydırmak sayfanın başı demektir
      duration: const Duration(seconds: 1), // Kaydırma süresi
      curve: Curves.easeInOut, // Animasyon tipi
    );
  }

  // PG Rating seçim dialogunu göstermek için fonksiyon
  Future<void> _showPgRatingSelector(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 44, 50, 60),
          title: Text(
            S.of(context).selectPgRating,
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildPgRatingOption(context, '(G)', 'assets/images/G.png'),
                _buildPgRatingOption(context, '(PG)', 'assets/images/PG.png'),
                _buildPgRatingOption(context, '(PG-13)', 'assets/images/PG13.png'),
                _buildPgRatingOption(context, '(R)', 'assets/images/R.png'),
                _buildPgRatingOption(context, '(NC-17)', 'assets/images/NC17.png'),
                _buildPgRatingOption(context, '', 'assets/images/Unrated.png'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Her bir PG rating seçeneği için widget oluşturan yardımcı fonksiyon
  Widget _buildPgRatingOption(BuildContext context, String rating, String imagePath) {
    return InkWell(
      onTap: () {
        setState(() {
          _pgRating = rating;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        decoration: BoxDecoration(
          color: _pgRating == rating 
            ? Colors.blue.withOpacity(0.3) 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _pgRating == rating 
              ? Colors.blue 
              : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = ScreenUtil.isTablet(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).movieDetails, 
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
          )
        ),
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        iconTheme: IconThemeData(size: ScreenUtil.getAdaptiveIconSize(context, 24),color: Colors.white),
        actions: [
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
                  title: Text(widget.movie!.hidden! ? 
                    S.of(context).restoreHiddenMovies :
                    S.of(context).hideChosenMovies, 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.getAdaptiveTextSize(context, 20),
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
                          await hideMovies(context, widget.movie!, true);
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
            icon: const Icon(Icons.swap_horizontal_circle_outlined, color: Colors.white),
            onPressed: _toggleWatchedStatus,
          ),
          /*
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showAddOptionsMenu(context),
          ),*/
        ],
      ),
      body: Stack(
        children: [
          if(_imageLink != null && _imageLink!.isNotEmpty)
            Positioned.fill(
             child: Image.network(
               _imageLink!, // Resim URL'si
               fit: BoxFit.contain, // Tüm alanı kaplar
               errorBuilder: (context, error, stackTrace) =>
               Image.asset(
                'assets/images/placeholder_poster.png',
                fit: BoxFit.contain,
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
              padding: ScreenUtil.getAdaptivePadding(context),
          child: Column(
            children: [
              TextFormField(
                controller: _movieNameController,
                    decoration: InputDecoration(labelText: '${S.of(context).movieTitle} *', labelStyle: TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16))),
                style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).pleaseEnterMovieTitle;
                  }
                  return null;
                },
              ),
              TextFormField(
                    controller: _sortTitleController,
                    decoration: InputDecoration(labelText: S.of(context).customSortTitle, labelStyle: TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),),
                style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),
                  ),
                  SizedBox(height: screenWidth * 0.1),
                  Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              S.of(context).movieDetails,
                              style: TextStyle(
                                color: Colors.white, 
                              fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028),
                                fontWeight: FontWeight.bold
                              ),
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Divider(height: 0, color: Colors.white60,),
                        SizedBox(height: screenHeight * 0.02,),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _editRuntime,
                              child: Container(
                              height: screenHeight * 0.08,
                              width: screenWidth * 0.32,
                                child: Card(
                                  color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          color: Colors.white,
                                        size: ScreenUtil.getAdaptiveIconSize(context, 17),
                                        ),
                                      SizedBox(width: 2),
                                        Text(
                                          _formatRuntime(_runtimeController.text),
                                          style: TextStyle(
                                            color: Colors.white,
                                          fontSize: ScreenUtil.getAdaptiveTextSize(context, 17),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Container(
                            height: screenHeight * 0.08,
                            width:  screenWidth * 0.2,
                            child: GestureDetector(
                              onTap: () {
                                _showPgRatingSelector(context);
                              },
                              child: Card(
                                color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Image.asset(
                                          _pgRating == '(G)' ? 'assets/images/G.png' :
                                          _pgRating == '(R)' ? 'assets/images/R.png' :
                                          _pgRating == '(PG)' ? 'assets/images/PG.png' :
                                          _pgRating == '(PG-13)' ? 'assets/images/PG13.png' :
                                          _pgRating == '(NC-17)' ? 'assets/images/NC17.png' : 'assets/images/Unrated.png',
                                          width: 100,
                                          height: 50,
                                          ),
                                )
                                ),
                            ),
                          ),
                      Container(
                        height: screenHeight * 0.08,
                        width:  screenWidth * 0.32,
                            child: Card(
                              color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                controller: _imdbRatingController,
                                decoration: InputDecoration(
                                //labelText: S.of(context).imdbScore,
                                //labelStyle: TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),
                                prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                'assets/images/imdb.png',
                                width: 40,
                                height: 40,
                                  ),
                                ),
                                border: InputBorder.none,
                              ),
                                keyboardType: TextInputType.number,
                            style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 19.5), fontWeight: FontWeight.bold),
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
                          ),
                        ),
                          ],
                        ),
                  SizedBox(height: screenWidth * 0.02),
                  if(_afterCreditsExists != null && _basedOn != null)
                  Card(
                    color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Sol taraf
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _basedOn == 'Book' ? S.of(context).basedBook :
                                      _basedOn == 'Comic' ? S.of(context).basedComic : 
                                      _basedOn == 'Manga' ? S.of(context).basedManga : 
                                      _basedOn == 'Documentary' ? S.of(context).basedDocumentary : 
                                      _basedOn == 'Anime' ? S.of(context).basedAnime : 
                                      _basedOn == 'Cartoon' ? S.of(context).basedCartoon : 
                                      _basedOn == 'Toy' ? S.of(context).basedToy : 
                                      _basedOn == 'Manhua' ? S.of(context).basedManhua :
                                      _basedOn == 'Autobiography' ? S.of(context).basedAutobiography : 
                                      _basedOn == 'Manhwa' ? S.of(context).basedManhwa : S.of(context).basedOriginal,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil.getAdaptiveTextSize(context, 12),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Ortadaki dikey çizgi
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: VerticalDivider(
                                thickness: 1,
                                width: 1,
                                color: Colors.white,
                              ),
                            ),
                            // Sağ taraf
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      S.of(context).afterCreditsScene,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil.getAdaptiveTextSize(context, 12),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.015),
                                  Icon(
                                    _afterCreditsExists! ? Icons.check : Icons.clear,
                                    color: _afterCreditsExists! ? Colors.green : Colors.red,
                                    size: screenHeight * 0.02,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.025),
                  if((_budgetController.text.isNotEmpty && toDouble(_budgetController.text)! > 0) && (_revenueController.text.isNotEmpty && toDouble(_revenueController.text)! > 0))
                  Card(
                    color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: ScreenUtil.getAdaptivePadding(context).vertical/2, horizontal: ScreenUtil.getAdaptivePadding(context).horizontal/3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                        Expanded(child: Text('${S.of(context).budgetColon} ${_formatCurrency(double.tryParse(_budgetController.text))}', style:  TextStyle(fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.028), color: Colors.red))),
                          SizedBox(width: screenWidth * 0.1,),
                        Expanded(child: Text('${S.of(context).revenueColon} ${_formatCurrency(double.tryParse(_revenueController.text))}', style: TextStyle(fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.028), color: Colors.red))),
                                          ],
                          ),
                        ),
                        if(_countryController.text.isNotEmpty)
                        Padding(
                  padding: EdgeInsets.fromLTRB(ScreenUtil.getAdaptivePadding(context).horizontal * 0.05, 0, ScreenUtil.getAdaptivePadding(context).horizontal * 0.4, ScreenUtil.getAdaptivePadding(context).vertical * 0.5),
                    child: CountryFlag.fromCountryCode(_countryController.text.toUpperCase()),
                ),
                      ],
                    ),
                  ),    
                      ],
                  ),
                        
                  SizedBox(height: screenWidth * 0.1),
                  if (_providers['flatrate']!.isNotEmpty || 
                      _providers['rent']!.isNotEmpty || 
                      _providers['buy']!.isNotEmpty)
                    Card(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              S.of(context).whereToWatch,
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028),
                                fontWeight: FontWeight.bold
                              ),
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Divider(height: 0, color: Colors.white60,),
                          SizedBox(height: screenHeight *0.02,),
                          ProviderCard(
                            systemLanguage: widget.systemLanguage,
                            providers: (() {
                              final Map<String, Map<String, dynamic>> uniqueProviders = {};
                              
                              for (var provider in _providers['flatrate']! as List) {
                                final providerId = provider['provider_id'].toString();
                                if (!uniqueProviders.containsKey(providerId)) {
                                  uniqueProviders[providerId] = {
                                    'provider_id': providerId,
                                    'logo_path': provider['logo_path'],
                                    'provider_name': provider['provider_name'],
                                    'categories': <String>['Subscription'],
                                  };
                                } else {
                                  uniqueProviders[providerId]!['categories'].add('Subscription');
                                }
                              }
                              
                              for (var provider in _providers['rent']! as List) {
                                final providerId = provider['provider_id'].toString();
                                if (!uniqueProviders.containsKey(providerId)) {
                                  uniqueProviders[providerId] = {
                                    'provider_id': providerId,
                                    'logo_path': provider['logo_path'],
                                    'provider_name': provider['provider_name'],
                                    'categories': <String>['Rent']
                                  };
                                } else {
                                  uniqueProviders[providerId]!['categories'].add('Rent');
                                }
                              }
                              
                              for (var provider in _providers['buy']! as List) {
                                final providerId = provider['provider_id'].toString();
                                if (!uniqueProviders.containsKey(providerId)) {
                                  uniqueProviders[providerId] = {
                                    'provider_id': providerId,
                                    'logo_path': provider['logo_path'],
                                    'provider_name': provider['provider_name'],
                                    'categories': <String>['Buy']
                                  };
                                } else {
                                  uniqueProviders[providerId]!['categories'].add('Buy');
                                }
                              }
                              
                              return uniqueProviders.values.toList();
                            })(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    /* //Implement this ad later
                    if(_adService.bannerAd != null)
            FutureBuilder<Widget>(
              future: _adService.showBannerAd(isTablet),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const SizedBox.shrink();
              },
            ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.of(context).genres, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      IconButton(
                      onPressed: () async {
                        await _addDetails(S.of(context).addGenre, (genre) {
                          setState(() {
                            _selectedGenres.add(genre);
                          });
                        });
                      },
                      icon: Card( 
                        color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add_circle_outline, color: Colors.white, size: ScreenUtil.getAdaptiveIconSize(context, 24)),
                        )),
                    )
                    ],
                  ),
                  const Divider(height: 0, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.05),
                  SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, 16)),
                  _selectedGenres.isNotEmpty
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ScreenUtil.getAdaptiveGridCrossAxisCount(context, 
                            _selectedGenres.length >= 3 ? 3 : 2
                          ),
                            childAspectRatio: isTablet ? 2.0 : 1.5,
                            mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                            crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
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
                                    builder: (context) => GenreMoviesScreen(genre: _selectedGenres[index], isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail, systemLanguage: widget.systemLanguage,),
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
                                      fontSize: ScreenUtil.getAdaptiveTextSize(context, _selectedGenres.length <= 2 ? screenWidth * 0.055 : 
                                      _selectedGenres.length == 3 ? screenWidth * 0.04 : screenWidth * 0.03), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Text(S.of(context).noGenresSelected, style: const TextStyle(color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  SizedBox(height: screenHeight * 0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.of(context).director, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      IconButton(
                        onPressed: () async {
                          _editDirector();
                        },
                        icon: Card( 
                          color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(_directorNameController.text.isEmpty ? Icons.add_circle_outline : Icons.edit, color: Colors.white,),
                          )),
                      ) //18
                    ],
                  ),
                  const Divider(height: 0, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.05),
                  GestureDetector(
                    onLongPress: () {
                      _deleteDirector();
                    },
                    onTap: () async {
                      final movieId = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DirectorScreen(personName: _directorNameController.text, personType: 'Directing', systemLanguage: widget.systemLanguage, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,),
                        ),
                      );
                      
                      if (movieId != null) {
                        //final movieDetails = await _tmdbService.getMovieDetails(movieId);
                        _fetchMovieDetails(movieId);
                        // Handle the movie details as needed
                      }
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _directorNameController.text.isNotEmpty 
                                  ? _directorNameController.text 
                                  : S.of(context).directorNull,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.of(context).actors, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      IconButton(
                      onPressed: () async {
                        await _addDetails(S.of(context).addActor, (actor) {
                          setState(() {
                            _selectedActors.add(actor);
                          });
                        });
                      },
                      icon: Card( 
                        color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add_circle_outline, color: Colors.white, size: ScreenUtil.getAdaptiveIconSize(context, 24)),
                        )),
                    )
                    ],
                  ),
                  const Divider(height: 0, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.05),
                  _selectedActors.isNotEmpty
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _selectedActors.length == 1 ? 2 : _selectedActors.length >= 3 ? 3 : 2 ,
                            childAspectRatio: isTablet ? 2.0 : 1.5,
                            mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                            crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
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
                                    builder: (context) => DirectorScreen(personName: actorName, personType: 'Acting', systemLanguage: widget.systemLanguage, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,),
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
                                      style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, _selectedActors.length < 3 ? screenWidth * 0.05 : screenWidth * 0.03), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Text(S.of(context).noActorsSelected, style: const TextStyle(color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  SizedBox(height: screenWidth * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.of(context).writers, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      IconButton(
                      onPressed: () async {
                        await _addDetails(S.of(context).addWriter, (writer) {
                          setState(() {
                            _selectedWriters.add(writer);
                          });
                        });
                      },
                      icon: Card( 
                        color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add_circle_outline, color: Colors.white, size: ScreenUtil.getAdaptiveIconSize(context, 24)),
                        )),
                    )
                    ],
                  ),
                  const Divider(height: 0, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.05),
                  _selectedWriters.isNotEmpty
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ScreenUtil.getAdaptiveGridCrossAxisCount(context, 
                              _selectedWriters.length >= 3 ? 3 : 2
                            ),
                            childAspectRatio: isTablet ? 2.0 : 1.5,
                            mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                            crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
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
                                    builder: (context) => DirectorScreen(personName: writerName, personType: 'Writing', systemLanguage: widget.systemLanguage, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail,),
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
                                      style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, _selectedWriters.length < 3 ? screenWidth * 0.05 : screenWidth * 0.03), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Text(S.of(context).noWritersSelected, style: const TextStyle(color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  SizedBox(height: screenWidth * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.of(context).productionCompanies, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      IconButton(
                      onPressed: () async {
                        await _addDetails(S.of(context).addProductionCompany, (company) {
                          setState(() {
                            _selectedProductionCompanies.add(company);
                          });
                        });
                      },
                      icon: Card( 
                        color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add_circle_outline, color: Colors.white, size: ScreenUtil.getAdaptiveIconSize(context, 24)),
                        )),
                    )
                    ],
                  ),
                  const Divider(height: 0, color: Colors.white60,),
                  SizedBox(height: screenWidth * 0.05),
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
                                    builder: (context) => CompanyScreen(companyName: companyName, isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail, systemLanguage: widget.systemLanguage,),
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
                                      style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.045), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Text(S.of(context).noCompaniesSelected, style: const TextStyle(color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.05),),
                Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(S.of(context).franchises, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,), //18
                        IconButton(
                        onPressed: () async {
                          await _addDetails(S.of(context).addFranchise, (actor) {
                            setState(() {
                              _selectedFranchises.add(actor);
                            });
                          });
                        },
                        icon: Card( 
                          color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.add_circle_outline, color: Colors.white,),
                          )),
                      )
                      ],
                    ),
                    const Divider(height: 0, color: Colors.white60,),
                    SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenWidth * 0.05),), //50
                _selectedFranchises.isNotEmpty
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ScreenUtil.getAdaptiveGridCrossAxisCount(context, 
                            _selectedFranchises.length == 1 ? 2 : _selectedFranchises.length >= 3 ? 3 : 2
                          ),
                          childAspectRatio: isTablet ? 2.0 : 1.5,
                          mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                          crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedFranchises.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onLongPress: () {
                             _deleteFranchise(index);
                            },
                            child: Card(
                              color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    _selectedFranchises[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, _selectedFranchises.length < 3 ? screenWidth * 0.05 : screenWidth * 0.03,), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Text(S.of(context).noFranchisesSelected, style: TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, 14)), maxLines: 1, overflow: TextOverflow.ellipsis,),
                    SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenWidth * 0.05),), //50
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(S.of(context).tags, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,), //18
                        IconButton(
                        onPressed: () async {
                          await _addDetails(S.of(context).addTag, (actor) {
                            setState(() {
                              _selectedTags.add(actor);
                            });
                          });
                        },
                        icon: Card( 
                          color: const Color.fromARGB(255, 44, 50, 60).withOpacity(0.5),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.add_circle_outline, color: Colors.white,),
                          )),
                      )
                      ],
                    ),
                    const Divider(height: 0, color: Colors.white60,),
                    SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenWidth * 0.05),), //50
                    _selectedTags.isNotEmpty
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ScreenUtil.getAdaptiveGridCrossAxisCount(context, 
                            _selectedTags.length == 1 ? 2 : _selectedTags.length >= 3 ? 3 : 2
                          ),
                          childAspectRatio: isTablet ? 2.0 : 1.5,
                          mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                          crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedTags.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onLongPress: () {
                             _deleteTag(index);
                            },
                            onTap: () async {
                                final movieId = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TagMoviesScreen(tag: _selectedTags[index], isFromWishlist: widget.isFromWishlist, userEmail: widget.userEmail, systemLanguage: widget.systemLanguage,),
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
                                    _selectedTags[index] == 'Superhero' ? S.of(context).superhero :
                                    _selectedTags[index] == 'Sequel' ? S.of(context).sequel :
                                    _selectedTags[index] == 'MCU' ? S.of(context).mcu :
                                    _selectedTags[index] == 'Magic' ? S.of(context).magic :
                                    _selectedTags[index] == 'Supernatural' ? S.of(context).supernatural :
                                    _selectedTags[index] == 'Time Travel' ? S.of(context).timetravel :
                                    _selectedTags[index] == 'Romance' ? S.of(context).romance :
                                    _selectedTags[index] == 'Anime' ? S.of(context).anime :
                                    _selectedTags[index] == 'Prequel' ? S.of(context).prequel :
                                    _selectedTags[index] == 'Chosen One' ? S.of(context).chosenOne :
                                    _selectedTags[index] == 'Fantasy World' ? S.of(context).fantasyWorld :
                                    _selectedTags[index] == 'Isekai' ? S.of(context).isekai :
                                    _selectedTags[index] == 'Pirate' ? S.of(context).pirate :
                                    _selectedTags[index] == 'Martial Arts' ? S.of(context).martialArts :
                                    _selectedTags[index] == 'Kung Fu' ? S.of(context).kungFu :
                                    _selectedTags[index] == 'Yakuza' ? S.of(context).yakuza :
                                    _selectedTags[index] == 'Anti War' ? S.of(context).antiWar :
                                    _selectedTags[index] == 'Sports Documentary' ? S.of(context).sportsDocumentary :
                                    _selectedTags[index] == 'Dystopia' ? S.of(context).dystopia :
                                    _selectedTags[index] == 'Steampunk' ? S.of(context).steampunk :
                                    _selectedTags[index] == 'Robot' ? S.of(context).robot :
                                    _selectedTags[index] == 'Silent Film' ? S.of(context).silentFilm :
                                    _selectedTags[index] == 'Cyberpunk' ? S.of(context).cyberpunk :
                                    _selectedTags[index] == 'Military' ? S.of(context).military :
                                    _selectedTags[index] == 'Sci-fi' ? S.of(context).sciFi :
                                    _selectedTags[index] == 'Space' ? S.of(context).space :
                                    _selectedTags[index] == 'Prison' ? S.of(context).prison :
                                    _selectedTags[index] == 'AI' ? S.of(context).ai :
                                    _selectedTags[index] == 'Philosophy' ? S.of(context).philosophy :
                                    _selectedTags[index] == 'Mafia' ? S.of(context).mafia :
                                    _selectedTags[index] == 'Detective' ? S.of(context).detective :
                                    _selectedTags[index] == 'Dark Comedy' ? S.of(context).darkComedy :
                                    _selectedTags[index] == 'School' ? S.of(context).school : _selectedTags[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, _selectedTags.length < 3 ? screenWidth * 0.05 : screenWidth * 0.03,), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Text(S.of(context).noTagsSelected, style: TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, 14)), maxLines: 1, overflow: TextOverflow.ellipsis,),
                /* //Implement this ad later
                if(_adService.bannerAd != null)
                SizedBox(height: screenHeight * 0.05),
                if(_adService.bannerAd != null)
            FutureBuilder<Widget>(
              future: _adService.showBannerAd(isTablet),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const SizedBox.shrink();
              },
            ),*/
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil.getAdaptivePadding(context).vertical, horizontal: ScreenUtil.getAdaptivePadding(context).horizontal), // Padding for better spacing
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
                                fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.015),
                              ),
                            ),
                            TextSpan(
                              text: DateFormat('dd MMMM yyyy').format(_selectedDate.toLocal()),
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.023),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.getAdaptivePadding(context).horizontal * 0.01),
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
              TextFormField(
                controller: _plotController,
                decoration: InputDecoration(labelText: S.of(context).plot, labelStyle: TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),),
                maxLines: 3,
                style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),
              ),
              SizedBox(height: screenHeight * 0.03,),
              if(!widget.isFromWishlist)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                    value: _selectedCollectionType,
                    dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),
                    decoration: InputDecoration(
                      labelText: S.of(context).collectionType,
                      labelStyle: TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),
                    ),
                    items: [
                      DropdownMenuItem(value: '', alignment: Alignment.center, child: Text(S.of(context).none, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'VHS', alignment: Alignment.center, child: Text(S.of(context).vhs, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'DVD', alignment: Alignment.center, child: Text(S.of(context).dvd, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'BLU-RAY', alignment: Alignment.center, child: Text(S.of(context).bluRay, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Steelbook', alignment: Alignment.center, child: Text(S.of(context).steelbook, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Digital', alignment: Alignment.center, child: Text(S.of(context).digital, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Disney Plus', alignment: Alignment.center, child: Text('Disney Plus', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Netflix', alignment: Alignment.center, child: Text('Netflix', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Amazon Prime Video', alignment: Alignment.center, child: Text('Amazon Prime Video', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Hulu', alignment: Alignment.center, child: Text('Hulu', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Peacock', alignment: Alignment.center, child: Text('Peacock', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'HBO Max', alignment: Alignment.center, child: Text('HBO Max', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Paramount+', alignment: Alignment.center, child: Text('Paramount+', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Crunchyroll', alignment: Alignment.center, child: Text('Crunchyroll', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Google TV', alignment: Alignment.center, child: Text('Google TV', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Apple TV+', alignment: Alignment.center, child: Text('Apple TV+', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Sling TV', alignment: Alignment.center, child: Text('Sling TV', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Blu TV', alignment: Alignment.center, child: Text('Blu TV', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                      DropdownMenuItem(value: 'Puhu TV', alignment: Alignment.center, child: Text('Puhu TV', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),)),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCollectionType = newValue;
                        });
                      }
                    },
                                    ),
                  ),
              Container(
                    height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight *0.05),  // Çizginin yüksekliğini ayarlayın
                    child: const VerticalDivider(
                      color: Colors.white54,  // Dikey çizgi rengi
                      thickness: 1,  // Çizginin kalınlığı
                    ),
                  ),
              Expanded(
                child: TextFormField(
                  controller: _watchCountController,
                  decoration: InputDecoration(labelText: S.of(context).watchCount, labelStyle: TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),),
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
                  style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),
                ),
              ),
                ],
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: S.of(context).myNotes, labelStyle: TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),),
                maxLines: 3,
                style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, 16)),
              ),
              if (!widget.isFromWishlist) ...{
                ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil.getAdaptivePadding(context).vertical * 0.01, horizontal: ScreenUtil.getAdaptivePadding(context).horizontal * 0.02), // Padding for better spacing
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
                                fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.015),
                              ),
                            ),
                            TextSpan(
                              text: DateFormat('dd MMMM yyyy').format(_watchedDate!.toLocal()),
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.023),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil.getAdaptivePadding(context).horizontal * 0.01),
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
                              decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3), // Siyah yarı saydam filtre
                              borderRadius: BorderRadius.circular(20),
                            ),
                            ),
                ),
                if(!widget.isFromWishlist)
                RatingBar.builder(
                  unratedColor: Colors.blueGrey.withOpacity(0.6),
                  itemSize: ScreenUtil.getAdaptiveIconSize(context, 30),
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
                              decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3), // Siyah yarı saydam filtre
                              borderRadius: BorderRadius.circular(20),
                            ),
                            ),
                          ),                 
                          RatingBar.builder(
                          unratedColor: Colors.blueGrey.withOpacity(0.6),
                          itemSize: ScreenUtil.getAdaptiveIconSize(context, 30),
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
                  const SizedBox(height: 30),
                  if(_seriesMovies.isNotEmpty)
                  Card(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(S.of(context).otherMoviesInSeries, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ),
                        Container(
                          height: isTablet ? screenHeight * 0.45 : screenHeight * 0.3,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _seriesMovies.length,
                            itemBuilder: (context, index) {
                              final movie = _seriesMovies[index];
                              return GestureDetector(
                                onTap: () async {
                                    final movieDetails = await TmdbService().getMovieDetails(movie['id']);
                                    final movieDetailsLanguage = await TmdbService().getMovieDetails(movie['id'], languageCode: widget.systemLanguage);
                                    if (movieDetails != null) {
                                      final chosenMovie = Movie(
                                        id: movieDetails['id'].toString(),
                                        movieName: movieDetails['title'] ?? '',
                                        directorName: movieDetails['credits']['crew']
                                            ?.firstWhere((crew) => crew['job'] == 'Director', orElse: () => {'name': ''})['name'] ?? '',
                                        releaseDate: movieDetails['release_date'] != null 
                                            ? DateTime.parse(movieDetails['release_date']) 
                                            : DateTime.now(),
                                        plot: movieDetailsLanguage!['overview'] ?? movieDetails['overview'] ?? '',
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
                                            ?.take(6)
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
                                        watched: false,
                                        userEmail: widget.userEmail ?? 'test@test.com',
                                        hidden: false
                                      );
                        
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddMovieScreen(
                                              isFromWishlist: true,
                                              movie: chosenMovie,
                                              systemLanguage: widget.systemLanguage,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                },
                                child: Container(
                                  width: isTablet ? screenWidth * 0.6 : screenWidth * 0.4,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Card(
                                    color: const Color.fromARGB(255, 44, 50, 60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    elevation: 8,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12.0),
                                            topRight: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                            bottomLeft: Radius.circular(12.0),
                                          ),
                                          child: Image.network(
                                            'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                            fit: BoxFit.cover,
                                            height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                                            width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                                            errorBuilder: (context, error, stackTrace) =>
                                              Image.asset(
                                                'assets/images/placeholder_poster.png',
                                                fit: BoxFit.cover,
                                                height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                                                width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                                              ),
                                          ),
                                        ),
                                        ),
                                        /*
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 44, 50, 60),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight: Radius.circular(10),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight *0.005)),
                                                Padding(
                                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                                  child: Text(
                                    movie['title'] ?? S.of(context).noTitle,
                                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.027), fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    child: Column(
                                      children: [
                                        if(movie['genre_ids'] != null && movie['genre_ids'].any((id) => genreMap[id] != null))
                                        Text(
                                          '${movie['genre_ids'].map((id) => 
                                          _getGenreLocalizedString(genreMap[id] ?? 'Action')
                                          ).take(3).join(', ')}',
                                          style:  TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.025)),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.001)),
                                        if (movie['release_date'] != null)
                                        Text(
                                          '${movie['release_date'].split('-')[0]}',
                                          style:  TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.025)),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                              ],
                                            ),
                                          ),
                                        ),*/
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  if(_similarMovies.length > 3)
                  Card(color: Colors.transparent,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(S.of(context).similarMovies, style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenHeight * 0.028), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ),
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ScreenUtil.getAdaptiveGridCrossAxisCount(context, 3),
                        childAspectRatio: isTablet ? 2.0 : 0.4,
                        mainAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
                        crossAxisSpacing: ScreenUtil.getAdaptiveGridSpacing(context, 8),
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
                              final movieDetailsLanguage = await TmdbService().getMovieDetails(similarMovie['id'], languageCode: widget.systemLanguage);
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
                                  plot: movieDetailsLanguage!['overview'] ?? movieDetails['overview'] ?? '',
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
                                      ?.take(6)
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
                                  userEmail: widget.userEmail ?? 'test@test.com',
                                  hidden: false
                                );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddMovieScreen(
                                        isFromWishlist: widget.isFromWishlist,
                                        movie: chosenMovie,
                                        systemLanguage: widget.systemLanguage,
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
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16.0), // Sol üst köşe
                                          topRight: Radius.circular(16.0), // Sağ üst köşe
                                        ),
                                      child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${similarMovie['poster_path']}',
                                          fit: BoxFit.cover,
                                          height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.22),
                                          width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.35),
                                        ),
                                    )
                                    : const Icon(Icons.movie, size: 100, color: Colors.white54),
                                SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight *0.01)),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 5),
                                  child: Text(
                                    similarMovie['title'] ?? S.of(context).noTitle,
                                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.027), fontWeight: FontWeight.bold),
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
                                          style:  TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.025)),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.001)),
                                        if (similarMovie['release_date'] != null)
                                        Text(
                                          '${similarMovie['release_date'].split('-')[0]}',
                                          style:  TextStyle(color: Colors.white54, fontSize: ScreenUtil.getAdaptiveTextSize(context, screenWidth * 0.025)),
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
              const SizedBox(height: 30,),
              //Upload Image
              /*
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
              */
              if(_adService.bannerAd != null)
            FutureBuilder<Widget>(
              future: _adService.showBannerAd(isTablet),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const SizedBox.shrink();
              },
            ),
              const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  fixedSize: Size(
                    double.infinity,
                    ScreenUtil.getAdaptiveCardHeight(context, 50),
                  ),
                ),
                onPressed: _saveMovie,
                        icon: const Icon(Icons.save),
                        label: Text(S.of(context).update, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          fixedSize: Size(
                            double.infinity,
                            ScreenUtil.getAdaptiveCardHeight(context, 50),
                          ),
                        ),
                        onPressed: _deleteMovie,
                        icon: const Icon(Icons.delete),
                        label: Text(S.of(context).delete, style: const TextStyle(fontSize: 18)),
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
    _notesController.dispose();
    _runtimeController.dispose();
    _imdbRatingController.dispose();
    _watchCountController.dispose();
    _writersController.dispose();
    _actorsController.dispose();
    _productionCompanyController.dispose();
    _countryController.dispose();
    _popularityController.dispose();
    _budgetController.dispose();
    _revenueController.dispose();
    _scrollController.dispose();
    _adService.disposeAds();
    super.dispose();
  }
} 