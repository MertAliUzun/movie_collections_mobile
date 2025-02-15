import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';

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
    // İzinleri kontrol et
    if (!await requestPermission()) return; // İzin verilmezse işlemi durdur

    List<List<dynamic>> csvData = [
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

    for (var movie in widget._allMovies) {
      csvData.add([
        movie.id.toString(),                                    // String
        movie.movieName.toString(),                            // String
        movie.directorName.toString(),                         // String
        movie.releaseDate.toIso8601String(),                  // DateTime -> String
        movie.plot?.toString() ?? '',                         // String?
        movie.runtime?.toString() ?? '',                      // int? -> String
        movie.imdbRating?.toString() ?? '',                   // double? -> String
        movie.writers?.join(', ') ?? '',                      // List<String>? -> String
        movie.actors?.join(', ') ?? '',                       // List<String>? -> String
        movie.watched.toString(),                             // bool -> String
        movie.imageLink.toString(),                           // String
        movie.userEmail.toString(),                           // String
        movie.watchDate?.toIso8601String() ?? '',            // DateTime? -> String
        movie.userScore?.toString() ?? '',                    // double? -> String
        movie.hypeScore?.toString() ?? '',                    // double? -> String
        movie.genres?.join(', ') ?? '',                       // List<String>? -> String
        movie.productionCompany?.join(', ') ?? '',           // List<String>? -> String
        movie.customSortTitle?.toString() ?? '',             // String?
        movie.country?.toString() ?? '',                     // String?
        movie.popularity?.toString() ?? '',                  // double? -> String
        movie.budget?.toString() ?? '',                      // double? -> String
        movie.revenue?.toString() ?? '',                     // double? -> String
        movie.toSync.toString()                             // bool -> String
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
      // Hata durumunda kullanıcıya mesaj göster
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: 'Hata!',
          message: 'Dosya yazma hatası: $e',
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

  Future<void> importMoviesFromCSV() async {
    if (!await requestPermission()) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;

      try {
        final input = File(filePath).openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();

        final moviesBox = Hive.box<Movie>('movies');

        for (var row in fields.skip(1)) {
          try {
            final movie = Movie(
              id: row[0].toString(),                                    // String
              movieName: row[1].toString(),                            // String
              directorName: row[2].toString(),                         // String
              releaseDate: DateTime.parse(row[3].toString()),          // String -> DateTime
              plot: row[4].toString().isEmpty ? null : row[4].toString(), // String?
              runtime: row[5].toString().isEmpty ? null : int.parse(row[5].toString()),    // String -> int?
              imdbRating: row[6].toString().isEmpty ? null : double.parse(row[6].toString()), // String -> double?
              writers: row[7].toString().isEmpty ? null : row[7].toString().split(', '),   // String -> List<String>?
              actors: row[8].toString().isEmpty ? null : row[8].toString().split(', '),    // String -> List<String>?
              watched: row[9].toString().toLowerCase() == 'true',      // String -> bool
              imageLink: row[10].toString(),                           // String
              userEmail: row[11].toString(),                           // String
              watchDate: row[12].toString().isEmpty ? null : DateTime.parse(row[12].toString()), // String -> DateTime?
              userScore: row[13].toString().isEmpty ? null : double.parse(row[13].toString()),   // String -> double?
              hypeScore: row[14].toString().isEmpty ? null : double.parse(row[14].toString()),   // String -> double?
              genres: row[15].toString().isEmpty ? null : row[15].toString().split(', '),        // String -> List<String>?
              productionCompany: row[16].toString().isEmpty ? null : row[16].toString().split(', '), // String -> List<String>?
              customSortTitle: row[17].toString().isEmpty ? null : row[17].toString(),           // String?
              country: row[18].toString().isEmpty ? null : row[18].toString(),                   // String?
              popularity: row[19].toString().isEmpty ? null : double.parse(row[19].toString()),  // String -> double?
              budget: row[20].toString().isEmpty ? null : double.parse(row[20].toString()),      // String -> double?
              revenue: row[21].toString().isEmpty ? null : double.parse(row[21].toString()),     // String -> double?
              toSync: row[22].toString().toLowerCase() == 'true'       // String -> bool
            );

            moviesBox.put(movie.id, movie);
          } catch (e) {
            print('Satır dönüştürme hatası: $e');
            continue; // Hatalı satırı atla ve devam et
          }
        }

        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: AwesomeSnackbarContent(
            title: 'Başarılı!',
            message: 'CSV dosyası başarıyla içe aktarıldı.',
            contentType: ContentType.success,
            inMaterialBanner: true,
          ),
          dismissDirection: DismissDirection.horizontal,
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showSnackBar(snackBar);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            
          ),
        ),
      );

      } catch (e) {
        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: AwesomeSnackbarContent(
            title: 'Hata!',
            message: 'Dosya okuma hatası: $e',
            contentType: ContentType.failure,
            inMaterialBanner: true,
          ),
          dismissDirection: DismissDirection.horizontal,
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showSnackBar(snackBar);
      }
    } else {
      // Kullanıcı dosya seçmeyi iptal ettiyse
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: 'İptal Edildi!',
          message: 'Dosya seçimi iptal edildi.',
          contentType: ContentType.warning,
          inMaterialBanner: true,
        ),
        dismissDirection: DismissDirection.horizontal,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(snackBar);
    }
  }

  Future<bool> requestPermission() async {
    var status = await Permission.manageExternalStorage.status;
    bool isOld = false;
    if(status.isRestricted) {status = await Permission.storage.status; isOld = true;}
    if (!status.isGranted) {
      if(isOld) {
        status = await Permission.storage.request();
      }
      else {
        status = await Permission.manageExternalStorage.request();
      }
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
          dismissDirection: DismissDirection.horizontal,
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showSnackBar(snackBar);
        return false; // İzin verilmezse false döndür
      }
    }
    if (status.isDenied && !isOld) {
      // Kullanıcı izni reddettiyse ayarlar sayfasına yönlendirin
      openAppSettings();
    }

    return true; // İzin verildiyse true döndür
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
                      child: TextButton(
                        onPressed: () {
                          importMoviesFromCSV(); // CSV içe aktarma fonksiyonunu çağır
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
                              Text('Import from CSV', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039)),
                              SizedBox(width: screenWidth * 0.03),
                              Icon(size: screenWidth * 0.055, Icons.file_upload, color: Colors.white),
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
