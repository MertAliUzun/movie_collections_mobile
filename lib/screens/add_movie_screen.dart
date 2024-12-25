import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'dart:async';
import '../models/movie_model.dart';
import '../services/supabase_service.dart';
import '../services/omdb_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddMovieScreen extends StatefulWidget {
  final bool isFromWishlist;

  const AddMovieScreen({super.key, required this.isFromWishlist});

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
  final _rtRatingController = TextEditingController();
  final _writersController = TextEditingController();
  final _actorsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _watchedDate = DateTime.now();
  double _userScore = 0.0;
  File? _selectedImage;
  bool _isUploading = false;
  String? _imageLink;
  final cloudinary = CloudinaryPublic('dper5kp88', 'YOUR_UPLOAD_PRESET', cache: false);
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  final _omdbService = OmdbService();

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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (query.length >= 2) {
        setState(() {
          _isSearching = true;
        });
        try {
          final results = await _omdbService.searchMovies(query);
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        } catch (e) {
          setState(() {
            _isSearching = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Film arama hatası: $e')),
            );
          }
        }
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _selectMovie(String imdbId) async {
    try {
      final movieDetails = await _omdbService.getMovieDetails(imdbId);
      if (movieDetails != null) {
        setState(() {
          _movieNameController.text = movieDetails['Title'] ?? '';
          _directorNameController.text = movieDetails['Director'] ?? '';
          _plotController.text = movieDetails['Plot'] ?? '';
          _runtimeController.text = movieDetails['Runtime']?.replaceAll(' min', '') ?? '';
          _imdbRatingController.text = movieDetails['imdbRating'] ?? '';
          _rtRatingController.text = movieDetails['Ratings']
              ?.firstWhere((r) => r['Source'] == 'Rotten Tomatoes', orElse: () => {'Value': '0'})['Value']
              ?.replaceAll('%', '') ?? '0';
          _writersController.text = movieDetails['Writer'] ?? '';
          _actorsController.text = movieDetails['Actors'] ?? '';
          
          if (movieDetails['Released'] != null && movieDetails['Released'] != 'N/A') {
            try {
              final dateStr = movieDetails['Released'];
              final dateParts = dateStr.split(' ');
              final months = {
                'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
              };
              
              final day = int.parse(dateParts[0]);
              final month = months[dateParts[1]] ?? 1;
              final year = int.parse(dateParts[2]);
              
              _selectedDate = DateTime(year, month, day);
            } catch (e) {
              print('Tarih parse edilemedi: ${movieDetails['Released']}');
            }
          }
          
          _imageLink = movieDetails['Poster'] ?? '';
        });
        _searchController.clear();
        _searchResults = [];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Film detayları alınırken hata oluştu: $e')),
        );
      }
    }
  }

  void _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      final supabase = Supabase.instance.client;
      final service = SupabaseService(supabase);

      final movie = Movie(
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
        rtRating: _rtRatingController.text.isNotEmpty 
            ? double.tryParse(_rtRatingController.text) 
            : null,
        writers: _writersController.text.isNotEmpty 
            ? _writersController.text.split(',').map((e) => e.trim()).toList() 
            : null,
        actors: _actorsController.text.isNotEmpty 
            ? _actorsController.text.split(',').map((e) => e.trim()).toList() 
            : null,
        watchDate: widget.isFromWishlist ? null : _watchedDate,
        userScore: widget.isFromWishlist ? null : _userScore,
        watched: !widget.isFromWishlist,
        imageLink: _imageLink ?? '',
        userEmail: 'test@test.com',
      );

      try {
        await service.addMovie(movie);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Film başarıyla eklendi')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Film Ekle'),
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
                  hintText: 'Film ara...',
                  prefixIcon: const Icon(Icons.search),
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
                onChanged: _onSearchChanged,
              ),
              if (_searchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = _searchResults[index];
                        return ListTile(
                          leading: movie['Poster'] != 'N/A'
                              ? Image.network(
                                  movie['Poster'],
                                  width: 50,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.movie),
                                )
                              : const Icon(Icons.movie),
                          title: Text(movie['Title']),
                          subtitle: Text(movie['Year']),
                          onTap: () => _selectMovie(movie['imdbID']),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _movieNameController,
                decoration: const InputDecoration(labelText: 'Film Adı *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen film adını girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _directorNameController,
                decoration: const InputDecoration(labelText: 'Yönetmen *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen yönetmen adını girin';
                  }
                  return null;
                },
              ),
              ListTile(
                  title: Text(
                    'Çıkış Tarihi: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _watchDate(context),
                ),
              TextFormField(
                controller: _plotController,
                decoration: const InputDecoration(labelText: 'Konu'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _runtimeController,
                decoration: const InputDecoration(labelText: 'Süre (dakika)'),
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
              ),
              TextFormField(
                controller: _imdbRatingController,
                decoration: const InputDecoration(labelText: 'IMDB Puanı'),
                keyboardType: TextInputType.number,
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
              TextFormField(
                controller: _rtRatingController,
                decoration: const InputDecoration(labelText: 'Rotten Tomatoes Puanı'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = double.tryParse(value);
                    if (number == null || number < 0 || number > 100) {
                      return 'Geçerli bir puan girin (0-100)';
                    }
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _writersController,
                decoration: const InputDecoration(
                  labelText: 'Senaristler',
                  helperText: 'Virgülle ayırarak yazın',
                ),
              ),
              TextFormField(
                controller: _actorsController,
                decoration: const InputDecoration(
                  labelText: 'Oyuncular',
                  helperText: 'Virgülle ayırarak yazın',
                ),
                //User Section
              ),
              if (!widget.isFromWishlist) ...{
                ListTile(
                  title: Text(
                    'İzleme Tarihi: ${_watchedDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
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
              SizedBox(height: 10,),
              },
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
                                  Icon(Icons.cloud_upload, size: 50),
                                  Text('Film afişi seçmek için tıklayın'),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMovie,
                child: const Text('Filmi Ekle'),
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
    _directorNameController.dispose();
    _plotController.dispose();
    _runtimeController.dispose();
    _imdbRatingController.dispose();
    _rtRatingController.dispose();
    _writersController.dispose();
    _actorsController.dispose();
    super.dispose();
  }
} 