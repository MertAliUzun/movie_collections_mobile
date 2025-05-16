import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'package:movie_collections_mobile/screens/hidden_movies_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/movie_model.dart';
import '../screens/discover_main_screen.dart';
import '../screens/edit_movie_screen.dart';
import '../main.dart';
import '../services/ad_service.dart';
import '../services/ai_service.dart';
import '../services/supabase_service.dart';
import '../services/tmdb_service.dart';
import '../screens/ai_movie_recommendations_screen.dart';
import '../screens/discover_movie_screen.dart';
import '../screens/popular_people_screen.dart';
import '../sup/screen_util.dart';

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
  final String systemLanguage;

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
    required this.systemLanguage,
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
  final AdService _adService = AdService();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isPremium = false;

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

    _adService.loadRewardedAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showRewardedAd();
        });
      }
    );

    _loadPremiumStatus();
    _initInAppPurchase();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPremium = prefs.getBool('isPremium') ?? false;
    });
  }

  Future<void> _initInAppPurchase() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // Store bağlantısı yok
      return;
    }

    // Satın alma işlemlerini dinle
    _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchases) {
      _handlePurchaseUpdates(purchases);
    });
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        // Satın alma işlemi devam ediyor
        continue;
      }
      if (purchase.status == PurchaseStatus.error) {
        if (purchase.error?.message == 'BillingResponse.itemAlreadyOwned') {
          // Zaten satın alınmış
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isPremium', true);
          if(mounted) {
          setState(() {
            _isPremium = true;
          });
        }
        } else {
          // Diğer hatalar
          if (mounted) {
            final snackBar = SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              content: AwesomeSnackbarContent(
                title: S.of(context).error,
                message: purchase.error?.message ?? S.of(context).error,
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
      } else if (purchase.status == PurchaseStatus.purchased ||
                 purchase.status == PurchaseStatus.restored) {
        // Satın alma başarılı
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);
        setState(() {
          _isPremium = true;
        });

        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }

        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            content: AwesomeSnackbarContent(
              title: S.of(context).succesful,
              message: S.of(context).succesful,
              contentType: ContentType.success,
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
  }

  Future<void> _buyPremium() async {
    if(userEmail == null || userEmail == 'test@test.com' || userName == null) { return;}
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // Store bağlantısı yoksa hata mesajı göster
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: AwesomeSnackbarContent(
            title: S.of(context).error,
            message: S.of(context).checkInternet,
            contentType: ContentType.failure,
            inMaterialBanner: true,
          ),
          dismissDirection: DismissDirection.horizontal,
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showSnackBar(snackBar);
      }
      return;
    }

    // Ürün ID'sini belirle (App Store ve Play Store'da ayarladığınız ID)
    String productId =  dotenv.env['PREMIUM_PRODUCT_ID']!;

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails({productId});

    if (response.notFoundIDs.isNotEmpty) {
      // Ürün bulunamadı
      return;
    }

    final ProductDetails product = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      // Satın alma işlemini başlat
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // Satın alma hatası
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: AwesomeSnackbarContent(
            title: S.of(context).error,
            message: S.of(context).failure,
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

  Movie? _getRandomMovie(BuildContext context) {
    final random = Random();
    
    // Koşula göre filtreleme yap
    List<Movie> filteredMovies = _isFromWishlist
        ? _movies.where((movie) => !movie.watched && !movie.hidden!).toList() // watched == false
        : _movies.where((movie) => movie.watched && !movie.hidden!).toList(); // watched == true
  
    if (filteredMovies.isEmpty) {
      // Eğer filtrelenmiş listede film yoksa, Snackbar göster
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).error, 
          message: S.of(context).unableToDetectMovies, 
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
    //return;
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
          title: Text(S.of(context).signOut,  style: const TextStyle(color: Colors.white)),
          content: Text(S.of(context).signOutConfirm,  style: const TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).no,  style: const TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(S.of(context).yes, style: const TextStyle(color: Colors.white)),
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
          title: S.of(context).succesful,
          message: S.of(context).signedOutAccount, 
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
    if(!dotenv.isInitialized) { await dotenv.load(fileName: ".env"); }

    final webClientId = dotenv.env['WEB_CLIENT_ID']!;
    final iosClientId = dotenv.env['IOS_CLIENT_ID']!;

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw S.of(context).signInCancel;
      }
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw S.of(context).noAccessToken;
      }
      if (idToken == null) {
        throw S.of(context).noIdToken;
      }

      /*
      // Kullanıcı bilgilerini al
      final String userId = googleUser.id;
      final String userEmail = googleUser.email;
      final String userPicture = googleUser.photoUrl ?? '';
      final String userName = googleUser.displayName ?? '';
      */
      /*
      // SharedPreferences'dan isPremium değerini al
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('isPremium') ?? false;

      // Supabase'e kullanıcıyı ekle veya güncelle
      final service = SupabaseService(supabase);
      await service.addUser(
        id:  googleUser.id,
        email: googleUser.email,
        userPicture: googleUser.photoUrl,
        userName: googleUser.displayName,
        isPremium: isPremium,
      );

      // Premium durumunu Supabase'den kontrol et ve SharedPreferences'ı güncelle
      final isPremiumFromServer = await service.getIsPremium(googleUser.email);
      if (isPremiumFromServer != isPremium) {
        await prefs.setBool('isPremium', isPremiumFromServer);
      }
      */

      // Ana sayfaya yönlendirme yap ve kullanıcı bilgilerini geç
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            isInit: false,
            systemLanguage: widget.systemLanguage,
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
          title: S.of(context).error, 
          message: S.of(context).failure, 
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
    try {
      // CSV verilerini hazırla
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
          'To Sync',
          'Watch Count',
          'My Notes',
          'Collection Type',
          'Creation Date',
          'PG Rating',
          'Franchises',
          'Tags',
          'Hidden'
        ],
      ];

      for (var movie in widget._allMovies) {
        csvData.add([
          movie.id.toString(),
          movie.movieName.toString(),
          movie.directorName.toString(),
          movie.releaseDate.toIso8601String(),
          movie.plot?.toString() ?? '',
          movie.runtime?.toString() ?? '',
          movie.imdbRating?.toString() ?? '',
          movie.writers?.join(', ') ?? '',
          movie.actors?.join(', ') ?? '',
          movie.watched.toString(),
          movie.imageLink.toString(),
          movie.userEmail.toString(),
          movie.watchDate?.toIso8601String() ?? '',
          movie.userScore?.toString() ?? '',
          movie.hypeScore?.toString() ?? '',
          movie.genres?.join(', ') ?? '',
          movie.productionCompany?.join(', ') ?? '',
          movie.customSortTitle?.toString() ?? '',
          movie.country?.toString() ?? '',
          movie.popularity?.toString() ?? '',
          movie.budget?.toString() ?? '',
          movie.revenue?.toString() ?? '',
          movie.toSync.toString(),
          movie.watchCount?.toString() ?? '',
          movie.myNotes?.toString() ?? '',
          movie.collectionType?.toString() ?? '',
          movie.creationDate?.toIso8601String() ?? '',
          movie.pgRating?.toString() ?? '',
          movie.franchises?.join(', ') ?? '',
          movie.tags?.join(', ') ?? '',
          movie.hidden.toString(),
        ]);
      }

      String csvString = const ListToCsvConverter().convert(csvData);
      
      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/movies.csv');
      await tempFile.writeAsString(csvString);

      // Share Plus ile dosyayı paylaş
      final result = await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: 'Movies CSV Export',
        text: 'Here is your exported movies collection',
      );

      if (result.status == ShareResultStatus.success) {
        _adService.showRewardedAd();
        
        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: AwesomeSnackbarContent(
            title: S.of(context).succesful,
            message: S.of(context).csvFileCreated,
            contentType: ContentType.success,
            inMaterialBanner: true,
          ),
          dismissDirection: DismissDirection.horizontal,
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).failure,
          message: '${S.of(context).errorWritingFile} $e',
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
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final input = file.openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();

        final moviesBox = Hive.box<Movie>('movies');

        for (var row in fields.skip(1)) {
          try {
            final movie = Movie(
              id: row[0].toString(),
              movieName: row[1].toString(),
              directorName: row[2].toString(),
              releaseDate: DateTime.parse(row[3].toString()),
              plot: row[4].toString().isEmpty ? null : row[4].toString(),
              runtime: row[5].toString().isEmpty ? null : int.parse(row[5].toString()),
              imdbRating: row[6].toString().isEmpty ? null : double.parse(row[6].toString()),
              writers: row[7].toString().isEmpty ? null : row[7].toString().split(', '),
              actors: row[8].toString().isEmpty ? null : row[8].toString().split(', '),
              watched: row[9].toString().toLowerCase() == 'true',
              imageLink: row[10].toString(),
              userEmail: row[11].toString(),
              watchDate: row[12].toString().isEmpty ? null : DateTime.parse(row[12].toString()),
              userScore: row[13].toString().isEmpty ? null : double.parse(row[13].toString()),
              hypeScore: row[14].toString().isEmpty ? null : double.parse(row[14].toString()),
              genres: row[15].toString().isEmpty ? null : row[15].toString().split(', '),
              productionCompany: row[16].toString().isEmpty ? null : row[16].toString().split(', '),
              customSortTitle: row[17].toString().isEmpty ? null : row[17].toString(),
              country: row[18].toString().isEmpty ? null : row[18].toString(),
              popularity: row[19].toString().isEmpty ? null : double.parse(row[19].toString()),
              budget: row[20].toString().isEmpty ? null : double.parse(row[20].toString()),
              revenue: row[21].toString().isEmpty ? null : double.parse(row[21].toString()),
              toSync: row[22].toString().toLowerCase() == 'false',
              watchCount: row[23].toString().isEmpty ? null : int.parse(row[23].toString()),
              myNotes: row[24].toString().isEmpty ? null : row[24].toString(),
              collectionType: row[25].toString().isEmpty ? null : row[25].toString(),
              creationDate: row[26].toString().isEmpty ? null : DateTime.parse(row[26].toString()),
              pgRating: row[27].toString().isEmpty ? null : row[27].toString(),
              franchises: row[28].toString().isEmpty ? null : row[28].toString().split(', '),
              tags: row[29].toString().isEmpty ? null : row[29].toString().split(', '),
              hidden: row[30].toString().toLowerCase() == 'true',
            );

            moviesBox.put(movie.id, movie);
            _adService.showRewardedAd();
          } catch (e) {
            print('${S.of(context).errorConvertingLine} $e');
            continue;
          }
        }

        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: AwesomeSnackbarContent(
            title: S.of(context).succesful,
            message: S.of(context).csvFileImported,
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
              isInit: false,
              systemLanguage: widget.systemLanguage,
            ),
          ),
        );
      } else {
        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: AwesomeSnackbarContent(
            title: S.of(context).cancelled,
            message: S.of(context).cancelChooseFile,
            contentType: ContentType.failure,
            inMaterialBanner: true,
          ),
          dismissDirection: DismissDirection.horizontal,
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentMaterialBanner()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: AwesomeSnackbarContent(
          title: S.of(context).failure,
          message: S.of(context).errorReadingFile,
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

  /*
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
            title: S.of(context).error,
            message: S.of(context).noStoragePermission,
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
  */

  Future<void> _showErrorDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
          title: Text(S.of(context).error, style: const TextStyle(color: Colors.white),),
          content: Text(S.of(context).checkInternet, style: const TextStyle(color: Colors.white),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).ok, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPremiumDialog(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
          title: Text(
            S.of(context).buyPremium,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    S.of(context).premiumWillBeForPlayStoreUser,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildPremiumFeature(Icons.block, S.of(context).removeAds),
                SizedBox(height: screenHeight * 0.015),
                _buildPremiumFeature(Icons.movie_outlined, S.of(context).removeMovieLimit),
                SizedBox(height: screenHeight * 0.015),
                /*_buildPremiumFeature(Icons.backup_outlined, S.of(context).cloudBackUp),
                SizedBox(height: screenHeight * 0.015),
                _buildPremiumFeature(Icons.star_outline, S.of(context).checkUnderratedOverrated),
                SizedBox(height: screenHeight * 0.015),
                _buildPremiumFeature(Icons.star_outline, S.of(context).premiumSupport),
                SizedBox(height: screenHeight * 0.015),*/
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.04
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                S.of(context).buyButton,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _buyPremium();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumFeature(IconData icon, String text) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.amber,
          size: screenWidth * 0.05,
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    if(userEmail == null || userEmail == 'test@test.com' || userName == null) { return;}
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
          title: Text(
            S.of(context).delete,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            userEmail! + S.of(context).willBeDeleted,
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                S.of(context).no,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                S.of(context).yes,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && userEmail != null) {
      try {
        // Supabase'den kullanıcıyı sil
        final supabase = Supabase.instance.client;
        await supabase.from('users').delete().eq('email', userEmail);

        // Google hesabından çıkış yap
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        /*
        // Premium durumunu sıfırla
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', false);
        */
        // Başarılı silme mesajı göster
        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            content: AwesomeSnackbarContent(
              title: S.of(context).succesful,
              message: S.of(context).succesful,
              contentType: ContentType.success,
              inMaterialBanner: true,
            ),
            dismissDirection: DismissDirection.horizontal,
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentMaterialBanner()
            ..showSnackBar(snackBar);
        }

        // Uygulamayı kapat
        SystemNavigator.pop();
      } catch (e) {
        // Hata durumunda mesaj göster
        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            content: AwesomeSnackbarContent(
              title: S.of(context).error,
              message: S.of(context).failure,
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
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> sortingOptions = [
       DropdownMenuItem(
         value: 'movieName', 
         child: Container(
           child: Text(
             S.of(context).title,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'releaseDate', 
         child: Container(
           child: Text(
             S.of(context).releaseDate,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'directorName', 
         child: Container(
           child: Text(
             S.of(context).director,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'imdbRating', 
         child: Container(
           child: Text(
             S.of(context).imdbRating,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'runtime', 
         child: Container(
           child: Text(
             S.of(context).runtime,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'creationDate', 
         child: Container(
           child: Text(
             S.of(context).creationDate,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
    ];
    if (_isFromWishlist) {
      sortingOptions.add(DropdownMenuItem(value: 'hypeScore', child: Text(S.of(context).hypeScore)));
    } else {
      sortingOptions.add(DropdownMenuItem(value: 'userScore', child: Text(S.of(context).userScore)));
      sortingOptions.add(DropdownMenuItem(value: 'watchDate', child: Text(S.of(context).watchDate)));
      sortingOptions.add(DropdownMenuItem(value: 'watchCount', child: Text(S.of(context).watchCount)));
    }

    List<DropdownMenuItem<String>> groupingOptions = [
       DropdownMenuItem(
         value: 'None', 
         child: Container(
           child: Text(
             S.of(context).none,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'Director', 
         child: Container(
           child: Text(
             S.of(context).director,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'Genre', 
         child: Container(
           child: Text(
             S.of(context).genre,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'Release Year', 
         child: Container(
           child: Text(
             S.of(context).releaseYear,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'Franchise', 
         child: Container(
           child: Text(
             S.of(context).franchise,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'Tag', 
         child: Container(
           child: Text(
             S.of(context).tag,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
    ];
    if (!_isFromWishlist) {
      groupingOptions.add(DropdownMenuItem(value: 'Watch Year', child: Text(S.of(context).watchYear)));
    } 
    List<DropdownMenuItem<String>> sortingDirOptions = [
       DropdownMenuItem(
         value: 'Ascending', 
         child: Container(
           child: Text(
             S.of(context).ascending,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'Descending', 
         child: Container(
           child: Text(
             S.of(context).descending,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
    ];
    List<DropdownMenuItem<String>> viewingOptions = [
       DropdownMenuItem(
         value: 'List', 
         child: Container(
           child: Text(
             S.of(context).list,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'List(Small)', 
         child: Container(
           child: Text(
             S.of(context).listSmall,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'Card', 
         child: Container(
           child: Text(
             S.of(context).card,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
       DropdownMenuItem(
         value: 'Poster', 
         child: Container(
           child: Text(
             S.of(context).poster,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
         )
       ),
    ];

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top),
      width: screenWidth * 0.7,
      child: Drawer(
        backgroundColor: const Color.fromARGB(255, 34, 40, 50),
        child: ListView(
          children: [
            DrawerHeader(
              child: userPicture != null
                  ? Column(
                    children: [
                      GestureDetector(
                        onLongPress: () => _deleteAccount(context),
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
                            style: const TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text:  S.of(context).welcome,
                                style: const TextStyle(fontWeight: FontWeight.normal,),
                              ),
                              TextSpan(
                                text: userName!,
                                style: TextStyle(fontWeight: FontWeight.bold, color: _isPremium ? Colors.amber : Colors.white),
                              ),
                            ],
                          ),
                        )
                      ),
                    ],
                  )
                  : GestureDetector(
                    onTap: () async {
                      // Google hesabına giriş yap
                      await _googleSignIn(context);
                    } ,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,0,10),
                      child: Image.asset(
                       'assets/images/white_logo.png',
                       fit: BoxFit.cover,
                       height: ScreenUtil.getAdaptiveCardHeight(context, screenHeight * 0.2),
                       width: ScreenUtil.getAdaptiveCardWidth(context, screenWidth * 0.3),
                      ),
                    ),
                  )
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).viewAs,
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _viewType,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.055,),
                        underline: const SizedBox(),
                        isExpanded: true, 
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            _changeViewType(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: viewingOptions,
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
                    S.of(context).groupBy,
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _groupByText,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.055,),
                        underline: const SizedBox(),
                        isExpanded: true, 
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _toggleGroupBy(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: groupingOptions,
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
                    S.of(context).sortBy,
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: screenWidth * 0.55,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.055,),
                        underline: const SizedBox(),
                        isExpanded: true, 
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
                        S.of(context).sort,
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
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        dropdownColor: const Color.fromARGB(255, 44, 50, 60),
                        style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.055,),
                        underline: const SizedBox(),
                        isExpanded: true,
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            _onSortDirChanged(newValue);
                            Navigator.of(context).pop();
                          }
                        },
                        items: sortingDirOptions,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            ListTile(
              title: Column(
                children: [
                  /*
                  Container(
                    width: screenWidth * 0.5,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.001, 0, 0),
                      child: TextButton(
                        onPressed: () {
                          if(_isPremium) { null;} else {
                          if (userEmail == null || userEmail == 'test@test.com' || userName == null) {
                            _showErrorDialog(context);
                          } else {
                            _showPremiumDialog(context);
                          }
                         }
                        },
                        style: TextButton.styleFrom(
                          side: BorderSide(
                            color: _isPremium ? Colors.grey : Colors.white,
                            width: .3,
                          ),
                          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  S.of(context).buyPremium,
                                  style: TextStyle(
                                    color: _isPremium ? Colors.grey : Colors.white,
                                    fontSize: screenWidth * 0.039
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Icon(
                                size: screenWidth * 0.055,
                                Icons.verified,
                                color: _isPremium ? Colors.grey : Colors.white
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  */
                  Container(
                    width: screenWidth * 0.5,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.01, 0, 0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiscoverMainScreen(
                                isFromWishlist: _isFromWishlist,
                                userEmail: userEmail,
                                systemLanguage: widget.systemLanguage, //Change with widget.systemLanguage
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: .3,
                          ),
                          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Text(S.of(context).discover, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039),overflow: TextOverflow.ellipsis, softWrap: false)),
                              SizedBox(width: screenWidth * 0.03,),
                              Icon(size: screenWidth * 0.055,
                              Icons.explore, color: Colors.white,),
                            ],
                          ), 
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.5,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.01, 0, 0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HiddenMoviesScreen(
                                systemLanguage: widget.systemLanguage,
                                isFromWishlist: _isFromWishlist ?? true,
                                userEmail: userEmail ?? 'test@test.com',
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: .3,
                          ),
                          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Text(S.of(context).hiddenMovies, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039), overflow: TextOverflow.ellipsis, softWrap: false)),
                              SizedBox(width: screenWidth * 0.03),
                              Icon(size: screenWidth * 0.055, Icons.slow_motion_video, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  /*
                  Container(
                    width: screenWidth * 0.5,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.01, 0, 0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiscoverMovieScreen(
                                discoverType: 'Latest',
                                isFromWishlist: _isFromWishlist ?? true,
                                userEmail: userEmail ?? 'test@test.com',
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: .3,
                          ),
                          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Text(S.of(context).latestMovies, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039), overflow: TextOverflow.ellipsis, softWrap: false)),
                              SizedBox(width: screenWidth * 0.03),
                              Icon(size: screenWidth * 0.055, Icons.slow_motion_video, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.5,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.01, 0, 0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiscoverMovieScreen(
                                discoverType: 'Upcoming',
                                isFromWishlist: _isFromWishlist ?? true,
                                userEmail: userEmail ?? 'test@test.com',
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: .3,
                          ),
                          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Text(S.of(context).upcomingMovies, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039), overflow: TextOverflow.ellipsis, softWrap: false)),
                              SizedBox(width: screenWidth * 0.03),
                              Icon(size: screenWidth * 0.055, Icons.slow_motion_video, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  */
                  Container(
                    width: screenWidth * 0.5,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.01, 0, 0),
                      child: TextButton(
                        onPressed: () {
                          exportMoviesToCSV(); // CSV dışa aktarma fonksiyonunu çağır
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: .3,
                          ),
                          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Text(S.of(context).exportCSV, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039), overflow: TextOverflow.ellipsis, softWrap: false)),
                              SizedBox(width: screenWidth * 0.03),
                              Icon(size: screenWidth * 0.055, Icons.upload, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.5,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.01, 0, 0),
                      child: TextButton(
                        onPressed: () {
                          importMoviesFromCSV(); // CSV içe aktarma fonksiyonunu çağır
                        },
                        style: TextButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: .3,
                          ),
                          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(S.of(context).importCSV, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039), overflow: TextOverflow.ellipsis, softWrap: false),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Icon(size: screenWidth * 0.055, Icons.download, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.5,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.01, 0, 0),
                      child: TextButton(onPressed:() {
                        final movie = _getRandomMovie(context);
                        if (movie == null) { Navigator.of(context).pop(); }
                        if (movie != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMovieScreen(isFromWishlist: _isFromWishlist, movie: movie, userEmail: userEmail, systemLanguage: widget.systemLanguage,),
                          ),
                        );
                      }
                      },style: TextButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white,
                          width: .3,
                        ),
                        backgroundColor: const Color.fromARGB(255, 34, 40, 50),),  
                        child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Text(S.of(context).randomMovie, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.039),overflow: TextOverflow.ellipsis, softWrap: false)),
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
