import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  
  // Uygulama kapatıldığında Hive kutularını kapat
  //await Hive.close();
}

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
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CollectionScreen(),
    const WishlistScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
      ),
    );
  }
}
