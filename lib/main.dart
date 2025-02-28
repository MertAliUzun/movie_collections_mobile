import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movie_collections_mobile/generated/l10n.dart';
import 'screens/collection_screen.dart';
import 'screens/wishlist_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/movie_model.dart';
import 'dart:ui' as ui;
import 'services/ad_service.dart';

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
  
  var systemLanguage = ui.window.locale.languageCode;

  runApp(MyApp(systemLanguage: systemLanguage));
  
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
      title: 'Film Koleksiyonu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(systemLanguage: systemLanguage,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? userId; // Kullanıcı ID'si
  final String? userEmail; // Kullanıcı E-postası
  final String? userPicture; // Kullanıcı Resmi
  final String? userName; // Kullanıcı Adı
  final String? systemLanguage;

  const MyHomePage({super.key, this.userId, this.userEmail, this.userPicture, this.userName, this.systemLanguage});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? _userId;
  String? _userEmail;
  String? _userPicture;
  String? _userName;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _googleSignIn();
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
  }

    Future<AuthResponse> _googleSignIn() async {
    if (_userEmail != null) {
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
        _showErrorDialog(e.toString());
      }

      if (mounted) {
        setState(() {
          _userId = '0'; // User did not log in
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
      body: _userId != null ? Column(
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
