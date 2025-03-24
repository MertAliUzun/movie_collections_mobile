import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'screens/collection_screen.dart';
import 'screens/wishlist_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/movie_model.dart';
import 'dart:ui' as ui;
import 'services/ad_service.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/supabase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env dosyasını yükle
  await dotenv.load(fileName: ".env");
  
  // Supabase'i başlat
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  
  
  /* // Check internet connection and sync local movies if connected
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult[0] != ConnectivityResult.none) {
    final supabase = Supabase.instance.client;
    final service = SupabaseService(supabase);
    await service.syncLocalMovies();
  }
  */

  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter()); // Register the Movie adapter
  await Hive.openBox<Movie>('movies'); // Open the box for movies
  
  // Mevcut filmleri yeni alanlarla güncelle
  await _updateMoviesWithNewFields();
  
  await _checkForUpdate();
  
  var systemLanguage = ui.window.locale.languageCode;

  runApp(MyApp(systemLanguage: systemLanguage));
  
}

Future<void> _checkForUpdate() async {
  try {
    final updateInfo = await InAppUpdate.checkForUpdate();

  if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
    if (updateInfo.immediateUpdateAllowed) {
      // Zorunlu güncelleme
      await InAppUpdate.performImmediateUpdate();
    } else if (updateInfo.flexibleUpdateAllowed) {
      // Esnek güncelleme
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    }
  }
  } catch (e) {
    
  }
  
}

// Mevcut filmleri yeni alanlarla güncelleyen fonksiyon
Future<void> _updateMoviesWithNewFields() async {
  final moviesBox = Hive.box<Movie>('movies');
  
  for (var movie in moviesBox.values) {
    // Yeni bir Movie nesnesi oluştur, eksik alanları varsayılan değerlerle doldur
    final updatedMovie = Movie(
      id: movie.id,
      movieName: movie.movieName,
      directorName: movie.directorName,
      releaseDate: movie.releaseDate,
      plot: movie.plot,
      runtime: movie.runtime,
      imdbRating: movie.imdbRating,
      writers: movie.writers,
      actors: movie.actors,
      watched: movie.watched,
      imageLink: movie.imageLink,
      userEmail: movie.userEmail,
      watchDate: movie.watchDate,
      userScore: movie.userScore,
      hypeScore: movie.hypeScore,
      genres: movie.genres,
      productionCompany: movie.productionCompany,
      customSortTitle: movie.customSortTitle,
      country: movie.country,
      popularity: movie.popularity,
      budget: movie.budget,
      revenue: movie.revenue,
      toSync: movie.toSync,
      watchCount: movie.watchCount,
      myNotes: movie.myNotes,
      collectionType: movie.collectionType,
      // Yeni alanlar için varsayılan değerler
      creationDate: movie.creationDate ?? DateTime.now(),
      pgRating: movie.pgRating ?? '',
      franchises: movie.franchises ?? [],
      tags: movie.tags ?? []
    );
    
    // Güncellenen filmi kaydet
    moviesBox.put(movie.id, updatedMovie);
  }
}

// Premium durumunu kontrol eden fonksiyon
Future<void> _checkPremiumStatus() async {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  final bool available = await inAppPurchase.isAvailable();
  
  if (!available) return;

  // Ürün ID'sini al
  String productId = dotenv.env['PREMIUM_PRODUCT_ID']!;
  
  try {
    // Satın alma stream'ini dinle
    inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchases) async {
      for (var purchase in purchases) {
        if (purchase.productID == productId && 
            (purchase.status == PurchaseStatus.purchased || 
             purchase.status == PurchaseStatus.restored)) {
          // Satın alınmış veya geri yüklenmiş durumda
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isPremium', true);

          if (purchase.pendingCompletePurchase) {
            await inAppPurchase.completePurchase(purchase);
          }
        } else if (purchase.status == PurchaseStatus.error) {
          if (purchase.error?.message == 'BillingResponse.itemAlreadyOwned') {
            // Zaten satın alınmış
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isPremium', true);
          }
        } else if(purchase.status == PurchaseStatus.canceled) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isPremium', false);
        }
      }
    });
  } catch (e) {
    print('Premium durumu kontrol edilirken hata: $e');
  }
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  final String systemLanguage;
  const MyApp({super.key, required this.systemLanguage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: Locale(systemLanguage),
      title: 'Zen: Movie Collection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(systemLanguage: systemLanguage, isInit: true,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? userId; // Kullanıcı ID'si
  final String? userEmail; // Kullanıcı E-postası
  final String? userPicture; // Kullanıcı Resmi
  final String? userName; // Kullanıcı Adı
  final String? systemLanguage;
  final bool? isFromWishlist;
  bool isInit = true;

  MyHomePage({super.key, this.userId, this.userEmail, this.userPicture, this.userName, this.systemLanguage, required this.isInit, this.isFromWishlist});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? _userId;
  String? _userEmail;
  String? _userPicture;
  String? _userName;
  bool? _isLoaded = false;
  final AdService _adService = AdService();
  final InAppReview _inAppReview = InAppReview.instance;

  Future<void> _selectPage() async {
    if(widget.isFromWishlist != null) {
      if(widget.isFromWishlist!) {
        _selectedIndex = 1;
      } else{
        _selectedIndex = 0;
      }
    } else {
      _selectedIndex = 0;
    }
    
  }
  
  @override
  void initState() {
    super.initState();
    if(widget.isInit!) {_googleSignIn(); widget.isInit = false;}
    else { _isLoaded = true; }
    _selectPage();
    _checkPremiumStatus();
    /*
    _adService.loadBannerAd(
      onAdLoaded: (ad) {
        setState(() {});
      },
    );
    _adService.loadRewardedAd(
      onAdLoaded: (ad) {
        setState(() {
          _adService.showRewardedAd();
        });
      }
    );
    */
    _checkAndRequestReview();
  }

  Future<void> _checkAndRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    
    /*
    // Uygulama açılma sayısını al ve artır
    int openCount = prefs.getInt('app_open_count') ?? 0;
    await prefs.setInt('app_open_count', openCount + 1);
    */
    // Son review isteği zamanını al
    final lastReviewTime = prefs.getInt('last_review_time');
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Eğer son review'dan en az 30 gün geçtiyse ve açılış sayısı 5'in katıysa
    if (lastReviewTime == null || now - lastReviewTime > 30 * 24 * 60 * 60 * 1000) // 7 means 7 days, make 30 for a month
       // && (openCount + 1) % 5 == 0) 
        {
      await Future.delayed(const Duration(minutes: 1));
      // Kullanıcı hala uygulamayı kullanıyor mu kontrol et
      if (!mounted) return;
        // Review dialog'unu göster
        if (await _inAppReview.isAvailable()) {
          await _inAppReview.requestReview();
          // Son review zamanını kaydet
          await prefs.setInt('last_review_time', now);
        }
    }
  }

  Future<AuthResponse> _googleSignIn() async {
    if (_userEmail != null) {
      setState(() {
          _isLoaded = true;
        });
      
      return AuthResponse();
    }

    const webClientId = '994622404083-l5lm49gg40agjbrh0vvtnbo6b3sddl3u.apps.googleusercontent.com';
    const iosClientId = '994622404083-pmh33nqujdu7pvekl5djj4nge8hi0v2n.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) {
          _showErrorDialog(S.of(context).signInCancel); // Only use context if mounted
        }
        throw Exception('Sign in canceled');
      }

      

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        if (mounted) {
          _showErrorDialog(S.of(context).noAccessToken); // Only use context if mounted
        }
        throw Exception('No access token');
      }
      if (idToken == null) {
        if (mounted) {
          _showErrorDialog(S.of(context).noIdToken); // Only use context if mounted
        }
        throw Exception('No id token');
      }

      // User data
      _userId = googleUser.id;
      _userEmail = googleUser.email;
      _userPicture = googleUser.photoUrl;
      _userName = googleUser.displayName;

      /*
      // SharedPreferences'dan isPremium değerini al
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('isPremium') ?? false;

      // Supabase'e kullanıcıyı ekle veya güncelle
      final service = SupabaseService(supabase);
      await service.addUser(
        id: _userId!,
        email: _userEmail!,
        userPicture: _userPicture,
        userName: _userName,
        isPremium: isPremium,
      );

      // Premium durumunu Supabase'den kontrol et ve SharedPreferences'ı güncelle
      final isPremiumFromServer = await service.getIsPremium(_userEmail!);
      if (isPremiumFromServer != isPremium) {
        await prefs.setBool('isPremium', isPremiumFromServer);
      }
      */

      setState(() {
        _isLoaded = true;
      });

      // Update movies box
      final moviesBox = Hive.box<Movie>('movies');
      for (var movie in moviesBox.values) {
        if (movie.userEmail == 'test@test.com') {
          movie.userEmail = _userEmail ?? 'test@test.com'; // Update
          moviesBox.put(movie.id, movie); // Save updated movie
        }
      }
      if (mounted) {
        setState(() {
          _selectedIndex = 0;
        });
      }

      return supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      if (mounted) {
        //_showErrorDialog(e.toString());y
      }

      if (mounted) {
        setState(() {
          _userId = '0'; // User did not log in
          _isLoaded = true;
        });
      }

      return AuthResponse();
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
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

  @override
  Widget build(BuildContext context) {
    // _pages listesini burada oluştur
    final List<Widget> _pages = [
      _userId != null && _userId != '0'
          ? CollectionScreen(userId: _userId, userEmail: _userEmail, userPicture: _userPicture, userName: _userName, systemLanguage: widget.systemLanguage,)
          : CollectionScreen(systemLanguage: widget.systemLanguage,),
      _userId != null && _userId != '0'
          ? WishlistScreen(userId: _userId, userEmail: _userEmail, userPicture: _userPicture, userName: _userName, systemLanguage: widget.systemLanguage)
          : WishlistScreen(systemLanguage: widget.systemLanguage),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      body: _isLoaded! ? Column(
        children:[ 
          Expanded(child: _pages[_selectedIndex]), 
          /*
          if(_adService.bannerAd != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _adService.bannerAd!.size.width.toDouble(),
                height: _adService.bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _adService.bannerAd!),
              ),
            )
            */
        ]
      ) 
      : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 44, 50, 60),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.movie, color: Colors.amber,),
            label: S.of(context).collection,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bookmark, color: Colors.red,),
            label: S.of(context).wishlist,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
      ),
    );
  }

  @override
  void dispose() {
    _adService.disposeAds();
    super.dispose();
  }
}
