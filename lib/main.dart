import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'screens/collection_screen.dart';
import 'screens/wishlist_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/add_movie_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'services/supabase_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/movie_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env dosyasını yükle
  await dotenv.load(fileName: ".env");
  
  // Supabase'i başlat
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  
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
  
  runApp(const MyApp());
  
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film Koleksiyonu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? userId; // Kullanıcı ID'si
  final String? userEmail; // Kullanıcı E-postası
  final String? userPicture; // Kullanıcı Resmi
  final String? userName; // Kullanıcı Adı

  const MyHomePage({super.key, this.userId, this.userEmail, this.userPicture, this.userName});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? _userId;
  String? _userEmail;
  String? _userPicture;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _googleSignIn();
  }

  Future<AuthResponse> _googleSignIn() async {
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

      // Kullanıcı bilgilerini al
      _userId = googleUser.id;
      _userEmail = googleUser.email;
      _userPicture = googleUser.photoUrl;
      _userName = googleUser.displayName;

      // movies kutusundaki userEmail'i güncelle
      final moviesBox = Hive.box<Movie>('movies');
      for (var movie in moviesBox.values) {
        if (movie.userEmail == 'test@test.com') {
          movie.userEmail = _userEmail ?? 'test@test.com'; // Güncelle
          moviesBox.put(movie.id, movie); // Güncellenmiş filmi kutuya kaydet
        }
      }

      // İlk açılışta CollectionScreen'e geçiş yap
      setState(() {
        _selectedIndex = 0; // CollectionScreen'i seç
      });

      return supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      // Hata durumunda kullanıcıya mesaj göster
      _showErrorDialog(e.toString());
      // Kullanıcı giriş yapmadıysa _userId'yi 0 olarak ayarla
      setState(() {
        _userId = '0'; // Kullanıcı giriş yapmadı
      });
      return AuthResponse();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 34, 40, 50),
          title: const Text('Hata', style: TextStyle(color: Colors.white),),
          content: const Text('Check internet your connection.', style: TextStyle(color: Colors.white),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam', style: TextStyle(color: Colors.white)),
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
          ? CollectionScreen(userId: _userId, userEmail: _userEmail, userPicture: _userPicture, userName: _userName,)
          : const CollectionScreen(),
      _userId != null && _userId != '0'
          ? WishlistScreen(userId: _userId, userEmail: _userEmail, userPicture: _userPicture, userName: _userName,)
          : const WishlistScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 50),
      body: _userId != null ? _pages[_selectedIndex] : const Center(child: CircularProgressIndicator()), 
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 44, 50, 60),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.movie, color: Colors.amber,),
            label: 'Koleksiyon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark, color: Colors.red,),
            label: 'İzleme Listesi',
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
}
