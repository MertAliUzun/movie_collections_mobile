import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/movie_model.dart';
import '../screens/edit_movie_screen.dart';
import '../main.dart';

class DrawerWidget extends StatefulWidget {
  final String _viewType;
  final String _groupByText;
  final String _sortBy;
  final String _sortDir;
  final bool _isFromWishlist;
  final List<Movie> _movies;
  final List<Movie> _allMovies;
  final ValueChanged<String> _changeViewType;
  final ValueChanged<String> _toggleGroupBy;
  final ValueChanged<String> _onSortByChanged;
  final ValueChanged<String> _onSortDirChanged;
  final String? userPicture; // Kullanıcı profil resmi
  final String? userId; 
  final String? userEmail; 
  final String? userName;

  const DrawerWidget({
    Key? key,
    required String viewType,
    required String groupByText,
    required String sortBy,
    required String sortDir,
    required bool isFromWishlist,
    required List<Movie> movies,
    required List<Movie> allMovies,
    required ValueChanged<String> changeViewType,
    required ValueChanged<String> toggleGroupBy,
    required ValueChanged<String> onSortByChanged,
    required ValueChanged<String> onSortDirChanged,
    this.userPicture, // Kullanıcı profil resmini al
    this.userEmail,
    this.userId,
    this.userName,
  })  : _viewType = viewType,
        _groupByText = groupByText,
        _changeViewType = changeViewType,
        _toggleGroupBy = toggleGroupBy,
        _sortBy = sortBy,
        _onSortByChanged = onSortByChanged,
        _onSortDirChanged = onSortDirChanged,
        _sortDir = sortDir,
        _isFromWishlist = isFromWishlist,
        _movies = movies,
        _allMovies = allMovies,
        super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late String _viewType;
  late String _groupByText;
  late String _sortBy;
  late String _sortDir;
  late bool _isFromWishlist;
  late List<Movie> _movies;
  late ValueChanged<String> _changeViewType;
  late ValueChanged<String> _toggleGroupBy;
  late ValueChanged<String> _onSortByChanged;
  late ValueChanged<String> _onSortDirChanged;
  late String? userPicture; // Kullanıcı profil resmi
  late String? userId; 
  late String? userEmail; 
  late String? userName;

  @override
  void initState() {
    super.initState();
    _viewType = widget._viewType;
    _groupByText = widget._groupByText;
    _sortBy = widget._sortBy;
    _sortDir = widget._sortDir;
    _isFromWishlist = widget._isFromWishlist;
    _movies = widget._movies;
    _changeViewType = widget._changeViewType;
    _toggleGroupBy = widget._toggleGroupBy;
    _onSortByChanged = widget._onSortByChanged;
    _onSortDirChanged = widget._onSortDirChanged;
    userPicture = widget.userPicture;
    userId = widget.userId;
    userEmail = widget.userEmail;
    userName = widget.userName;
  }

  Movie? _getRandomMovie(BuildContext context) {
    final random = Random();
    
    // Koşula göre filtreleme yap
    List<Movie> filteredMovies = _isFromWishlist
        ? _movies.where((movie) => !movie.watched).toList() // watched == false
        : _movies.where((movie) => movie.watched).toList(); // watched == true
  
    if (filteredMovies.isEmpty) {
      // Eğer filtrelenmiş listede film yoksa, Snackbar göster
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: 'Failure!', 
          message: 'Unable to Detect Movies!', 
          contentType: ContentType.failure, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);

      return null; // Hiçbir film bulunamadıysa null döndür
    }
  
    // Rastgele bir film seç
    return filteredMovies[random.nextInt(filteredMovies.length)];
  }

  Future<void> _signOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
          title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
          content: const Text('Çıkış yapmak istediğinize emin misiniz?', style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: const Text('Hayır', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Evet', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      // Çıkış işlemi başarılı olduğunda Snackbar göster
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: 'Çıkış Başarılı!', 
          message: 'Hesabınızdan çıkış yapıldı.', 
          contentType: ContentType.success, 
          inMaterialBanner: true,
        ), 
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);

      // Uygulamayı kapat
      SystemNavigator.pop(); // Uygulamayı kapat
    }
  }

  Future<void> _googleSignIn(BuildContext context) async {
    const webClientId = '994622404083-l5lm49gg40agjbrh0vvtnbo6b3sddl3u.apps.googleusercontent.com';
    const iosClientId = '994622404083-pmh33nqujdu7pvekl5djj4nge8hi0v2n.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In was canceled.';
      }
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      /*
      // Kullanıcı bilgilerini al
      final String userId = googleUser.id;
      final String userEmail = googleUser.email;
      final String userPicture = googleUser.photoUrl ?? '';
      final String userName = googleUser.displayName ?? '';
      */

      // Ana sayfaya yönlendirme yap ve kullanıcı bilgilerini geç
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            
          ),
        ),
      );
    } catch (e) {
      // Hata durumunda kullanıcıya mesaj göster
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: 'Hata!', 
          message: e.toString(), 
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

  Future<void> exportMoviesToCSV() async {
    // İzinleri kontrol et ve talep et
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
            // İzin verilmezse kullanıcıya mesaj göster
            final snackBar = SnackBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                behavior: SnackBarBehavior.floating,
                content: AwesomeSnackbarContent(
                    title: 'Hata!',
                    message: 'Depolama izni verilmedi.',
                    contentType: ContentType.failure,
                    inMaterialBanner: true,
                ),
            );
            ScaffoldMessenger.of(context)
                ..hideCurrentMaterialBanner()
                ..showSnackBar(snackBar);
            return; // İzin verilmezse işlemi durdur
        }
    }

    if (status.isDenied) {
        // Kullanıcı izni reddettiyse ayarlar sayfasına yönlendirin
        openAppSettings();
    }

    // CSV formatında başlıkları tanımlayın
    List<List<String>> csvData = [
      [
        'ID', 
        'Movie Name', 
        'Director Name', 
        'Release Date', 
        'Plot', 
        'Runtime', 
        'IMDB Rating', 
        'Writers', 
        'Actors', 
        'Watched', 
        'Image Link', 
        'User Email', 
        'Watch Date', 
        'User Score', 
        'Hype Score', 
        'Genres', 
        'Production Company', 
        'Custom Sort Title', 
        'Country', 
        'Popularity', 
        'Budget', 
        'Revenue', 
        'To Sync'
      ],
    ];

    // allMovies listesini CSV formatına dönüştürün
    for (var movie in widget._allMovies) {
      csvData.add([
        movie.id,
        movie.movieName,
        movie.directorName,
        movie.releaseDate.toIso8601String(),
        movie.plot ?? '',
        movie.runtime?.toString() ?? '',
        movie.imdbRating?.toString() ?? '',
        movie.writers?.join(', ') ?? '',
        movie.actors?.join(', ') ?? '',
        movie.watched.toString(),
        movie.imageLink,
        movie.userEmail,
        movie.watchDate?.toIso8601String() ?? '',
        movie.userScore?.toString() ?? '',
        movie.hypeScore?.toString() ?? '',
        movie.genres?.join(', ') ?? '',
        movie.productionCompany?.join(', ') ?? '',
        movie.customSortTitle ?? '',
        movie.country ?? '',
        movie.popularity?.toString() ?? '',
        movie.budget?.toString() ?? '',
        movie.revenue?.toString() ?? '',
        movie.toSync.toString(),
      ]);
    }

    // CSV verisini bir String'e dönüştürün
    String csvString = const ListToCsvConverter().convert(csvData);

    try {
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/movies.csv';
      final file = File(path);
      await file.writeAsString(csvString);

      // Kullanıcıya başarı mesajı göster
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: 'Başarılı!',
          message: 'CSV dosyası başarıyla oluşturuldu: $path',
          contentType: ContentType.success,
          inMaterialBanner: true,
        ),
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: 'Başarısız!',
          message: 'Hata: $e',
          contentType: ContentType.failure,
          inMaterialBanner: true,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> sortingOptions = [
      const DropdownMenuItem(value: 'movieName', child: Text('Title')),
      const DropdownMenuItem(value: 'releaseDate', child: Text('Release Date')),
      const DropdownMenuItem(value: 'directorName', child: Text('Director')),
      const DropdownMenuItem(value: 'imdbRating', child: Text('IMDB Rating')),
      const DropdownMenuItem(value: 'runtime', child: Text('Runtime')),
    ];
    if (_isFromWishlist) {
      sortingOptions.add(const DropdownMenuItem(value: 'hypeScore', child: Text('Hype Score')));
    } else {
      sortingOptions.add(const DropdownMenuItem(value: 'userScore', child: Text('User Score')));
      sortingOptions.add(const DropdownMenuItem(value: 'watchDate', child: Text('Watch Date')));
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top),
      width: screenWidth * 0.7,
      child: Drawer(
        backgroundColor: Color.fromARGB(255, 44, 50, 60),
        child: ListView(
          children: [
            DrawerHeader(
              child: userPicture != null
                  ? Column(
                    children: [
                      GestureDetector(
                        onTap: () => _signOut(context),
                        child: ClipOval(
                          child: Image.network(
                            userPicture!,
                            fit: BoxFit.scaleDown, // Resmi çerçeveye göre ölçeklendirir
                            width: 90, // Çap kadar genişlik
                            height: 90, // Çap kadar yükseklik
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text: 'Welcome, ',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: userName!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ),
                    ],
                  )
                  : IconButton(
                icon: Icon(Icons.login, size: 50),
                onPressed: () async {
                  // Google hesabına giriş yap
                  await _googleSignIn(context); // Google Sign-In fonksiyonunu çağır
                  print('object');
                },
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View As',
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _viewType,
                        icon: Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.16, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        underline: SizedBox(),
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            _changeViewType(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: ['List', 'List(Small)', 'Card', 'Poster'].map((String choice) {
                          return DropdownMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(fontSize: screenWidth * 0.055, color: Colors.white70),
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
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _groupByText,
                        icon: Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.11, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        underline: SizedBox(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _toggleGroupBy(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: ['None', 'Director', 'Genre', 'Release Year', if (!_isFromWishlist) 'Watch Year',].map((String choice) {
                          return DropdownMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(fontSize: screenWidth * 0.055, color: Colors.white70),
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
                    'Sort By',
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.02, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        icon: Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.14, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.055,),
                        underline: SizedBox(),
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            _onSortByChanged(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: sortingOptions,
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
                  Row(
                    children: [
                      Text(
                        'Sort ',
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                      ),
                      Icon(_sortDir == 'Ascending' ? Icons.north : Icons.south , color: Colors.white, size: 18,),
                    ],
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _sortDir,
                        icon: Padding(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.14, 0, 0, 0),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.055,),
                        underline: SizedBox(),
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            _onSortDirChanged(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: ['Ascending', 'Descending'].map((String choice) {
                          return DropdownMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(fontSize: screenWidth * 0.055, color: Colors.white70),
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
                children: [
                  Container(
                    width: screenWidth * 0.45,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.03, 0, screenHeight * 0.01),
                      child: TextButton(
                        onPressed: () {
                          exportMoviesToCSV(); // CSV dışa aktarma fonksiyonunu çağır
                        },
                        style: TextButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white,
                            width: .3,
                          ),
                          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Export to CSV', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039)),
                              SizedBox(width: screenWidth * 0.03),
                              Icon(size: screenWidth * 0.055, Icons.import_export, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.45,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.03, 0, screenHeight * 0.01),
                      child: TextButton(onPressed:() {
                        final movie = _getRandomMovie(context);
                        if (movie == null)
                        Navigator.of(context).pop();
                        if (movie != null)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMovieScreen(isFromWishlist: _isFromWishlist, movie: movie, userEmail: userEmail,),
                          ),
                        );
                      },style: TextButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white,
                          width: .3,
                        ),
                        backgroundColor: const Color.fromARGB(255, 34, 40, 50),),  
                        child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Import from CSV', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039),),
                            SizedBox(width: screenWidth * 0.03,),
                            Icon(size: screenWidth * 0.055,
                            _isFromWishlist ? Icons.bookmark : Icons.movie,  
                             color: _isFromWishlist ? Colors.red : Colors.amber,),
                          ],
                        ), 
                      )),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.45,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.03, 0, screenHeight * 0.01),
                      child: TextButton(onPressed:() {
                        final movie = _getRandomMovie(context);
                        if (movie == null)
                        Navigator.of(context).pop();
                        if (movie != null)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMovieScreen(isFromWishlist: _isFromWishlist, movie: movie, userEmail: userEmail,),
                          ),
                        );
                      },style: TextButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white,
                          width: .3,
                        ),
                        backgroundColor: const Color.fromARGB(255, 34, 40, 50),),  
                        child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Random Movie', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039),),
                            SizedBox(width: screenWidth * 0.03,),
                            Icon(size: screenWidth * 0.055,
                            _isFromWishlist ? Icons.bookmark : Icons.movie,  
                             color: _isFromWishlist ? Colors.red : Colors.amber,),
                          ],
                        ), 
                      )),
                    ),
                  ),
                ],
              ),

            ),
          ],
        ),
      ),
    );
  }
}
